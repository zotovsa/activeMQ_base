#!/usr/bin/env bash
DONAME_NAME=artemis-cluster


rm broker.jks
keytool -genkey -alias broker -keyalg RSA -validity 500 -keypass 123456 -storepass 123456 -dname "CN=$DONAME_NAME, OU=Engineering, O=NM, L=Milwaukee S=Winsconsin C=US" -keystore broker.jks
keytool -import -alias root -keystore broker.jks -trustcacerts -file rootCA.crt -storepass 123456 -noprompt
keytool -certreq -keyalg RSA -alias broker -file broker.csr -keystore broker.jks  -storepass 123456
openssl x509 -req -sha256 -in broker.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out broker.crt -days 5000
keytool -import -alias broker -keystore broker.jks  -file broker.crt -storepass 123456