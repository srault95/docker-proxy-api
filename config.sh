#!/bin/bash

TARGET=/etc/nginx/certs

if [ -e ${TARGET}/server.key ]; then
    if [ -z "${FORCE_CONFIG}" ]; then
		echo "Already configured. normal exit"
        exit 0
    else
        rm -f ${TARGET}/server.key
        rm -f ${TARGET}/server.crt
    fi
fi

echo "SSL certificate generation..."

openssl genrsa -out ${TARGET}/server.key 1024 2>/dev/null 1>&2
    
openssl req -new -newkey rsa:${SSL_RSA_BIT:-4096} -days ${SSL_DAYS:-365} -nodes -subj "/C=/ST=/L=/O=/CN=${SSL_COMMON_NAME:-localhost}" -keyout ${TARGET}/server.key -out ${TARGET}/server.csr 2>/dev/null 1>&2

openssl x509 -req -days ${SSL_DAYS:-365} -in ${TARGET}/server.csr -signkey ${TARGET}/server.key -out ${TARGET}/server.crt 2>/dev/null 1>&2

rm -f ${TARGET}/server.csr

chown root:root ${TARGET}/server.*
chmod 0400 ${TARGET}/server.*

echo "Password generation..."

printf "${DOCKER_USER:-docker}:$(openssl passwd -crypt ${DOCKER_PASSWORD:-docker})\n" > /etc/nginx/.passwd

echo "End configuration."
