# ActiveMQ Apollo 1.2.0

##   FROM java:8
FROM centos:centos7

##   MAINTAINER Victor Romero <victor.romero@gmail.com>
MAINTAINER Sergei Zotov <szotov@forsythe.com>

##
# Set labels used in OpenShift to describe the builder images
LABEL io.k8s.description="ActiveMQ Artemis Builder Image." \
      io.k8s.display-name="ActiveMQ Artemis" \
      io.openshift.expose-services="8161:http,61616:all-amq-protocols,5672:amqp" \
      io.openshift.tags="builder,activemq,artemis"

##
# ActiveMQ Artemis
ENV ARTEMIS_VERSION=1.5.3 \
    ARTEMIS_INSTANCE_HOME=/var/lib/artemis

# Java jdk 8
ENV JAVA_VERSION=8u101 \
    BUILD_VERSION=b13


# add user and group for artemis
##RUN groupadd -r artemis && useradd -r -g artemis artemis
RUN groupadd -g 1001 -r artemis && useradd -u 1000 -r -g artemis -d ${ARTEMIS_INSTANCE_HOME} artemis

##
# Upgrading system, download java
RUN yum -y upgrade && yum -y install \
    curl  \
    tar  \
    wget && yum clean all -y


RUN yum install -y libaio && \
    wget "http://dl.fedoraproject.org/pub/epel/7/x86_64/x/xmlstarlet-1.6.1-1.el7.x86_64.rpm" -O /tmp/xmlstartlet.rpm && \
    yum install -y /tmp/xmlstartlet.rpm && \
    yum clean all -y



RUN wget -nv --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$BUILD_VERSION/jdk-$JAVA_VERSION-linux-x64.rpm" -O /tmp/jdk-8-linux-x64.rpm

RUN yum -y install /tmp/jdk-8-linux-x64.rpm && \
    yum clean all -y

RUN alternatives --install /usr/bin/java   jar /usr/java/latest/bin/java 200000 && \
    alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 200000 && \
    alternatives --install /usr/bin/javac  javac /usr/java/latest/bin/javac 200000


ENV JAVA_HOME=/usr/java/latest \
    PATH=$JAVA_HOME/bin:$PATH






##RUN apt-get -qq -o=Dpkg::Use-Pty=0 update && \
##    apt-get -qq -o=Dpkg::Use-Pty=0 upgrade -y && \
##    apt-get -qq -o=Dpkg::Use-Pty=0 install -y --no-install-recommends libaio1 xmlstarlet && \
##    rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root
##RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
##RUN apt-get -qq -o=Dpkg::Use-Pty=0 update && \
##    apt-get -qq install -y --no-install-recommends ca-certificates wget && \
##    rm -rf /var/lib/apt/lists/* && \
##    wget -q -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" && \
##    wget -q -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" && \
##    gpg --verify /usr/local/bin/gosu.asc && \
##    rm /usr/local/bin/gosu.asc && \
##    chmod +x /usr/local/bin/gosu

# Setup gosu for easier command execution
RUN gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64" && \
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64.asc" && \
    gpg --verify /usr/local/bin/gosu.asc && \
    rm /usr/local/bin/gosu.asc && \
    rm -r /root/.gnupg/ && \
    chmod +x /usr/local/bin/gosu




# Uncompress and validate
##RUN cd /opt && wget -q http://www-us.apache.org/dist/activemq/activemq-artemis/1.5.3/apache-artemis-1.5.3-bin.tar.gz && \
##  wget -q http://www.us.apache.org/dist/activemq/activemq-artemis/1.5.3/apache-artemis-1.5.3-bin.tar.gz.asc && \
##  wget -q http://apache.org/dist/activemq/KEYS && \
##  gpg --import KEYS && \
##  gpg apache-artemis-1.5.3-bin.tar.gz.asc && \
##  tar xfz apache-artemis-1.5.3-bin.tar.gz && \
##  ln -s apache-artemis-1.5.3 apache-artemis && \
##  rm -f apache-artemis-1.5.3-bin.tar.gz KEYS apache-artemis-1.5.3-bin.tar.gz.asc



# Uncompress and validate
RUN cd /opt && \
    wget -nv -q http://www-us.apache.org/dist/activemq/activemq-artemis/$ARTEMIS_VERSION/apache-artemis-$ARTEMIS_VERSION-bin.tar.gz && \
    tar xfz apache-artemis-$ARTEMIS_VERSION-bin.tar.gz && \
    ln -s apache-artemis-$ARTEMIS_VERSION apache-artemis && \
    rm -f apache-artemis-$ARTEMIS_VERSION-bin.tar.gz


# Create broker instance
RUN cd /var/lib && \
  /opt/apache-artemis-$ARTEMIS_VERSION/bin/artemis create artemis \
    --home /opt/apache-artemis \
    --user artemis \
    --password artemis \
    --role admin \
    --allow-anonymous

# Ports are only exposed with an explicit argument, there is no need to binding
# the web console to localhost
RUN cd ${ARTEMIS_INSTANCE_HOME}/etc && \
  xmlstarlet ed -L -N amq="http://activemq.org/schema" \
    -u "/amq:broker/amq:web/@bind" \
    -v "http://0.0.0.0:8161" bootstrap.xml

RUN chown -R artemis.artemis ${ARTEMIS_INSTANCE_HOME}

### !!!!! SHOULD WE USE NEXT??????
RUN chmod -R a+w ${ARTEMIS_INSTANCE_HOME}/data && chmod -R a+w ${ARTEMIS_INSTANCE_HOME}/tmp 



# Web Server
EXPOSE 8161

# Port for CORE,MQTT,AMQP,HORNETQ,STOMP,OPENWIRE
EXPOSE 61616

# Port for HORNETQ,STOMP
EXPOSE 5445

# Port for AMQP
EXPOSE 5672

# Port for MQTT
EXPOSE 1883

#Port for STOMP
EXPOSE 61613

# Port for JGroups channels
EXPOSE 7080 7081







# Expose some outstanding folders
VOLUME ["/var/lib/artemis/data"]
VOLUME ["/var/lib/artemis/tmp"]
VOLUME ["/var/lib/artemis/etc"]

WORKDIR /var/lib/artemis/bin

COPY docker-entrypoint.sh /

COPY common-0.9.0.jar /opt/$ARTEMIS_VERSION/lib
COPY dns-0.9.0.jar /opt/$ARTEMIS_VERSION/lib
COPY broker.xml ${ARTEMIS_INSTANCE_HOME}/etc
#COPY broker-no-ssl.xml ${ARTEMIS_INSTANCE_HOME}/etc/broker.xml

COPY jgroups.xml ${ARTEMIS_INSTANCE_HOME}c
COPY logging.properties ${ARTEMIS_INSTANCE_HOME}/etc
COPY broker.jks ${ARTEMIS_INSTANCE_HOME}/etc

RUN chmod a+x /docker-entrypoint.sh \
    chgrp 0 /docker-entrypoint.sh 

RUN chgrp -R 0 ${ARTEMIS_INSTANCE_HOME} \
  && chmod -R g+rwX ${ARTEMIS_INSTANCE_HOME}

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["artemis-server"]





