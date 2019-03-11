FROM alpine:latest

ARG SQUID_MAJOR_VERSION=4
ARG SQUID_MENOR_VERSION=6
ARG SQUID_VERSION=${SQUID_MAJOR_VERSION}.${SQUID_MENOR_VERSION}

LABEL maintainer="Ernesto Pérez <ernesto.perez@euigs.com>" \
  org.label-schema.name="Squid" \
  org.label-schema.description="Squid docker image based on Alpine Linux." \
  org.label-schema.vcs-url="https://github.com/a-eperez/docker-squid" \
  org.label-schema.schema-version="1.0"

RUN set -ex && \
    apk add --update --no-cache \
    alpine-sdk \
    bash \
    curl \
    file \
    heimdal \
    heimdal-dev \
    libcap \
    libcap-dev \
    libdbi-drivers \
    libldap \
    libressl \
    libressl-dev \
    libtool \
    linux-pam \
    linux-pam-dev \
    openldap-dev \
    perl \
    perl-dbi \
    samba \
    samba-winbind-clients \
    curl

RUN mkdir -p /usr/src && \
    curl -LSs \
    http://www.squid-cache.org/Versions/v${SQUID_MAJOR_VERSION}/squid-${SQUID_VERSION}.tar.gz | tar \
    -xzv -C /usr/src

RUN cd /usr/src/squid* && \
    ./configure \
    --prefix=/usr \
    --datadir=/usr/share/squid \
    --sysconfdir=/etc/squid \
    --libexecdir=/usr/lib/squid \
    --localstatedir=/var \
    --with-logdir=/var/log/squid \
    --disable-strict-error-checking \
    --disable-arch-native \
    --enable-removal-policies="lru,heap" \
    --enable-auth-basic="getpwnam,DB,LDAP,NCSA,PAM,POP3,RADIUS,SASL,SMB,SMB_LM" \
    --enable-auth-digest="LDAP" \
    --enable-auth-negotiate="kerberos" \
    --enable-log-daemon-helpers="DB,file" \
    --enable-epoll \
    --disable-mit \
    --enable-heimdal \
    --enable-delay-pools \
    --enable-arp-acl \
    --enable-openssl \
    --enable-ssl-crtd \
    --enable-linux-netfilter \
    --enable-ident-lookups \
    --enable-useragent-log \
    --enable-cache-digests \
    --enable-referer-log \
    --enable-async-io \
    --enable-truncate \
    --enable-arp-acl \
    --enable-htcp \
    --enable-carp \
    --enable-poll \
    --enable-follow-x-forwarded-for \
    --with-large-files \
    --with-default-user=squid \
    --with-openssl && \
    make all && \
    make install

RUN apk del \
    alpine-sdk \
    heimdal-dev \
    libcap-dev \
    libressl-dev \
    linux-pam-dev \
    openldap-dev

COPY root /

VOLUME /var/cache/squid /var/logs/squid

EXPOSE 3128/tcp

HEALTHCHECK --interval=1m --timeout=3s \
  CMD squidclient -h localhost cache_object://localhost/counters || exit 1

ENTRYPOINT ["/usr/sbin/entry-point.sh"]
CMD ["/usr/sbin/squid", "-f /etc/squid/squid.conf", "-NYCd", "1"]
