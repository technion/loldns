# Don't edit Makefile! Use conf-* for configuration.

SHELL=/bin/sh
CFLAGS=-Wall -g
CC=gcc
AR=ar -qs
MAXLOOKUP=175
MAXBOGONS=16

default: it

clean:
	rm -f *.a *.o
	rm -f dnscache-conf dnscache walldns-conf walldns rbldns-conf rbldns \
	rbldns-data pickdns-conf pickdns pickdns-data tinydns-conf tinydns \
	tinydns-data tinydns-get tinydns-edit axfr-get axfrdns-conf axfrdns \
	dnsip dnsipq dnsname dnstxt dnsmx dnsfilter random-ip dnsqr dnsq \
	dnstrace dnstracesort cachetest utime rts startcache starttiny loglol \
	choose installapp instcheck chkshsgr auto-str direntry.h \
	uint32.h uint64.h hasshsgr.h iopause.h select.h socket.lib \
	hasdevtcp.h systype
	

#Josh's added progs go here
startcache: daemons.o startcache.o
	$(CC) $(CFLAGS) -o startcache daemons.o startcache.o
starttiny: daemons.o starttiny.o
	$(CC) $(CFLAGS) -o starttiny daemons.o starttiny.o
loglol: loglol.o
	$(CC) $(CFLAGS) -o loglol loglol.o
startcache.o: startcache.c daemons.h
	$(CC) $(CFLAGS) -c startcache.c
starttiny.o: starttiny.c daemons.h
	$(CC) $(CFLAGS) -c starttiny.c
daemons.o: daemons.c
	$(CC) $(CFLAGS) -c daemons.c
loglol.o: loglol.c
	$(CC) $(CFLAGS) -c loglol.c

alloc.a: \
alloc.o alloc_re.o getln.o getln2.o stralloc_cat.o \
stralloc_catb.o stralloc_cats.o stralloc_copy.o stralloc_eady.o \
stralloc_num.o stralloc_opyb.o stralloc_opys.o stralloc_pend.o
	$(AR) alloc.a alloc.o alloc_re.o getln.o getln2.o \
	stralloc_cat.o stralloc_catb.o stralloc_cats.o \
	stralloc_copy.o stralloc_eady.o stralloc_num.o \
	stralloc_opyb.o stralloc_opys.o stralloc_pend.o

alloc.o: \
alloc.c alloc.h error.h
	$(CC) $(CFLAGS) -c alloc.c

alloc_re.o: \
alloc_re.c alloc.h byte.h
	$(CC) $(CFLAGS) -c alloc_re.c

auto-str: \
auto-str.o buffer.a unix.a byte.a
	$(CC) $(CFLAGS) -o auto-str auto-str.o buffer.a unix.a byte.a 

auto-str.o: \
auto-str.c buffer.h exit.h
	$(CC) $(CFLAGS) -c auto-str.c

auto_home.c: \
auto-str conf-home
	./auto-str auto_home `head -1 conf-home` > auto_home.c

auto_home.o: \
auto_home.c
	$(CC) $(CFLAGS) -c auto_home.c

axfr-get: \
axfr-get.o iopause.o timeoutread.o timeoutwrite.o dns.a libtai.a \
alloc.a buffer.a unix.a byte.a
	$(CC) $(CFLAGS) -o axfr-get axfr-get.o iopause.o timeoutread.o timeoutwrite.o \
	dns.a libtai.a alloc.a buffer.a unix.a byte.a 

axfr-get.o: \
axfr-get.c uint32.h uint16.h stralloc.h gen_alloc.h error.h \
strerr.h getln.h buffer.h stralloc.h buffer.h exit.h open.h scan.h \
byte.h str.h ip4.h timeoutread.h timeoutwrite.h dns.h stralloc.h \
iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c axfr-get.c

axfrdns: \
axfrdns.o iopause.o droproot.o tdlookup.o response.o qlog.o \
prot.o timeoutread.o timeoutwrite.o dns.a libtai.a alloc.a env.a \
cdb.a buffer.a unix.a byte.a
	$(CC) $(CFLAGS) -o axfrdns axfrdns.o \
	iopause.o droproot.o tdlookup.o response.o \
	qlog.o prot.o timeoutread.o timeoutwrite.o dns.a libtai.a \
	alloc.a env.a cdb.a buffer.a unix.a byte.a 

axfrdns-conf: \
axfrdns-conf.o generic-conf.o auto_home.o buffer.a unix.a byte.a
	$(CC) $(CFLAGS) -o axfrdns-conf axfrdns-conf.o \
	generic-conf.o auto_home.o buffer.a \
	unix.a byte.a 

axfrdns-conf.o: \
axfrdns-conf.c strerr.h exit.h auto_home.h generic-conf.h \
buffer.h
	$(CC) $(CFLAGS) -c axfrdns-conf.c

axfrdns.o: \
axfrdns.c droproot.h exit.h env.h uint32.h uint16.h ip4.h \
tai.h uint64.h buffer.h timeoutread.h timeoutwrite.h open.h seek.h \
cdb.h uint32.h stralloc.h gen_alloc.h strerr.h str.h byte.h case.h \
dns.h stralloc.h iopause.h taia.h tai.h taia.h scan.h qlog.h uint16.h \
response.h uint32.h
	$(CC) $(CFLAGS) -c axfrdns.c

buffer.a: \
buffer.o buffer_1.o buffer_2.o buffer_copy.o buffer_get.o \
buffer_put.o strerr_die.o strerr_sys.o
	$(AR) buffer.a buffer.o buffer_1.o buffer_2.o \
	buffer_copy.o buffer_get.o buffer_put.o strerr_die.o \
	strerr_sys.o

buffer.o: \
buffer.c buffer.h
	$(CC) $(CFLAGS) -c buffer.c

buffer_1.o: \
buffer_1.c buffer.h
	$(CC) $(CFLAGS) -c buffer_1.c

buffer_2.o: \
buffer_2.c buffer.h
	$(CC) $(CFLAGS) -c buffer_2.c

buffer_copy.o: \
buffer_copy.c buffer.h
	$(CC) $(CFLAGS) -c buffer_copy.c

buffer_get.o: \
buffer_get.c buffer.h byte.h error.h
	$(CC) $(CFLAGS) -c buffer_get.c

buffer_put.o: \
buffer_put.c buffer.h str.h byte.h error.h
	$(CC) $(CFLAGS) -c buffer_put.c

buffer_read.o: \
buffer_read.c buffer.h
	$(CC) $(CFLAGS) -c buffer_read.c

buffer_write.o: \
buffer_write.c buffer.h
	$(CC) $(CFLAGS) -c buffer_write.c

byte.a: \
byte_chr.o byte_copy.o byte_cr.o byte_diff.o byte_zero.o \
case_diffb.o case_diffs.o case_lowerb.o fmt_ulong.o ip4_fmt.o \
ip4_scan.o scan_ulong.o str_chr.o str_diff.o str_len.o str_rchr.o \
str_start.o uint16_pack.o uint16_unpack.o uint32_pack.o \
uint32_unpack.o
	$(AR) byte.a byte_chr.o byte_copy.o byte_cr.o \
	byte_diff.o byte_zero.o case_diffb.o case_diffs.o \
	case_lowerb.o fmt_ulong.o ip4_fmt.o ip4_scan.o scan_ulong.o \
	str_chr.o str_diff.o str_len.o str_rchr.o str_start.o \
	uint16_pack.o uint16_unpack.o uint32_pack.o uint32_unpack.o

byte_chr.o: \
byte_chr.c byte.h
	$(CC) $(CFLAGS) -c byte_chr.c

byte_copy.o: \
byte_copy.c byte.h
	$(CC) $(CFLAGS) -c byte_copy.c

byte_cr.o: \
byte_cr.c byte.h
	$(CC) $(CFLAGS) -c byte_cr.c

byte_diff.o: \
byte_diff.c byte.h
	$(CC) $(CFLAGS) -c byte_diff.c

byte_zero.o: \
byte_zero.c byte.h
	$(CC) $(CFLAGS) -c byte_zero.c

cache.o: \
cache.c alloc.h byte.h uint32.h exit.h tai.h uint64.h cache.h \
uint32.h uint64.h
	$(CC) $(CFLAGS) -c cache.c

cachetest: \
cachetest.o cache.o libtai.a buffer.a alloc.a unix.a byte.a
	$(CC) $(CFLAGS) -o cachetest cachetest.o \
	cache.o libtai.a buffer.a alloc.a unix.a \
	byte.a 

cachetest.o: \
cachetest.c buffer.h exit.h cache.h uint32.h uint64.h str.h
	$(CC) $(CFLAGS) -c cachetest.c

case_diffb.o: \
case_diffb.c case.h
	$(CC) $(CFLAGS) -c case_diffb.c

case_diffs.o: \
case_diffs.c case.h
	$(CC) $(CFLAGS) -c case_diffs.c

case_lowerb.o: \
case_lowerb.c case.h
	$(CC) $(CFLAGS) -c case_lowerb.c

cdb.a: \
cdb.o cdb_hash.o cdb_make.o
	$(AR) cdb.a cdb.o cdb_hash.o cdb_make.o

cdb.o: \
cdb.c error.h seek.h byte.h cdb.h uint32.h
	$(CC) $(CFLAGS) -c cdb.c

cdb_hash.o: \
cdb_hash.c cdb.h uint32.h
	$(CC) $(CFLAGS) -c cdb_hash.c

cdb_make.o: \
cdb_make.c seek.h error.h alloc.h cdb.h uint32.h cdb_make.h \
buffer.h uint32.h
	$(CC) $(CFLAGS) -c cdb_make.c

chkshsgr: \
chkshsgr.o
	$(CC) $(CFLAGS) -o chkshsgr chkshsgr.o

chkshsgr.o: \
chkshsgr.c exit.h
	$(CC) $(CFLAGS) -c chkshsgr.c

choose: \
warn-auto.sh choose.sh conf-home
	cat warn-auto.sh choose.sh \
	| sed s}HOME}"`head -1 conf-home`"}g \
	> choose
	chmod 755 choose


dd.o: \
dd.c dns.h stralloc.h gen_alloc.h iopause.h taia.h tai.h \
uint64.h taia.h dd.h
	$(CC) $(CFLAGS) -c dd.c

direntry.h: \
choose trydrent.c direntry.h1 direntry.h2
	./choose c trydrent direntry.h1 direntry.h2 > direntry.h

dns.a: \
dns_dfd.o dns_domain.o dns_dtda.o dns_ip.o dns_ipq.o dns_mx.o \
dns_name.o dns_nd.o dns_packet.o dns_random.o dns_rcip.o dns_rcrw.o \
dns_resolve.o dns_sortip.o dns_transmit.o dns_txt.o
	$(AR) dns.a dns_dfd.o dns_domain.o dns_dtda.o dns_ip.o \
	dns_ipq.o dns_mx.o dns_name.o dns_nd.o dns_packet.o \
	dns_random.o dns_rcip.o dns_rcrw.o dns_resolve.o \
	dns_sortip.o dns_transmit.o dns_txt.o

dns_dfd.o: \
dns_dfd.c error.h alloc.h byte.h dns.h stralloc.h gen_alloc.h \
iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dns_dfd.c

dns_domain.o: \
dns_domain.c error.h alloc.h case.h byte.h dns.h stralloc.h \
gen_alloc.h iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dns_domain.c

dns_dtda.o: \
dns_dtda.c stralloc.h gen_alloc.h dns.h stralloc.h iopause.h \
taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dns_dtda.c

dns_ip.o: \
dns_ip.c stralloc.h gen_alloc.h uint16.h byte.h dns.h \
stralloc.h iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dns_ip.c

dns_ipq.o: \
dns_ipq.c stralloc.h gen_alloc.h case.h byte.h str.h dns.h \
stralloc.h iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dns_ipq.c

dns_mx.o: \
dns_mx.c stralloc.h gen_alloc.h byte.h uint16.h dns.h \
stralloc.h iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dns_mx.c

dns_name.o: \
dns_name.c stralloc.h gen_alloc.h uint16.h byte.h dns.h \
stralloc.h iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dns_name.c

dns_nd.o: \
dns_nd.c byte.h fmt.h dns.h stralloc.h gen_alloc.h iopause.h \
taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dns_nd.c

dns_packet.o: \
dns_packet.c error.h dns.h stralloc.h gen_alloc.h iopause.h \
taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dns_packet.c

dns_random.o: \
dns_random.c dns.h stralloc.h gen_alloc.h iopause.h taia.h \
tai.h uint64.h taia.h taia.h uint32.h
	$(CC) $(CFLAGS) -c dns_random.c

dns_rcip.o: \
dns_rcip.c taia.h tai.h uint64.h openreadclose.h stralloc.h \
gen_alloc.h byte.h ip4.h env.h dns.h stralloc.h iopause.h taia.h \
taia.h
	$(CC) $(CFLAGS) -c dns_rcip.c

dns_rcrw.o: \
dns_rcrw.c taia.h tai.h uint64.h env.h byte.h str.h \
openreadclose.h stralloc.h gen_alloc.h dns.h stralloc.h iopause.h \
taia.h taia.h
	$(CC) $(CFLAGS) -c dns_rcrw.c

dns_resolve.o: \
dns_resolve.c iopause.h taia.h tai.h uint64.h taia.h byte.h \
dns.h stralloc.h gen_alloc.h iopause.h taia.h
	$(CC) $(CFLAGS) -c dns_resolve.c

dns_sortip.o: \
dns_sortip.c byte.h dns.h stralloc.h gen_alloc.h iopause.h \
taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dns_sortip.c

dns_transmit.o: \
dns_transmit.c socket.h uint16.h alloc.h error.h byte.h \
uint16.h dns.h stralloc.h gen_alloc.h iopause.h taia.h tai.h uint64.h \
taia.h
	$(CC) $(CFLAGS) -c dns_transmit.c

dns_txt.o: \
dns_txt.c stralloc.h gen_alloc.h uint16.h byte.h dns.h \
stralloc.h iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dns_txt.c

dnscache: \
dnscache.o droproot.o okclient.o log.o cache.o query.o jsrandoms.o  \
response.o dd.o roots.o iopause.o prot.o dns.a env.a alloc.a buffer.a \
libtai.a unix.a byte.a socket.lib
	$(CC) $(CFLAGS) -o dnscache dnscache.o jsrandoms.o  \
	droproot.o okclient.o log.o cache.o \
	query.o response.o dd.o roots.o iopause.o prot.o dns.a \
	env.a alloc.a buffer.a libtai.a unix.a byte.a  `cat \
	socket.lib` 

dnscache-conf: \
dnscache-conf.o generic-conf.o auto_home.o libtai.a buffer.a \
unix.a byte.a
	$(CC) $(CFLAGS) -o dnscache-conf dnscache-conf.o \
	generic-conf.o auto_home.o libtai.a \
	buffer.a unix.a byte.a 

dnscache-conf.o: \
dnscache-conf.c hasdevtcp.h strerr.h buffer.h uint32.h taia.h \
tai.h uint64.h str.h open.h error.h exit.h auto_home.h generic-conf.h \
buffer.h
	$(CC) $(CFLAGS) -c dnscache-conf.c -DMAXLOOKUP=$(MAXLOOKUP)

dnscache.o: \
dnscache.c env.h exit.h scan.h strerr.h error.h ip4.h \
uint16.h uint64.h socket.h uint16.h dns.h stralloc.h gen_alloc.h \
iopause.h taia.h tai.h uint64.h taia.h taia.h byte.h roots.h fmt.h \
iopause.h query.h dns.h uint32.h alloc.h response.h uint32.h cache.h \
uint32.h uint64.h ndelay.h log.h uint64.h okclient.h droproot.h bogon.h
	$(CC) $(CFLAGS) -c dnscache.c -DMAXLOOKUP=$(MAXLOOKUP) -DMAXBOGONS=$(MAXBOGONS)

dnsfilter: \
dnsfilter.o iopause.o getopt.a dns.a env.a libtai.a alloc.a \
buffer.a unix.a byte.a socket.lib
	$(CC) $(CFLAGS) -o dnsfilter dnsfilter.o \
	iopause.o getopt.a dns.a env.a libtai.a \
	alloc.a buffer.a unix.a byte.a  `cat socket.lib `

dnsfilter.o: \
dnsfilter.c strerr.h buffer.h stralloc.h gen_alloc.h alloc.h \
dns.h stralloc.h iopause.h taia.h tai.h uint64.h taia.h ip4.h byte.h \
scan.h taia.h sgetopt.h subgetopt.h iopause.h error.h exit.h
	$(CC) $(CFLAGS) -c dnsfilter.c

dnsip: \
dnsip.o iopause.o dns.a env.a libtai.a alloc.a buffer.a unix.a \
byte.a socket.lib
	$(CC) $(CFLAGS) -o dnsip dnsip.o \
	iopause.o dns.a env.a libtai.a alloc.a \
	buffer.a unix.a byte.a  `cat socket.lib` 

dnsip.o: \
dnsip.c buffer.h exit.h strerr.h ip4.h dns.h stralloc.h \
gen_alloc.h iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dnsip.c

dnsipq: \
dnsipq.o iopause.o dns.a env.a libtai.a alloc.a buffer.a unix.a \
byte.a socket.lib
	$(CC) $(CFLAGS) -o dnsipq dnsipq.o \
	iopause.o dns.a env.a libtai.a alloc.a \
	buffer.a unix.a byte.a  `cat socket.lib` 

dnsipq.o: \
dnsipq.c buffer.h exit.h strerr.h ip4.h dns.h stralloc.h \
gen_alloc.h iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dnsipq.c

dnsmx: \
dnsmx.o iopause.o dns.a env.a libtai.a alloc.a buffer.a unix.a \
byte.a socket.lib
	$(CC) $(CFLAGS) -o dnsmx  dnsmx.o \
	iopause.o dns.a env.a libtai.a alloc.a \
	buffer.a unix.a byte.a  `cat socket.lib` 

dnsmx.o: \
dnsmx.c buffer.h exit.h strerr.h uint16.h byte.h str.h fmt.h \
dns.h stralloc.h gen_alloc.h iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dnsmx.c

dnsname: \
dnsname.o iopause.o dns.a env.a libtai.a alloc.a buffer.a unix.a \
byte.a socket.lib
	$(CC) $(CFLAGS) -o dnsname dnsname.o \
	iopause.o dns.a env.a libtai.a alloc.a \
	buffer.a unix.a byte.a  `cat socket.lib`

dnsname.o: \
dnsname.c buffer.h exit.h strerr.h ip4.h dns.h stralloc.h \
gen_alloc.h iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dnsname.c

dnsq: \
dnsq.o iopause.o printrecord.o printpacket.o parsetype.o dns.a \
env.a libtai.a buffer.a alloc.a unix.a byte.a socket.lib
	$(CC) $(CFLAGS) -o dnsq dnsq.o \
	iopause.o printrecord.o printpacket.o \
	parsetype.o dns.a env.a libtai.a buffer.a alloc.a unix.a \
	byte.a  `cat socket.lib`

dnsq.o: \
dnsq.c uint16.h strerr.h buffer.h scan.h str.h byte.h error.h \
ip4.h iopause.h taia.h tai.h uint64.h printpacket.h stralloc.h \
gen_alloc.h parsetype.h dns.h stralloc.h iopause.h taia.h
	$(CC) $(CFLAGS) -c dnsq.c

dnsqr: \
dnsqr.o iopause.o printrecord.o printpacket.o parsetype.o dns.a \
env.a libtai.a buffer.a alloc.a unix.a byte.a socket.lib
	$(CC) $(CFLAGS) -o dnsqr dnsqr.o \
	iopause.o printrecord.o printpacket.o \
	parsetype.o dns.a env.a libtai.a buffer.a alloc.a unix.a \
	byte.a  `cat socket.lib`

dnsqr.o: \
dnsqr.c uint16.h strerr.h buffer.h scan.h str.h byte.h \
error.h iopause.h taia.h tai.h uint64.h printpacket.h stralloc.h \
gen_alloc.h parsetype.h dns.h stralloc.h iopause.h taia.h
	$(CC) $(CFLAGS) -c dnsqr.c

dnstrace: \
dnstrace.o dd.o iopause.o printrecord.o parsetype.o dns.a env.a \
libtai.a alloc.a buffer.a unix.a byte.a socket.lib
	$(CC) $(CFLAGS) -o dnstrace dnstrace.o \
	dd.o iopause.o printrecord.o parsetype.o \
	dns.a env.a libtai.a alloc.a buffer.a unix.a byte.a  `cat \
	socket.lib`

dnstrace.o: \
dnstrace.c uint16.h uint32.h fmt.h str.h byte.h ip4.h \
gen_alloc.h gen_allocdefs.h exit.h buffer.h stralloc.h gen_alloc.h \
error.h strerr.h iopause.h taia.h tai.h uint64.h printrecord.h \
stralloc.h alloc.h parsetype.h dd.h dns.h stralloc.h iopause.h taia.h
	$(CC) $(CFLAGS) -c dnstrace.c

dnstracesort: \
warn-auto.sh dnstracesort.sh conf-home
	cat warn-auto.sh dnstracesort.sh \
	| sed s}HOME}"`head -1 conf-home`"}g \
	> dnstracesort
	chmod 755 dnstracesort

dnstxt: \
dnstxt.o iopause.o dns.a env.a libtai.a alloc.a buffer.a unix.a \
byte.a socket.lib
	$(CC) $(CFLAGS) -o dnstxt dnstxt.o \
	iopause.o dns.a env.a libtai.a alloc.a \
	buffer.a unix.a byte.a  `cat socket.lib`

dnstxt.o: \
dnstxt.c buffer.h exit.h strerr.h dns.h stralloc.h \
gen_alloc.h iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c dnstxt.c

droproot.o: \
droproot.c env.h scan.h prot.h strerr.h
	$(CC) $(CFLAGS) -c droproot.c

env.a: \
env.o
	$(AR) env.a env.o

env.o: \
env.c str.h env.h
	$(CC) $(CFLAGS) -c env.c

error.o: \
error.c error.h
	$(CC) $(CFLAGS) -c error.c

error_str.o: \
error_str.c error.h
	$(CC) $(CFLAGS) -c error_str.c

fmt_ulong.o: \
fmt_ulong.c fmt.h
	$(CC) $(CFLAGS) -c fmt_ulong.c

generic-conf.o: \
generic-conf.c strerr.h buffer.h open.h generic-conf.h \
buffer.h
	$(CC) $(CFLAGS) -c generic-conf.c

getln.o: \
getln.c byte.h getln.h buffer.h stralloc.h gen_alloc.h
	$(CC) $(CFLAGS) -c getln.c

getln2.o: \
getln2.c byte.h getln.h buffer.h stralloc.h gen_alloc.h
	$(CC) $(CFLAGS) -c getln2.c

getopt.a: \
sgetopt.o subgetopt.o
	$(AR) getopt.a sgetopt.o subgetopt.o

hasdevtcp.h: \
systype hasdevtcp.h1 hasdevtcp.h2
	( case "`cat systype`" in \
	  sunos-5.*) cat hasdevtcp.h2 ;; \
	  *) cat hasdevtcp.h1 ;; \
	esac ) > hasdevtcp.h

hasshsgr.h: \
choose tryshsgr.c hasshsgr.h1 hasshsgr.h2 chkshsgr \
warn-shsgr
	./chkshsgr -o chkshsgr chkshgsr.o || ( cat warn-shsgr; exit 1 )
	./choose clr tryshsgr hasshsgr.h1 hasshsgr.h2 > hasshsgr.h

hier.o: \
hier.c auto_home.h
	$(CC) $(CFLAGS) -c hier.c

installapp: \
installapp.o hier.o auto_home.o buffer.a unix.a byte.a
	$(CC) $(CFLAGS) -o installapp installapp.o \
	hier.o auto_home.o buffer.a unix.a byte.a 

installapp.o: \
installapp.c buffer.h strerr.h error.h open.h exit.h
	$(CC) $(CFLAGS) -c installapp.c

iopause.h: \
choose trypoll.c iopause.h1 iopause.h2
	./choose clr trypoll iopause.h1 iopause.h2 > iopause.h

iopause.o: \
iopause.c taia.h tai.h uint64.h select.h iopause.h taia.h
	$(CC) $(CFLAGS) -c iopause.c

ip4_fmt.o: \
ip4_fmt.c fmt.h ip4.h
	$(CC) $(CFLAGS) -c ip4_fmt.c

ip4_scan.o: \
ip4_scan.c scan.h ip4.h
	$(CC) $(CFLAGS) -c ip4_scan.c

it: \
prog installapp 

libtai.a: \
tai_add.o tai_now.o tai_pack.o tai_sub.o tai_uint.o \
tai_unpack.o taia_add.o taia_approx.o taia_frac.o taia_less.o \
taia_now.o taia_pack.o taia_sub.o taia_tai.o taia_uint.o
	$(AR) libtai.a tai_add.o tai_now.o tai_pack.o \
	tai_sub.o tai_uint.o tai_unpack.o taia_add.o taia_approx.o \
	taia_frac.o taia_less.o taia_now.o taia_pack.o taia_sub.o \
	taia_tai.o taia_uint.o

log.o: \
log.c buffer.h uint32.h uint16.h error.h byte.h log.h \
uint64.h
	$(CC) $(CFLAGS) -c log.c

ndelay_off.o: \
ndelay_off.c ndelay.h
	$(CC) $(CFLAGS) -c ndelay_off.c

ndelay_on.o: \
ndelay_on.c ndelay.h
	$(CC) $(CFLAGS) -c ndelay_on.c

okclient.o: \
okclient.c str.h ip4.h okclient.h
	$(CC) $(CFLAGS) -c okclient.c

open_read.o: \
open_read.c open.h
	$(CC) $(CFLAGS) -c open_read.c

open_trunc.o: \
open_trunc.c open.h
	$(CC) $(CFLAGS) -c open_trunc.c

openreadclose.o: \
openreadclose.c error.h open.h readclose.h stralloc.h \
gen_alloc.h openreadclose.h stralloc.h
	$(CC) $(CFLAGS) -c openreadclose.c

parsetype.o: \
parsetype.c scan.h byte.h case.h dns.h stralloc.h gen_alloc.h \
iopause.h taia.h tai.h uint64.h taia.h uint16.h parsetype.h
	$(CC) $(CFLAGS) -c parsetype.c

pickdns: \
pickdns.o server.o response.o droproot.o qlog.o prot.o dns.a \
env.a libtai.a cdb.a alloc.a buffer.a unix.a byte.a socket.lib
	$(CC) $(CFLAGS) -o pickdns pickdns.o \
	 server.o response.o droproot.o qlog.o \
	prot.o dns.a env.a libtai.a cdb.a alloc.a buffer.a unix.a \
	byte.a  `cat socket.lib`

pickdns-conf: \
pickdns-conf.o generic-conf.o auto_home.o buffer.a unix.a byte.a
	$(CC) $(CFLAGS) -o pickdns-conf pickdns-conf.o \
	generic-conf.o auto_home.o buffer.a \
	unix.a byte.a 

pickdns-conf.o: \
pickdns-conf.c strerr.h exit.h auto_home.h generic-conf.h \
buffer.h
	$(CC) $(CFLAGS) -c pickdns-conf.c

pickdns-data: \
pickdns-data.o cdb.a dns.a alloc.a buffer.a unix.a byte.a
	$(CC) $(CFLAGS) -o pickdns-data pickdns-data.o \
	cdb.a dns.a alloc.a buffer.a unix.a \
	byte.a 

pickdns-data.o: \
pickdns-data.c buffer.h exit.h cdb_make.h buffer.h uint32.h \
open.h alloc.h gen_allocdefs.h stralloc.h gen_alloc.h getln.h \
buffer.h stralloc.h case.h strerr.h str.h byte.h scan.h fmt.h ip4.h \
dns.h stralloc.h iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c pickdns-data.c

pickdns.o: \
pickdns.c byte.h case.h dns.h stralloc.h gen_alloc.h \
iopause.h taia.h tai.h uint64.h taia.h open.h cdb.h uint32.h \
response.h uint32.h
	$(CC) $(CFLAGS) -c pickdns.c

printpacket.o: \
printpacket.c uint16.h uint32.h error.h byte.h dns.h \
stralloc.h gen_alloc.h iopause.h taia.h tai.h uint64.h taia.h \
printrecord.h stralloc.h printpacket.h stralloc.h
	$(CC) $(CFLAGS) -c printpacket.c

printrecord.o: \
printrecord.c uint16.h uint32.h error.h byte.h dns.h \
stralloc.h gen_alloc.h iopause.h taia.h tai.h uint64.h taia.h \
printrecord.h stralloc.h
	$(CC) $(CFLAGS) -c printrecord.c

prog: \
dnscache-conf dnscache  \
tinydns-conf tinydns \
tinydns-data tinydns-get tinydns-edit axfr-get  \
cachetest utime startcache starttiny loglol

prot.o: \
prot.c hasshsgr.h prot.h
	$(CC) $(CFLAGS) -c prot.c

qlog.o: \
qlog.c buffer.h qlog.h uint16.h
	$(CC) $(CFLAGS) -c qlog.c

query.o: \
query.c error.h roots.h log.h uint64.h case.h cache.h \
uint32.h uint64.h byte.h dns.h stralloc.h gen_alloc.h iopause.h \
taia.h tai.h uint64.h taia.h uint64.h uint32.h uint16.h dd.h alloc.h \
response.h uint32.h query.h dns.h uint32.h bogon.h
	$(CC) $(CFLAGS) -c query.c -DMAXBOGONS=$(MAXBOGONS)

random-ip: \
random-ip.o dns.a libtai.a buffer.a unix.a byte.a
	$(CC) $(CFLAGS) -o random-ip random-ip.o \
	dns.a libtai.a buffer.a unix.a byte.a 

random-ip.o: \
random-ip.c buffer.h exit.h fmt.h scan.h dns.h stralloc.h \
gen_alloc.h iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c random-ip.c

rbldns: \
rbldns.o server.o response.o dd.o droproot.o qlog.o prot.o dns.a \
env.a libtai.a cdb.a alloc.a buffer.a unix.a byte.a socket.lib
	$(CC) $(CFLAGS) -o rbldns rbldns.o \
	server.o response.o dd.o droproot.o qlog.o \
	prot.o dns.a env.a libtai.a cdb.a alloc.a buffer.a unix.a \
	byte.a  `cat socket.lib`

rbldns-conf: \
rbldns-conf.o generic-conf.o auto_home.o buffer.a unix.a byte.a
	$(CC) $(CFLAGS) -o rbldns-conf rbldns-conf.o \
	generic-conf.o auto_home.o buffer.a \
	unix.a byte.a 

rbldns-conf.o: \
rbldns-conf.c strerr.h exit.h auto_home.h generic-conf.h \
buffer.h
	$(CC) $(CFLAGS) -c rbldns-conf.c

rbldns-data: \
rbldns-data.o cdb.a alloc.a buffer.a unix.a byte.a
	$(CC) $(CFLAGS) -o rbldns-data rbldns-data.o \
	cdb.a alloc.a buffer.a unix.a byte.a 

rbldns-data.o: \
rbldns-data.c buffer.h exit.h cdb_make.h buffer.h uint32.h \
open.h stralloc.h gen_alloc.h getln.h buffer.h stralloc.h strerr.h \
byte.h scan.h fmt.h ip4.h
	$(CC) $(CFLAGS) -c rbldns-data.c

rbldns.o: \
rbldns.c str.h byte.h ip4.h open.h env.h cdb.h uint32.h dns.h \
stralloc.h gen_alloc.h iopause.h taia.h tai.h uint64.h taia.h dd.h \
strerr.h response.h uint32.h
	$(CC) $(CFLAGS) -c rbldns.c

readclose.o: \
readclose.c error.h readclose.h stralloc.h gen_alloc.h
	$(CC) $(CFLAGS) -c readclose.c

response.o: \
response.c dns.h stralloc.h gen_alloc.h iopause.h taia.h \
tai.h uint64.h taia.h byte.h uint16.h response.h uint32.h
	$(CC) $(CFLAGS) -c response.c

roots.o: \
roots.c open.h error.h str.h byte.h error.h direntry.h ip4.h \
dns.h stralloc.h gen_alloc.h iopause.h taia.h tai.h uint64.h taia.h \
openreadclose.h stralloc.h roots.h
	$(CC) $(CFLAGS) -c roots.c

scan_ulong.o: \
scan_ulong.c scan.h
	$(CC) $(CFLAGS) -c scan_ulong.c

seek_set.o: \
seek_set.c seek.h
	$(CC) $(CFLAGS) -c seek_set.c

select.h: \
choose trysysel.c select.h1 select.h2
	./choose c trysysel select.h1 select.h2 > select.h

server.o: \
server.c byte.h case.h env.h buffer.h strerr.h ip4.h uint16.h \
ndelay.h socket.h uint16.h droproot.h qlog.h uint16.h response.h \
uint32.h dns.h stralloc.h gen_alloc.h iopause.h taia.h tai.h uint64.h \
taia.h
	$(CC) $(CFLAGS) -c server.c

install: \
it installapp
	./installapp
	cp initscript /etc/init.d/loldns
	chmod 755 /etc/init.d/loldns
	mkdir -p /etc/sysconfig
	dig @e.root-servers.net . ns  |awk '/\tA\t/ {print $$5}' > /etc/dnsroots.global

rofl:
	@echo ".......................__ ............ "
	@echo "...............<ROFL ROFL ROFL ROFL>. "
	@echo "......................| |..........." 
	@echo "................... __\||/____......" 
	@echo ".\\...............|'-|--| .\\..\....." 
	@echo "..\ \_...........|--|---|..\\...\.... "
	@echo "../ L \_________,/-------\___\___\ "
	@echo ".|LOL|----------------O----- ----,\.." 
	@echo "..\ L /______,---''-----------, /..." 
	@echo "../ /.............\_________ ,/...." 
	@echo ".//.............____//___ __\\__/. "


sgetopt.o: \
sgetopt.c buffer.h sgetopt.h subgetopt.h subgetopt.h
	$(CC) $(CFLAGS) -c sgetopt.c

socket.lib: \
trylsock.c
	( ( $(CC) $(CFLAGS) -c trylsock.c && \
	$(CC) $(CFLAGS) -o trylsock -lsocket -lnsl ) >/dev/null 2>&1 \
	&& echo -lsocket -lnsl || exit 0 ) > socket.lib
	rm -f trylsock.o trylsock

socket_accept.o: \
socket_accept.c byte.h socket.h uint16.h
	$(CC) $(CFLAGS) -c socket_accept.c

socket_bind.o: \
socket_bind.c byte.h socket.h uint16.h
	$(CC) $(CFLAGS) -c socket_bind.c

socket_conn.o: \
socket_conn.c byte.h socket.h uint16.h
	$(CC) $(CFLAGS) -c socket_conn.c

socket_listen.o: \
socket_listen.c socket.h uint16.h
	$(CC) $(CFLAGS) -c socket_listen.c

socket_recv.o: \
socket_recv.c byte.h socket.h uint16.h
	$(CC) $(CFLAGS) -c socket_recv.c

socket_send.o: \
socket_send.c byte.h socket.h uint16.h
	$(CC) $(CFLAGS) -c socket_send.c

socket_tcp.o: \
socket_tcp.c ndelay.h socket.h uint16.h
	$(CC) $(CFLAGS) -c socket_tcp.c

socket_udp.o: \
socket_udp.c ndelay.h socket.h uint16.h
	$(CC) $(CFLAGS) -c socket_udp.c

str_chr.o: \
str_chr.c str.h
	$(CC) $(CFLAGS) -c str_chr.c

str_diff.o: \
str_diff.c str.h
	$(CC) $(CFLAGS) -c str_diff.c

str_len.o: \
str_len.c str.h
	$(CC) $(CFLAGS) -c str_len.c

str_rchr.o: \
str_rchr.c str.h
	$(CC) $(CFLAGS) -c str_rchr.c

str_start.o: \
str_start.c str.h
	$(CC) $(CFLAGS) -c str_start.c

stralloc_cat.o: \
stralloc_cat.c byte.h stralloc.h gen_alloc.h
	$(CC) $(CFLAGS) -c stralloc_cat.c

stralloc_catb.o: \
stralloc_catb.c stralloc.h gen_alloc.h byte.h
	$(CC) $(CFLAGS) -c stralloc_catb.c

stralloc_cats.o: \
stralloc_cats.c byte.h str.h stralloc.h gen_alloc.h
	$(CC) $(CFLAGS) -c stralloc_cats.c

stralloc_copy.o: \
stralloc_copy.c byte.h stralloc.h gen_alloc.h
	$(CC) $(CFLAGS) -c stralloc_copy.c

stralloc_eady.o: \
stralloc_eady.c alloc.h stralloc.h gen_alloc.h \
gen_allocdefs.h
	$(CC) $(CFLAGS) -c stralloc_eady.c

stralloc_num.o: \
stralloc_num.c stralloc.h gen_alloc.h
	$(CC) $(CFLAGS) -c stralloc_num.c

stralloc_opyb.o: \
stralloc_opyb.c stralloc.h gen_alloc.h byte.h
	$(CC) $(CFLAGS) -c stralloc_opyb.c

stralloc_opys.o: \
stralloc_opys.c byte.h str.h stralloc.h gen_alloc.h
	$(CC) $(CFLAGS) -c stralloc_opys.c

stralloc_pend.o: \
stralloc_pend.c alloc.h stralloc.h gen_alloc.h \
gen_allocdefs.h
	$(CC) $(CFLAGS) -c stralloc_pend.c

strerr_die.o: \
strerr_die.c buffer.h exit.h strerr.h
	$(CC) $(CFLAGS) -c strerr_die.c

strerr_sys.o: \
strerr_sys.c error.h strerr.h
	$(CC) $(CFLAGS) -c strerr_sys.c

subgetopt.o: \
subgetopt.c subgetopt.h
	$(CC) $(CFLAGS) -c subgetopt.c

systype: \
find-systype.sh conf-cc conf-ld trycpp.c x86cpuid.c
	( cat warn-auto.sh; \
	echo CC=\'`head -1 conf-cc`\'; \
	echo LD=\'`head -1 conf-ld`\'; \
	cat find-systype.sh; \
	) | sh > systype

tai_add.o: \
tai_add.c tai.h uint64.h
	$(CC) $(CFLAGS) -c tai_add.c

tai_now.o: \
tai_now.c tai.h uint64.h
	$(CC) $(CFLAGS) -c tai_now.c

tai_pack.o: \
tai_pack.c tai.h uint64.h
	$(CC) $(CFLAGS) -c tai_pack.c

tai_sub.o: \
tai_sub.c tai.h uint64.h
	$(CC) $(CFLAGS) -c tai_sub.c

tai_uint.o: \
tai_uint.c tai.h uint64.h
	$(CC) $(CFLAGS) -c tai_uint.c

tai_unpack.o: \
tai_unpack.c tai.h uint64.h
	$(CC) $(CFLAGS) -c tai_unpack.c

taia_add.o: \
taia_add.c taia.h tai.h uint64.h
	$(CC) $(CFLAGS) -c taia_add.c

taia_approx.o: \
taia_approx.c taia.h tai.h uint64.h
	$(CC) $(CFLAGS) -c taia_approx.c

taia_frac.o: \
taia_frac.c taia.h tai.h uint64.h
	$(CC) $(CFLAGS) -c taia_frac.c

taia_less.o: \
taia_less.c taia.h tai.h uint64.h
	$(CC) $(CFLAGS) -c taia_less.c

taia_now.o: \
taia_now.c taia.h tai.h uint64.h
	$(CC) $(CFLAGS) -c taia_now.c

taia_pack.o: \
taia_pack.c taia.h tai.h uint64.h
	$(CC) $(CFLAGS) -c taia_pack.c

taia_sub.o: \
taia_sub.c taia.h tai.h uint64.h
	$(CC) $(CFLAGS) -c taia_sub.c

taia_tai.o: \
taia_tai.c taia.h tai.h uint64.h
	$(CC) $(CFLAGS) -c taia_tai.c

taia_uint.o: \
taia_uint.c taia.h tai.h uint64.h
	$(CC) $(CFLAGS) -c taia_uint.c

tdlookup.o: \
tdlookup.c uint16.h open.h tai.h uint64.h cdb.h uint32.h \
byte.h case.h dns.h stralloc.h gen_alloc.h iopause.h taia.h tai.h \
taia.h seek.h response.h uint32.h
	$(CC) $(CFLAGS) -c tdlookup.c

timeoutread.o: \
timeoutread.c error.h iopause.h taia.h tai.h uint64.h \
timeoutread.h
	$(CC) $(CFLAGS) -c timeoutread.c

timeoutwrite.o: \
timeoutwrite.c error.h iopause.h taia.h tai.h uint64.h \
timeoutwrite.h
	$(CC) $(CFLAGS) -c timeoutwrite.c

tinydns: \
tinydns.o iopause.o server.o droproot.o tdlookup.o response.o qlog.o \
prot.o dns.a libtai.a env.a cdb.a alloc.a buffer.a unix.a byte.a \
socket.lib
	$(CC) $(CFLAGS) -o tinydns tinydns.o iopause.o  \
	server.o droproot.o tdlookup.o response.o \
	qlog.o prot.o dns.a libtai.a env.a cdb.a alloc.a buffer.a \
	unix.a byte.a  `cat socket.lib`

tinydns-conf: \
tinydns-conf.o generic-conf.o auto_home.o buffer.a unix.a byte.a
	$(CC) $(CFLAGS) -o tinydns-conf tinydns-conf.o \
	generic-conf.o auto_home.o buffer.a \
	unix.a byte.a 

tinydns-conf.o: \
tinydns-conf.c strerr.h exit.h auto_home.h generic-conf.h \
buffer.h
	$(CC) $(CFLAGS) -c tinydns-conf.c

tinydns-data: \
tinydns-data.o cdb.a dns.a alloc.a buffer.a unix.a byte.a
	$(CC) $(CFLAGS) -o tinydns-data tinydns-data.o \
	cdb.a dns.a alloc.a buffer.a unix.a \
	byte.a 

tinydns-data.o: \
tinydns-data.c uint16.h uint32.h str.h byte.h fmt.h ip4.h \
exit.h case.h scan.h buffer.h strerr.h getln.h buffer.h stralloc.h \
gen_alloc.h cdb_make.h buffer.h uint32.h stralloc.h open.h dns.h \
stralloc.h iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c tinydns-data.c

tinydns-edit: \
tinydns-edit.o dns.a alloc.a buffer.a unix.a byte.a
	$(CC) $(CFLAGS) -o tinydns-edit tinydns-edit.o \
	dns.a alloc.a buffer.a unix.a byte.a 

tinydns-edit.o: \
tinydns-edit.c stralloc.h gen_alloc.h buffer.h exit.h open.h \
getln.h buffer.h stralloc.h strerr.h scan.h byte.h str.h fmt.h ip4.h \
dns.h stralloc.h iopause.h taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c tinydns-edit.c

tinydns-get: \
tinydns-get.o tdlookup.o response.o printpacket.o printrecord.o \
parsetype.o dns.a libtai.a cdb.a buffer.a alloc.a unix.a byte.a
	$(CC) $(CFLAGS) -o tinydns-get tinydns-get.o \
	tdlookup.o response.o printpacket.o \
	printrecord.o parsetype.o dns.a libtai.a cdb.a buffer.a \
	alloc.a unix.a byte.a 

tinydns-get.o: \
tinydns-get.c str.h byte.h scan.h exit.h stralloc.h \
gen_alloc.h buffer.h strerr.h uint16.h response.h uint32.h case.h \
printpacket.h stralloc.h parsetype.h ip4.h dns.h stralloc.h iopause.h \
taia.h tai.h uint64.h taia.h
	$(CC) $(CFLAGS) -c tinydns-get.c

tinydns.o: \
tinydns.c dns.h stralloc.h gen_alloc.h iopause.h taia.h tai.h \
uint64.h taia.h
	$(CC) $(CFLAGS) -c tinydns.c

uint16_pack.o: \
uint16_pack.c uint16.h
	$(CC) $(CFLAGS) -c uint16_pack.c

uint16_unpack.o: \
uint16_unpack.c uint16.h
	$(CC) $(CFLAGS) -c uint16_unpack.c

uint32.h: \
tryulong32.c uint32.h1 uint32.h2
	( ( $(CC) $(CFLAGS) -c tryulong32.c && $(CC) $(CFLAGS) -o tryulong32 && \
	$(CC) $(CFLAGS) -o tryulong32 ) >/dev/null 2>&1 \
	&& cat uint32.h2 || cat uint32.h1 ) > uint32.h
	rm -f tryulong32.o tryulong32

uint32_pack.o: \
uint32_pack.c uint32.h
	$(CC) $(CFLAGS) -c uint32_pack.c

uint32_unpack.o: \
uint32_unpack.c uint32.h
	$(CC) $(CFLAGS) -c uint32_unpack.c

uint64.h: \
choose tryulong64.c uint64.h1 uint64.h2
	./choose clr tryulong64 uint64.h1 uint64.h2 > uint64.h

unix.a: \
buffer_read.o buffer_write.o error.o error_str.o ndelay_off.o \
ndelay_on.o open_read.o open_trunc.o openreadclose.o readclose.o \
seek_set.o socket_accept.o socket_bind.o socket_conn.o \
socket_listen.o socket_recv.o socket_send.o socket_tcp.o socket_udp.o
	$(AR) unix.a buffer_read.o buffer_write.o error.o \
	error_str.o ndelay_off.o ndelay_on.o open_read.o \
	open_trunc.o openreadclose.o readclose.o seek_set.o \
	socket_accept.o socket_bind.o socket_conn.o socket_listen.o \
	socket_recv.o socket_send.o socket_tcp.o socket_udp.o

utime: \
utime.o byte.a
	$(CC) $(CFLAGS) -o utime  utime.o byte.a 

utime.o: \
utime.c scan.h exit.h
	$(CC) $(CFLAGS) -c utime.c

walldns: \
walldns.o server.o response.o droproot.o qlog.o prot.o dd.o \
dns.a env.a cdb.a alloc.a buffer.a unix.a byte.a socket.lib
	$(CC) $(CFLAGS) -o walldns walldns.o \
	 server.o response.o droproot.o qlog.o \
	prot.o dd.o dns.a env.a cdb.a alloc.a buffer.a unix.a \
	byte.a  `cat socket.lib`

walldns-conf: \
walldns-conf.o generic-conf.o auto_home.o buffer.a unix.a byte.a
	$(CC) $(CFLAGS) -o walldns-conf walldns-conf.o \
	generic-conf.o auto_home.o buffer.a \
	unix.a byte.a 

walldns-conf.o: \
walldns-conf.c strerr.h exit.h auto_home.h generic-conf.h \
buffer.h
	$(CC) $(CFLAGS) -c walldns-conf.c

walldns.o: \
walldns.c byte.h dns.h stralloc.h gen_alloc.h iopause.h \
taia.h tai.h uint64.h taia.h dd.h response.h uint32.h
	$(CC) $(CFLAGS) -c walldns.c
