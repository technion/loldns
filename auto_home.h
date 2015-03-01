#ifndef AUTO_HOME_H
#define AUTO_HOME_H

extern const char auto_home[];
extern void h(const char *home,int uid,int gid,int mode);
extern void c(const char *home,char *subdir,char* file,int uid,int gid,int mode);
extern void d(const char *home,char* subdir,int uid,int gid,int mode);

#endif
