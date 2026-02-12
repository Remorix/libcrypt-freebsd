#ifndef _LIBCRYPT_UNISTD_H
#define _LIBCRYPT_UNISTD_H

/* In FreeBSD, libcrypt prototypes are provided by unistd.h */

#include_next <unistd.h>

struct crypt_data {
	int	initialized;	/* For compatibility with glibc. */
	char	__buf[256];	/* Buffer returned by crypt_r(). */
};

__BEGIN_DECLS

const char *
	 crypt_get_format(void);
char	*crypt_r(const char *, const char *, struct crypt_data *);
int	 crypt_set_format(const char *);

__END_DECLS

#endif
