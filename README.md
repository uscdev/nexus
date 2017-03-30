# nexus
Nexus plus ssl cert handling

This upgrades the standard nexus to use SSL (for Docker Trusted Registry)

docker service create --name nexus --replicas 1 --update-delay 10s \
--network web-bus -p 8081:8081 -p 8443:8443 \
--mount type=bind,source=$USC_LOCAL_DIR/nexus,target=/nexus-data \
--secret keystore.jks \
-e INSTALL4J_ADD_VM_PARAMS=-DJETTY_PASSWORD=OBF:1v2j1uum1xtv1zej1zer1xtn1uvk1v1v \
--constraint node.hostname==$STATIC_HOST sonatype/nexus3

Prerequisites:
1. Place SSL certs in keystore.jks
2. Obfuscate password for command line (see jetty documentation)
3. Place keystore in runtime secrets

Note: Typically you can use the standard sonatype/nexus3. This version gives you ssl, which allows you to
deploy and pull from the registry if the nginx reverse proxy is down.

To build:
docker build -t uscits/nexus .
docker push uscits/nexus
