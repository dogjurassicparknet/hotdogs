FROM postgres:16

ADD /init/0-cloud-bootstrap.sh /docker-entrypoint-initdb.d/.
ADD /init/1-seed.sh /docker-entrypoint-initdb.d/.
