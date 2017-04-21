FROM tomcat:alpine


COPY hawtio-default-1.5.0.war /usr/local/tomcat/webapps/hawtio.war

RUN  chgrp -R 0  /usr/local/tomcat/
RUN  chmod -R g+rwX /usr/local/tomcat/