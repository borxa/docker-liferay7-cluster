FROM openjdk:8-alpine

MAINTAINER Borxa Varela Bouzas <borxa@varelabouzas.net>

RUN apk add --no-cache curl p7zip

RUN addgroup -g 1001 liferay && \
    adduser -D -u 1002 -G liferay liferay

ENV LIFERAY_HOME=/usr/local/liferay-ce-portal-7.2.0-ga1
ENV LIFERAY_TOMCAT_URL=https://sourceforge.net/projects/lportal/files/Liferay%20Portal/7.2.0%20GA1/liferay-ce-portal-tomcat-7.2.0-ga1-20190531153709761.7z/download

WORKDIR /usr/local

# Install Liferay
RUN curl -fSL "$LIFERAY_TOMCAT_URL" -o liferay-ce-portal-tomcat-7.2.0-ga1.7z \
      && 7za x liferay-ce-portal-tomcat-7.2.0-ga1.7z -y \
      && rm liferay-ce-portal-tomcat-7.2.0-ga1.7z \
      && chown -R liferay:liferay $LIFERAY_HOME \
      && mkdir -p /data/liferay/document_library \
      && chown -R liferay:liferay /data

COPY entrypoint.sh /

# Wait for node for run in secuential mode
COPY config/wait-for-node.sh /

USER liferay

# Configure Liferay
COPY config/portal-ext.properties $LIFERAY_HOME/

# Configurations for unicast cluster
COPY config/*ping.xml $LIFERAY_HOME/tomcat-9.0.17/webapps/ROOT/WEB-INF/classes/

# Add custom logs
COPY config/portal-log4j-ext.xml $LIFERAY_HOME/tomcat-9.0.17/webapps/ROOT/WEB-INF/classes/META-INF/
COPY config/log4j.dtd $LIFERAY_HOME/tomcat-9.0.17/webapps/ROOT/WEB-INF/classes/META-INF/

# Add Redis jars to tomcat
COPY config/tomcat/*.jar $LIFERAY_HOME/tomcat-9.0.17/lib/

EXPOSE 8080/tcp
EXPOSE 11311/tcp

CMD ["/entrypoint.sh", "run"]
