#!/bin/sh

set -e

CHOWN=$(/usr/bin/which chown)
SQUID=$(/usr/bin/which squid)

prepare_folders() {
	echo "Preparing folders..."
	"$CHOWN" -R squid:squid /var/cache/squid
	"$CHOWN" -R squid:squid /var/log/squid
}

initialize_cache() {
	echo "Creating cache folder..."
	"$SQUID" -z

	sleep 7
}

create_cert() {
	if [ ! -f /etc/squid-cert/private.pem ]; then
		echo "Creating certificate..."
		openssl req -new -newkey rsa:2048 -sha256 -days 3650 -nodes -x509 \
			-extensions v3_ca -keyout /etc/squid-cert/private.pem \
			-out /etc/squid-cert/private.pem \
			-subj "/CN=$CN/O=$O/OU=$OU/C=$C" -utf8 -nameopt multiline,utf8

		openssl x509 -in /etc/squid-cert/private.pem \
			-outform DER -out /etc/squid-cert/CA.der
	else
		echo "Certificate found..."
	fi
}

clear_certs_db() {
  echo "Clearing generated certificate db..."
	rm -rfv /var/lib/ssl_db/
	/usr/lib/squid/ssl_crtd -c -s /var/lib/ssl_db
	"$CHOWN" -R squid.squid /var/lib/ssl_db
}

run() {
	echo "Starting squid..."
	if [ $SSL_BUMP == "1" ]; then
		mkdir -p /etc/squid-cert/
		"$CHOWN" -R squid:squid /etc/squid-cert/
		create_cert
    clear_certs_db
		exec "$SQUID" -NYCd 1 -f /etc/squid/squid-sslbump.conf
	else
		exec "$SQUID" -NYCd 1 -f /etc/squid/squid.conf
	fi
}

prepare_folders
initialize_cache
run