#include "auto_home.h"

void hier()
{

  h(auto_home,-1,-1,02755);
  d(auto_home,"bin",-1,-1,02755);

  c(auto_home,"bin","dnscache-conf",-1,-1,0755);
  c(auto_home,"bin","tinydns-conf",-1,-1,0755);

  /* New apps by Josh */

  c(auto_home,"bin","startcache",-1,-1,0755);
  c(auto_home,"bin","starttiny",-1,-1,0755);
  c(auto_home,"bin","loglol",-1,-1,0755);
  


  c(auto_home,"bin","dnscache",-1,-1,0755);
  c(auto_home,"bin","tinydns",-1,-1,0755);

  c(auto_home,"bin","tinydns-get",-1,-1,0755);
  c(auto_home,"bin","tinydns-data",-1,-1,0755);
  c(auto_home,"bin","tinydns-edit",-1,-1,0755);
  c(auto_home,"bin","axfr-get",-1,-1,0755);

}
