LIB=		crypt-fbsd
SHLIB_MAJOR?=	5

PREFIX?=	/usr/local
DESTDIR?=
LIBDIR?=	${PREFIX}/lib
INCLUDEDIR?=	${PREFIX}/include
DOCDIR?=	${PREFIX}/share/doc/libcrypt-freebsd
MANDIR?=	${PREFIX}/share/man

MAN?=		crypt.3
MLINKS?=	${MAN} crypt_get_format.3 \
		${MAN} crypt_r.3 \
		${MAN} crypt_set_format.3

CC?=		cc
AR?=		ar
INSTALL?=	install
LN?=		ln
RM?=		rm -f

MK_SHARED?=	yes

CPPFLAGS+=	-I${.CURDIR}
CFLAGS?=	-O2
CFLAGS+=	-fPIC -DHAS_DES -DHAS_BLOWFISH
LDFLAGS?=
LDADD?=		-lmd

UNAME_S!=	uname -s
.if ${UNAME_S} == "Darwin"
SHLIB_LINK=	lib${LIB}.${SHLIB_MAJOR}.dylib
SHLIB=		lib${LIB}.dylib
SHLIB_LDFLAGS=	-dynamiclib \
		-Wl,-install_name,${LIBDIR}/${SHLIB_LINK} \
		-Wl,-compatibility_version,${SHLIB_MAJOR} \
		-Wl,-current_version,${SHLIB_MAJOR}
.else
SHLIB_LINK=	lib${LIB}.so
SHLIB=		lib${LIB}.so.${SHLIB_MAJOR}
SHLIB_LDFLAGS=	-shared -Wl,-soname,${SHLIB}
.endif

SRCS=		crypt.c misc.c \
		crypt-md5.c crypt-nthash.c \
		crypt-sha256.c crypt-sha512.c \
		crypt-des.c crypt-blowfish.c blowfish.c
OBJS=		${SRCS:.c=.o}

ALL_TARGETS=	lib${LIB}.a
.if ${MK_SHARED:tl} != "no"
ALL_TARGETS+=	${SHLIB} ${SHLIB_LINK}
.endif

.PHONY: all clean install install-lib install-headers install-man

all: ${ALL_TARGETS}

.c.o:
	${CC} ${CPPFLAGS} ${CFLAGS} -c ${.IMPSRC} -o ${.TARGET}

lib${LIB}.a: ${OBJS}
	${AR} rcs ${.TARGET} ${.ALLSRC}

.if ${MK_SHARED:tl} != "no"
${SHLIB}: ${OBJS}
	${CC} ${SHLIB_LDFLAGS} ${LDFLAGS} -o ${.TARGET} ${.ALLSRC} ${LDADD}

${SHLIB_LINK}: ${SHLIB}
	${LN} -sf ${SHLIB:T} ${.TARGET}
.endif

install: install-lib install-headers install-man

install-lib: all
	${INSTALL} -d ${DESTDIR}${LIBDIR}
	${INSTALL} -m 644 lib${LIB}.a ${DESTDIR}${LIBDIR}/lib${LIB}.a
.if ${MK_SHARED:tl} != "no"
	${INSTALL} -m 755 ${SHLIB} ${DESTDIR}${LIBDIR}/${SHLIB}
	${LN} -sf ${SHLIB:T} ${DESTDIR}${LIBDIR}/${SHLIB_LINK}
.endif

install-headers:
	${INSTALL} -d ${DESTDIR}${INCLUDEDIR}
	${INSTALL} -m 644 unistd.h ${DESTDIR}${INCLUDEDIR}/unistd.h
	${INSTALL} -d ${DESTDIR}${DOCDIR}
	${INSTALL} -m 644 crypt.h ${DESTDIR}${DOCDIR}/crypt.h
	${INSTALL} -m 644 blowfish.h ${DESTDIR}${DOCDIR}/blowfish.h

install-man:
	${INSTALL} -d ${DESTDIR}${MANDIR}/man3
	${INSTALL} -m 644 ${MAN} ${DESTDIR}${MANDIR}/man3/${MAN}
.for _src _dst in ${MLINKS}
	${LN} -sf ${_src} ${DESTDIR}${MANDIR}/man3/${_dst}
.endfor

clean:
	${RM} ${OBJS} lib${LIB}.a ${SHLIB} ${SHLIB_LINK}
