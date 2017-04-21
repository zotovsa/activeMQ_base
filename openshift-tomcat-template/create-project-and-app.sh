#oc new-project test4
oc create -f ./hawtio.yml
oc new-app --template=tomcat-hawtio
