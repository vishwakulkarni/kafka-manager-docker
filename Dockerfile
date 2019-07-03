FROM debian:stretch-slim

ENV LANG C.UTF-8
ARG VERSION
ENV DEBIAN_FRONTEND noninteractive

#installing opnjjdk 8 because kafka-manager needs java.

RUN apt-get update && mkdir -p /usr/share/man/man1/ \
  && apt-get install --no-install-recommends -y openjdk-8-jdk-headless unzip\
  && apt-get clean && rm -rf /var/lib/apt/lists/*

#add jq for modifying json and setting zknodes
RUN apt-get update
RUN apt-get install jq --assume-yes

#this is a dummy vcapservices wont work unless you bind kafka instance and restage
ENV VCAP_SERVICES='{"kafka":[{"label":"kafka","provider":null,"plan":"dedicated","name":"test_kafka","tags":["kafka"],"instance_name":"test_kafka","binding_name":null,"credentials":{"username":"username","password":"password","urls":{"ca_cert":"https://kafka-service-broker.cf.sap.hana.ondemand.com/certs/rootCA.crt","token":"https://kafka-service-oauth.cf.sap.hana.ondemand.com/v1/39976793-dd2d-411a-bdf8-5504188dd84b/token","token_key":"https://kafka-service-oauth.cf.sap.hana.ondemand.com/v1/token_key","service":"https://kafka-service.cf.sap.hana.ondemand.com/v1/39976793-dd2d-411a-bdf8-5504188dd84b"},"cluster":{"zk":"localhost:2181","brokers":"10.254.20.21:9093,10.254.20.22:9093,10.254.20.23:9093","brokers.auth_ssl":"10.254.20.21:9093,10.254.20.22:9093,10.254.20.23:9093"},"tenant":"39976793-dd2d-411a-bdf8-5504188dd84b"},"syslog_drain_url":null,"volume_mounts":[]}]}'
#RUN ZK_HOSTS=$(echo $VCAP_SERVICES | jq '.cluster.zk')

RUN mkdir /app
COPY kafka-manager-$VERSION.zip /tmp
RUN unzip -d /tmp /tmp/kafka-manager-$VERSION.zip && mv /tmp/kafka-manager-$VERSION/* /app/ \
 && rm -rf /tmp/kafka-manager* && rm -rf /app/share/doc
ADD entrypoint.sh /app/
ADD application.conf /app/conf/
ADD logback.xml /app/conf/

WORKDIR /app

EXPOSE 9000
ENTRYPOINT ["./entrypoint.sh"]
