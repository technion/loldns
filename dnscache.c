#include <unistd.h>
#include "env.h"
#include "exit.h"
#include "scan.h"
#include "strerr.h"
#include "error.h"
#include "ip4.h"
#include "str.h"
#include "uint16.h"
#include "uint64.h"
#include "socket.h"
#include "dns.h"
#include "taia.h"
#include "byte.h"
#include "roots.h"
#include "fmt.h"
#include "iopause.h"
#include "query.h"
#include "alloc.h"
#include "response.h"
#include "cache.h"
#include "ndelay.h"
#include "log.h"
#include "okclient.h"
#include "droproot.h"
#include "openreadclose.h"

#include "bogon.h"
#include "jsrandoms.h"

static int packetquery(char *buf,unsigned int len,char **q,char qtype[2],char qclass[2],char id[2])
{
  unsigned int pos;
  char header[12];

  errno = error_proto;
  pos = dns_packet_copy(buf,len,0,header,12); if (!pos) return 0;
  if (header[2] & 128) return 0; /* must not respond to responses */
  if (!(header[2] & 1)) return 0; /* do not respond to non-recursive queries */
  if (header[2] & 120) return 0;
  if (header[2] & 2) return 0;
  if (byte_diff(header + 4,2,"\0\1")) return 0;

  pos = dns_packet_getname(buf,len,pos,q); if (!pos) return 0;
  pos = dns_packet_copy(buf,len,pos,qtype,2); if (!pos) return 0;
  pos = dns_packet_copy(buf,len,pos,qclass,2); if (!pos) return 0;
  if (byte_diff(qclass,2,DNS_C_IN) && byte_diff(qclass,2,DNS_C_ANY)) return 0;

  byte_copy(id,2,header);
  return 1;
}


static char myipoutgoing[4];
static char buf[1024];
uint64 numqueries = 0;

struct interf {
  char ip[4];
  int udp53;
  int tcp53;
  iopause_fd *udp53io;
  iopause_fd *tcp53io;
  
  struct interf *next;
} ;

struct interf *interhead = 0;

#ifdef MAXLOOKUP
#define MAXUDP MAXLOOKUP
#else
#define MAXUDP 200
#endif

static struct udpclient {
  struct query q;
  struct taia start;
  uint64 active; /* query number, if active; otherwise 0 */
  iopause_fd *io;
  int fd;
  char ip[4];
  uint16 port;
  char id[2];
} u[MAXUDP];
int uactive = 0;

void u_drop(int j)
{
  if (!u[j].active) return;
  log_querydrop(&u[j].active);
  u[j].active = 0; --uactive;
}

void u_respond(int j)
{
  if (!u[j].active) return;
  response_id(u[j].id);
  if (response_len > 512) response_tc();
  socket_send4(u[j].fd,response,response_len,u[j].ip,u[j].port);
  log_querydone(&u[j].active,response_len);
  u[j].active = 0; --uactive;
}

void u_new(int fd)
{
  int j;
  int i;
  struct udpclient *x;
  int len;
  static char *q = 0;
  char qtype[2];
  char qclass[2];

  for (j = 0;j < MAXUDP;++j)
    if (!u[j].active)
      break;

  if (j >= MAXUDP) {
    j = 0;
    for (i = 1;i < MAXUDP;++i)
      if (taia_less(&u[i].start,&u[j].start))
	j = i;
    errno = error_timeout;
    u_drop(j);
  }

  x = u + j;
  taia_now(&x->start);
  x->fd = fd;

  len = socket_recv4(x->fd,buf,sizeof buf,x->ip,&x->port);
  if (len == -1) return;
  if (len >= sizeof buf) return;
  if (x->port < 1024) if (x->port != 53) return;
  if (!okclient(x->ip)) return;

  if (!packetquery(buf,len,&q,qtype,qclass,x->id)) return;

  x->active = ++numqueries; ++uactive;
  log_query(&x->active,x->ip,x->port,x->id,q,qtype);
  switch(query_start(&x->q,q,qtype,qclass,myipoutgoing)) {
    case -1:
      u_drop(j);
      return;
    case 1:
      u_respond(j);
  }
}


#define MAXTCP 20
struct tcpclient {
  struct query q;
  struct taia start;
  struct taia timeout;
  uint64 active; /* query number or 1, if active; otherwise 0 */
  iopause_fd *io;
  int fd;
  char ip[4]; /* send response to this address */
  uint16 port; /* send response to this port */
  char id[2];
  int tcp; /* open TCP socket, if active */
  int state;
  char *buf; /* 0, or dynamically allocated of length len */
  unsigned int len;
  unsigned int pos;
} t[MAXTCP];
int tactive = 0;

/*
state 1: buf 0; normal state at beginning of TCP connection
state 2: buf 0; have read 1 byte of query packet length into len
state 3: buf allocated; have read pos bytes of buf
state 0: buf 0; handling query in q
state -1: buf allocated; have written pos bytes
*/

void t_free(int j)
{
  if (!t[j].buf) return;
  alloc_free(t[j].buf);
  t[j].buf = 0;
}

void t_timeout(int j)
{
  struct taia now;
  if (!t[j].active) return;
  taia_now(&now);
  taia_uint(&t[j].timeout,10);
  taia_add(&t[j].timeout,&t[j].timeout,&now);
}

void t_close(int j)
{
  if (!t[j].active) return;
  t_free(j);
  log_tcpclose(t[j].ip,t[j].port);
  close(t[j].tcp);
  t[j].active = 0; --tactive;
}

void t_drop(int j)
{
  log_querydrop(&t[j].active);
  errno = error_pipe;
  t_close(j);
}

void t_respond(int j)
{
  if (!t[j].active) return;
  log_querydone(&t[j].active,response_len);
  response_id(t[j].id);
  t[j].len = response_len + 2;
  t_free(j);
  t[j].buf = alloc(response_len + 2);
  if (!t[j].buf) { t_close(j); return; }
  uint16_pack_big(t[j].buf,response_len);
  byte_copy(t[j].buf + 2,response_len,response);
  t[j].pos = 0;
  t[j].state = -1;
}

void t_rw(int j)
{
  struct tcpclient *x;
  char ch;
  static char *q = 0;
  char qtype[2];
  char qclass[2];
  int r;

  x = t + j;
  if (x->state == -1) {
    r = write(x->tcp,x->buf + x->pos,x->len - x->pos);
    if (r <= 0) { t_close(j); return; }
    x->pos += r;
    if (x->pos == x->len) {
      t_free(j);
      x->state = 1; /* could drop connection immediately */
    }
    return;
  }

  r = read(x->tcp,&ch,1);
  if (r == 0) { errno = error_pipe; t_close(j); return; }
  if (r < 0) { t_close(j); return; }

  if (x->state == 1) {
    x->len = (unsigned char) ch;
    x->len <<= 8;
    x->state = 2;
    return;
  }
  if (x->state == 2) {
    x->len += (unsigned char) ch;
    if (!x->len) { errno = error_proto; t_close(j); return; }
    x->buf = alloc(x->len);
    if (!x->buf) { t_close(j); return; }
    x->pos = 0;
    x->state = 3;
    return;
  }

  if (x->state != 3) return; /* impossible */

  x->buf[x->pos++] = ch;
  if (x->pos < x->len) return;

  if (!packetquery(x->buf,x->len,&q,qtype,qclass,x->id)) { t_close(j); return; }

  x->active = ++numqueries;
  log_query(&x->active,x->ip,x->port,x->id,q,qtype);
  switch(query_start(&x->q,q,qtype,qclass,myipoutgoing)) {
    case -1:
      t_drop(j);
      return;
    case 1:
      t_respond(j);
      return;
  }
  t_free(j);
  x->state = 0;
}

void t_new(int fd)
{
  int i;
  int j;
  struct tcpclient *x;

  for (j = 0;j < MAXTCP;++j)
    if (!t[j].active)
      break;

  if (j >= MAXTCP) {
    j = 0;
    for (i = 1;i < MAXTCP;++i)
      if (taia_less(&t[i].start,&t[j].start))
	j = i;
    errno = error_timeout;
    if (t[j].state == 0)
      t_drop(j);
    else
      t_close(j);
  }

  x = t + j;
  taia_now(&x->start);
  x->fd = fd;

  x->tcp = socket_accept4(x->fd,x->ip,&x->port);
  if (x->tcp == -1) return;
  if (x->port < 1024) if (x->port != 53) { close(x->tcp); return; }
  if (!okclient(x->ip)) { close(x->tcp); return; }
  if (ndelay_on(x->tcp) == -1) { close(x->tcp); return; } /* Linux bug */

  x->active = 1; ++tactive;
  x->state = 1;
  t_timeout(j);

  log_tcpopen(x->ip,x->port);
}

#define FATAL "dnscache: fatal: "

iopause_fd *io = 0;
int numio;

static void doit(void)
{
  int j;
  struct taia deadline;
  struct taia stamp;
  struct interf *inter;
  int iolen;
  int r;

  io = (iopause_fd *) alloc((numio + 1 + MAXUDP + MAXTCP) * sizeof(iopause_fd));
  if (!io)
    strerr_die2sys(111,FATAL,"unable to alloc io: ");

  for (;;) {
    taia_now(&stamp);
    taia_uint(&deadline,120);
    taia_add(&deadline,&deadline,&stamp);

    iolen = 0;

    for (inter = interhead; inter != 0; inter = inter->next) {
      inter->udp53io = io + iolen++;
      inter->udp53io->fd = inter->udp53;
      inter->udp53io->events = IOPAUSE_READ;

      inter->tcp53io = io + iolen++;
      inter->tcp53io->fd = inter->tcp53;
      inter->tcp53io->events = IOPAUSE_READ;
    }

    for (j = 0;j < MAXUDP;++j)
      if (u[j].active) {
	u[j].io = io + iolen++;
	query_io(&u[j].q,u[j].io,&deadline);
      }
    for (j = 0;j < MAXTCP;++j)
      if (t[j].active) {
	t[j].io = io + iolen++;
	if (t[j].state == 0)
	  query_io(&t[j].q,t[j].io,&deadline);
	else {
	  if (taia_less(&t[j].timeout,&deadline)) deadline = t[j].timeout;
	  t[j].io->fd = t[j].tcp;
	  t[j].io->events = (t[j].state > 0) ? IOPAUSE_READ : IOPAUSE_WRITE;
	}
      }

    iopause(io,iolen,&deadline,&stamp);

    for (j = 0;j < MAXUDP;++j)
      if (u[j].active) {
	r = query_get(&u[j].q,u[j].io,&stamp);
	if (r == -1) u_drop(j);
	if (r == 1) u_respond(j);
      }

    for (j = 0;j < MAXTCP;++j)
      if (t[j].active) {
	if (t[j].io->revents)
	  t_timeout(j);
	if (t[j].state == 0) {
	  r = query_get(&t[j].q,t[j].io,&stamp);
	  if (r == -1) t_drop(j);
	  if (r == 1) t_respond(j);
	}
	else
	  if (t[j].io->revents || taia_less(&t[j].timeout,&stamp))
	    t_rw(j);
      }

    for (inter = interhead; inter != 0; inter = inter->next) {
      if (inter->udp53io)
        if (inter->udp53io->revents)
	  u_new(inter->udp53);

      if (inter->tcp53io)
        if (inter->tcp53io->revents)
	  t_new(inter->tcp53);
    }
  }
}
 
void setbogons()
{

  unsigned int i, j, k;

  stralloc bogonstring = {0};

  if (openreadclose("bogons",&bogonstring,64) != 1) {
    log_bogon("not configured");
    return;
  }
 
  /* JS Bogon code here */
  byte_zero(bogon_list, MAXBOGONS * sizeof(struct ip_mask)); /* FIX */


  for(j = k = i = 0; i < bogonstring.len; i++) {
    if (bogonstring.s[i] == '/')  {
      bogonstring.s[i] = '\0';
      if (!ip4_scan(bogonstring.s+k,bogon_list[j].base))
        strerr_die3x(111,FATAL,"unable to parse address in bogons",bogonstring.s+k);
      log_bogon(bogonstring.s+k);
      k = i+1;
    }
    if (bogonstring.s[i] == '\n')  {
      bogonstring.s[i] = '\0';
      log_bogonnm(bogonstring.s+k);
      if (!ip4_scan(bogonstring.s+k,bogon_list[j].netmask))
        strerr_die3x(111,FATAL,"unable to parse netmask in bogons",bogonstring.s+k);
      j++;
      k = i+1;
    }
  
  }


}

char seed[128];


int main()
{
  char *x;
  int len;
  int pos;
  int oldpos;
  char iptmp[4];
  char iperr[IP4_FMT];
  struct interf *inter;
  struct interf *itmp;
  unsigned long cachesize;

  x = env_get("IP");

  if (!x)
    strerr_die2x(111,FATAL,"$IP not set");

  len = str_len(x);
  numio = pos = oldpos = 0;
  
  while (pos < len) {
    if (pos) oldpos = pos + 1;
    pos = oldpos + str_chr(x + oldpos,'/');
    x[pos] = 0;
    if (!str_len(x + oldpos)) continue;
    
    if (!ip4_scan(x + oldpos,iptmp))
      strerr_die3x(111,FATAL,"unable to parse IP address ",x + oldpos);
      
    inter = (struct interf *) alloc(sizeof(struct interf));
    
    if (interhead == 0) interhead = inter;
    else if (interhead->next == 0) interhead->next = inter;
    else {
      for (itmp = interhead; itmp->next != 0; itmp = itmp->next);
      itmp->next = inter;
    }
    
    inter->next = 0;
    
    inter->udp53 = socket_udp();
    if (inter->udp53 == -1)
      strerr_die4sys(111,FATAL,"unable to create UDP socket for IP address ",x + oldpos,": ");
    if (socket_bind4_reuse(inter->udp53,iptmp,53) == -1)
      strerr_die4sys(111,FATAL,"unable to bind UDP socket for IP address ",x + oldpos,": ");
      
    inter->tcp53 = socket_tcp();
    if (inter->tcp53 == -1)
      strerr_die4sys(111,FATAL,"unable to create TCP socket for IP address ",x + oldpos,": ");
    if (socket_bind4_reuse(inter->tcp53,iptmp,53) == -1)
      strerr_die4sys(111,FATAL,"unable to bind TCP socket for IP address ",x + oldpos,": ");
      
    numio++;
    log_listen(iptmp);
  }

  if (interhead == 0)
    strerr_die2x(111,FATAL,"no interfaces to listen on");

  droproot(FATAL);

  for (inter = interhead; inter != 0; inter = inter->next)
    socket_tryreservein(inter->udp53,131072);

  byte_zero(seed,sizeof seed);
  read(0,seed,sizeof seed);
  jsextrarandom(seed);
  dns_random_init(seed);
  close(0);

  x = env_get("IPSEND");
  if (!x)
    strerr_die2x(111,FATAL,"$IPSEND not set");
  if (!ip4_scan(x,myipoutgoing))
    strerr_die3x(111,FATAL,"unable to parse IP address ",x);

  x = env_get("CACHESIZE");
  if (!x)
    strerr_die2x(111,FATAL,"$CACHESIZE not set");
  scan_ulong(x,&cachesize);
  if (!cache_init(cachesize))
    strerr_die3x(111,FATAL,"not enough memory for cache of size ",x);

  setbogons();



  if (env_get("HIDETTL"))
    response_hidettl();
  if (env_get("FORWARDONLY"))
    query_forwardonly();

  if (!roots_init())
    strerr_die2sys(111,FATAL,"unable to read servers: ");

  for (inter = interhead; inter != 0; inter = inter->next)
    if (socket_listen(inter->tcp53,20) == -1) {
      iperr[ip4_fmt(iperr,inter->ip)] = 0;
      strerr_die4sys(111,FATAL,"unable to listen on TCP socket for IP ",iperr,": ");
    }

  log_startup();
  doit();

  return 0;
}
