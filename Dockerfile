FROM debian:9

LABEL maintainer="andrei.cenja@eea.europa.eu"

RUN apt-get update && \
        apt-get upgrade && \
        apt-get dist-upgrade && \
        apt-get -y install --no-install-recommends apt-utils && \
        apt-get -y install --no-install-recommends build-essential cmake bison flex libpcap-dev pkg-config libglib2.0-dev libgpgme11-dev uuid-dev sqlfairy xmltoman doxygen libssh-dev libksba-dev libldap2-dev libsqlite3-dev libmicrohttpd-dev libxml2-dev libxslt1-dev xsltproc clang rsync rpm nsis alien sqlite3 libhiredis-dev libgcrypt11-dev libgnutls28-dev redis-server texlive-latex-base texlive-latex-recommended linux-libc-dev python python-pip mingw-w64 heimdal-multidev libpopt-dev libglib2.0-dev gnutls-bin certbot nmap ufw postgresql-9.6 postgresql-client-9.6 libpq-dev postgresql-server-dev-9.6 postgresql-contrib-9.6 libsnmp-base snmp haveged msmtp-mta wget libcgi-pm-perl dirmngr libssh2-1-dev && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*


COPY startd update /usr/sbin/

RUN  mkdir /opt/openvas && cd /usr/local/src && wget https://github.com/greenbone/gvm-libs/releases/download/v9.0.3/openvas-libraries-9.0.3.tar.gz && wget https://github.com/greenbone/openvas-scanner/archive/v5.1.3.tar.gz && wget https://github.com/greenbone/gvm/releases/download/v7.0.3/openvas-manager-7.0.3.tar.gz && wget https://github.com/greenbone/gsa/archive/v7.0.3.tar.gz && \
	cd /usr/local/src && for i in $(ls *.tar.gz); do tar zxvf $i; done && \
	export PKG_CONFIG_PATH=/opt/openvas/lib/pkgconfig:$PKG_CONFIG_PATH && cd /usr/local/src/gvm-libs-9.0.3/ && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/opt/openvas .. && make && make install && \
	cd /usr/local/src/gvm-7.0.3/ && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/opt/openvas -DBACKEND=POSTGRESQL .. && make && make install && \
	cd /usr/local/src/openvas-scanner-5.1.3/ && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/opt/openvas .. && make && make install && \
	cd /usr/local/src/gsa-7.0.3/ && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/opt/openvas .. && make && make install && \
	sed -i 's|port 6379|port 0|' /etc/redis/redis.conf && \
	sed -i 's|^\# unixsocket\ \/var\/run\/redis\/redis\.sock|unixsocket\ \/tmp\/redis\.sock|' /etc/redis/redis.conf && \
	sed -i 's|^# unixsocketperm |unixsocketperm |' /etc/redis/redis.conf && \
	echo  -e "/usr/local/lib/openvasmd/pg \n/opt/openvas/lib" > /etc/ld.so.conf.d/openvas-manager.conf && \
	ldconfig && \
	rm -rf /usr/local/src/gvm-libs-9.0.3/  && \
	rm -rf /usr/local/src/gvm-7.0.3/ && \
	rm -rf /usr/local/src/openvas-scanner-5.1.3/ && \
	rm -rf /usr/local/src/gsa-7.0.3/ && \
	apt-get remove -y cmake build-essential pkg-config libpcap-dev libglib2.0-dev libgpgme11-dev uuid-dev libssh-dev libksba-dev libldap2-dev libsqlite3-dev libmicrohttpd-dev libxml2-dev libxslt1-dev \
		libhiredis-dev libgcrypt11-dev libgnutls28-dev linux-libc-dev libpopt-dev libglib2.0-dev libpq-dev postgresql-server-dev-9.6 autoconf automake autotools-dev autopoint cmake-data cpio dpkg-dev \
		libp11-kit-dev make patch libassuan-dev libgmp-dev libgpg-error-dev libobjc-6-dev nettle-dev && \
	chmod +x /usr/sbin/startd /usr/sbin/update && \
	cp /usr/share/doc/msmtp/examples/msmtprc-system.example /etc/msmtprc &&\
	sed -i '/^#auto_from on.*/s/^#//' /etc/msmtprc
		

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
 && gpg --verify /tini.asc && \
	chmod +x /tini
ENTRYPOINT ["/tini", "--"]

CMD ["/usr/sbin/startd"]
