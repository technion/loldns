#include <sys/time.h>
#include <stdint.h>
#include <unistd.h>

extern char seed[128];

static void teaencrypt(uint32_t *v, uint32_t *k);

void jsextrarandom(char *seed)
{
	struct timeval tv;
	char newseed[128];
	int merge;
	int i;


	/* Not cryptographically secure. But random enough when used as a key
	 * to imrpove existing randomness */

	for(i=0; i<1024; i++)
	{
		gettimeofday(&tv, NULL);
		merge = tv.tv_usec%256;
		newseed[i%128] ^= merge;
	}

	teaencrypt((uint32_t*)seed, (uint32_t*)newseed);
	seed += 64; /* TEA is only 8 byte block size */
	teaencrypt((uint32_t*)seed, (uint32_t*)newseed);
}
static void teaencrypt(uint32_t *v, uint32_t *k)
{
	/* This is public domain code, TEA */
	
    uint32_t v0=v[0], v1=v[1], sum=0, i;           /* set up */
    uint32_t delta=0x9e3779b9;                     /* a key schedule constant */
    uint32_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
    for (i=0; i < 32; i++) {                       /* basic cycle start */
        sum += delta;
        v0 += ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        v1 += ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);  
    }                                              /* end cycle */
    v[0]=v0; v[1]=v1;
}

