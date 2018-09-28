# [eeacms/openvas-pg-debian](https://hub.docker.com/r/eeacms/openvas-pg-debian/)

Docker image for OpenVAS - based on [mattias-ohlsson/openvas](https://hub.docker.com/r/mattiasohlsson/openvas/)

## Run

- Username: admin
- Password: admin

> https://hostname/

Examples of accepted environment variables:

gsad:

GSAD_HOST="--allow-header-host 127.0.0.1" 

GSAD_LISTEN="--listen=127.0.0.1"

GSAD_HTTP_ONLY="--http-only"

GSAD_PORT="--port=443"

GSAD_REDIRECTPORT="--rport=80"

GSAD_MLISTEN="--mlisten=127.0.0.1"

GSAD_MPORT="--mport=9390"

GSAD_KEY="--ssl-private-key=/etc/pki/openvas/private/CA/serverkey.pem"

GSAD_CERT="--ssl-certificate=/etc/pki/openvas/CA/servercert.pem"

TLS_PRIORITIES="--gnutls-priorities=SECURE128:-AES-128-CBC:-CAMELLIA-128-CBC:-VERS-SSL3.0:-VERS-TLS1.0"

manager:

OPENVASMD_LISTEN="--listen=127.0.0.1"

OPENVASMD_PORT="--port=9390"

other:

SMTP_SERVER="smtp.example.com"


### Create a new OpenVAS container

    docker create --network=host --name=openvas eeacms/openvas-pg-debian

### Start your container

    docker start openvas

### Update feed

    docker exec openvas update

#### View logs

    docker logs --follow openvas
