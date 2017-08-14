FROM sonatype/nexus3
MAINTAINER Don Corley [dcorley@usc.edu]
LABEL name="Nexus repo with ssl for USC" \
    vendor="USC" \
    license="GPLv2" \
    build-date="2016-10-17"

# Dockerfile for Nexus repo
# Usage:
# After startup, set base URL in config screen and set https port for docker uploads (8444)
# docker secret create keystore.jks keystore.jks
# docker service create --name nexus --replicas 1 --update-delay 10s --network web-bus -p 8081:8081 -p 8443:8443 --mount type=bind,source=$USC_LOCAL_DIR/nexus,target=/nexus-data --secret keystore.jks -e INSTALL4J_ADD_VM_PARAMS=-DJETTY_PASSWORD=OBF:1v2j1uum1xtv1zej1zer1xtn1uvk1v1v --constraint node.hostname==$STATIC_HOST sonatype/nexus3
# Note: ports 8081 = web server, 8442 = Anonymous registry (thru ssl proxy), 8443 = ssl registry, 8444 = unused required port, 8445 = registry (thru ssl proxy)

USER root
# COPY etc/ssl etc/ssl
# RUN chown 0 etc/ssl && chgrp 0 etc/ssl && chmod 755 etc/ssl && chown 0 etc/ssl/keystore.jks \
# && chgrp 0 etc/ssl/keystore.jks && chmod 644 etc/ssl/keystore.jks
RUN sed -i \
's/jetty-requestlog.xml/jetty-requestlog.xml,$\{jetty.etc\}\/jetty-https.xml\napplication-port-ssl=8444\n/' \
etc/nexus-default.properties
# Note: I use 8444 just to spin up a port. The actual port will be 8443
# RUN sed -i \
# 's/Password\">OBF:1v2j1uum1xtv1zej1zer1xtn1uvk1v1v<\/Set>/Password\"><SystemProperty name=\"JETTY_PASSWORD\" default=\"OBF:1v2j1uum1xtv1zej1zer1xtn1uvk1v1v\"\/><\/Set>/' \
# etc/jetty/jetty-https.xml
# Actual password should be passed in as follows:
RUN sed -i \
's/Password\">password<\/Set>/Password\"><SystemProperty name=\"JETTY_PASSWORD\" default=\"OBF:1v2j1uum1xtv1zej1zer1xtn1uvk1v1v\"\/><\/Set>/' \
etc/jetty/jetty-https.xml
RUN sed -i \
's/<Property name=\"ssl.etc\"\/>\/keystore.jks/\/run\/secrets\/keystore.jks/' \
etc/jetty/jetty-https.xml
# Disallow insecure TLS protocols
RUN sed -i \
's/<Set name="ExcludeCipherSuites">/\
<Set name=\"ExcludeProtocols\">\n\
\t\t<Array type=\"java.lang.String\">\n\
\t\t\t<Item>SSL<\/Item>\n\
\t\t\t<Item>SSLv2<\/Item>\n\
\t\t\t<Item>SSLv2Hello<\/Item>\n\
\t\t\t<Item>SSLv3<\/Item>\n\
\t\t\t<Item>TLSv1<\/Item>\n\
\t\t\t<Item>TLSv1.1<\/Item>\n\
\t\t<Item>TLSv1.2<\/Item>\n\
\t<\/Array>\n<\/Set>\n\
\t<Set name="ExcludeCipherSuites">/' \
etc/jetty/jetty-https.xml
USER nexus

# For systemd usage this changes to /usr/sbin/init
CMD ["bin/nexus", "run"]
