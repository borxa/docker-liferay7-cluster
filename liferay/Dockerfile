FROM openjdk:8-alpine

MAINTAINER Borxa Varela Bouzas <borxa@varelabouzas.net>

RUN apk add --no-cache curl p7zip

RUN addgroup -g 1001 liferay && \
    adduser -D -u 1002 -G liferay liferay

ENV LIFERAY_HOME=/usr/local/liferay
ENV LIFERAY_TOMCAT_URL=https://sourceforge.net/projects/lportal/files/Liferay%20Portal/7.2.1%20GA2/liferay-ce-portal-tomcat-7.2.1-ga2-20191111141448326.7z/download

WORKDIR /usr/local

# Install Liferay 
RUN curl -fSL "$LIFERAY_TOMCAT_URL" -o liferay.7z \
      && 7za x liferay.7z -y \
      && rm liferay.7z \
      && ln -s liferay* liferay \
      && cd liferay \
      && ln -s tomcat* tomcat \
      && chown -R liferay:liferay * \
      && mkdir -p /data/liferay/document_library \
      && chown -R liferay:liferay /data

COPY entrypoint.sh /

# Wait for node for run in secuential mode
COPY config/wait-for-node.sh /

USER liferay

# Configure Tomcat session cluster
COPY config/tomcat/server*.xml $LIFERAY_HOME/tomcat/conf/
COPY config/tomcat/context*.xml $LIFERAY_HOME/tomcat/conf/
#COPY config/tomcat/web.xml $LIFERAY_HOME/tomcat/conf/
#COPY config/tomcat/web-root.xml $LIFERAY_HOME/tomcat/webapps/ROOT/WEB-INF/web.xml

# Configure Liferay
COPY config/portal-ext.properties $LIFERAY_HOME/

# Configurations for unicast cluster
COPY config/*ping.xml $LIFERAY_HOME/tomcat/webapps/ROOT/WEB-INF/classes/

# Add custom logs
COPY config/portal-log4j-ext.xml $LIFERAY_HOME/tomcat/webapps/ROOT/WEB-INF/classes/META-INF/
COPY config/log4j.dtd $LIFERAY_HOME/tomcat/webapps/ROOT/WEB-INF/classes/META-INF/

# Add Redis jars to tomcat
COPY config/tomcat/*.jar $LIFERAY_HOME/tomcat/lib/

EXPOSE 8080/tcp
EXPOSE 11311/tcp

CMD ["/entrypoint.sh", "run"]
