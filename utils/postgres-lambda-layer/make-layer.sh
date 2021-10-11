#!/bin/bash

set -e

cat >Dockerfile <<EOF
FROM public.ecr.aws/lambda/ruby:2.7
RUN yum install -y unzip postgresql-libs
EOF

rm -rf lib

docker build -t pg-layer-source -f ./Dockerfile .

mkdir lib

docker create -ti --name dummy pg-layer-source bash

docker cp dummy:/usr/lib64/libpq.so.5.5 lib/libpq.so.5
docker cp dummy:/usr/lib64/libldap_r-2.4.so.2.10.7 lib/libldap_r-2.4.so.2
docker cp dummy:/usr/lib64/liblber-2.4.so.2.10.7 lib/liblber-2.4.so.2
docker cp dummy:/usr/lib64/libsasl2.so.3.0.0 lib/libsasl2.so.3
docker cp dummy:/usr/lib64/libssl3.so lib
docker cp dummy:/usr/lib64/libsmime3.so lib
docker cp dummy:/usr/lib64/libnss3.so lib

docker rm -f dummy

zip -r $(date +%Y-%m-%d-%s)-lib-pg-layer.zip lib
