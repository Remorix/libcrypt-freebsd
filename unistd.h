#ifndef _LIBCRYPT_UNISTD_H
#define _LIBCRYPT_UNISTD_H

/* In FreeBSD, libcrypt prototypes are provided by unistd.h */

#include_next <unistd.h>
#include <sys/cdefs.h>

/* This is for avoid conflicting with Darwin shipped crypt() */
#ifndef __FBSD_ALIAS
#define __FBSD_ALIAS(sym)  __asm("_" __STRING(sym) "$FreeBSD")
#endif

struct crypt_data {
	int	initialized;	/* For compatibility with glibc. */
	char	__buf[256];	/* Buffer returned by crypt_r(). */
};

__BEGIN_DECLS

const char *
	 crypt_get_format(void);
char	*crypt_r(const char *, const char *, struct crypt_data *);
int	 crypt_set_format(const char *);
char	*crypt(const char *, const char *) __FBSD_ALIAS(crypt);

__END_DECLS

#endif
