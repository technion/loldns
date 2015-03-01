/* API for daemon management apps */

void runapp(const char *app, const char *logapp, const char *infile);
void setenvironment(); /* Replacement for envdir */
void gobackground();
