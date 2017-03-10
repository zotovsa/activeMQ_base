#!/usr/bin/env bash

keytool -import -alias root -keystore broker.jks -trustcacerts -file rootCA.crt -storepass 123456
keytool -genkey -alias broker -keyalg RSA -keystore broker.jks -storepass 123456
keytool -certreq -keyalg RSA -alias broker -file broker.csr -keystore broker.jks  -storepass 123456
openssl x509 -req -sha256 -in broker.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out broker.crt -days 5000
keytool -import -alias broker -keystore broker.jks  -file broker.crt -storepass 123456