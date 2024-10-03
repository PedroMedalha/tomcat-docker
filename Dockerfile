# Oracle Linux 9 base image
FROM oraclelinux:9

# Environment variables
ENV TOMCAT_VERSION=10.1.28
ENV CATALINA_HOME=/usr/share/tomcat
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk

# Install Java
RUN yum install -y \
    java-21-openjdk-devel \
    curl \
    openssl \
    && yum clean all

# Download and installation Tomcat
RUN curl -O https://archive.apache.org/dist/tomcat/tomcat-10/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz \
    && tar -xzf apache-tomcat-$TOMCAT_VERSION.tar.gz -C /usr/share/ \
    && mv /usr/share/apache-tomcat-$TOMCAT_VERSION $CATALINA_HOME \
    && rm apache-tomcat-$TOMCAT_VERSION.tar.gz

# Copy the PrKey and Public certificate to the container
COPY ca-key.pem /usr/share/tomcat/conf/
COPY ca-cert.pem /usr/share/tomcat/conf/

# Generate keystore.p12 from CA certificate and PrKey
RUN openssl pkcs12 -export -in /usr/share/tomcat/conf/ca-cert.pem -inkey /usr/share/tomcat/conf/ca-key.pem -out /usr/share/tomcat/conf/keystore.p12 -name tomcat -passout pass:XpandIT

# convert PKCS12 para JKS
RUN keytool -importkeystore -deststorepass XpandIT -destkeypass XpandIT -destkeystore /usr/share/tomcat/conf/keystore.jks -srckeystore /usr/share/tomcat/conf/keystore.p12 -srcstoretype PKCS12 -srcstorepass XpandIT -alias tomcat

# Edit the server.xml file to add SSL connector
RUN sed -i '/<\/Service>/i \
<Connector port="4041" protocol="org.apache.coyote.http11.Http11NioProtocol" \
    maxThreads="150" SSLEnabled="true" scheme="https" secure="true" \
    clientAuth="false" sslProtocol="TLS"> \
    <SSLHostConfig> \
        <Certificate certificateKeystoreFile="${catalina.base}/conf/keystore.jks" \
                     certificateKeystorePassword="XpandIT" \
                     type="RSA" /> \
    </SSLHostConfig> \
</Connector>' \
$CATALINA_HOME/conf/server.xml

    # Expose port 4041 for SSL
EXPOSE 4041

# Start Tomcat
CMD ["sh", "-c", "$CATALINA_HOME/bin/catalina.sh run"]
