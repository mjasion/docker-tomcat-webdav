FROM ubuntu:latest
MAINTAINER Marcin Jasion <marcin.jasion@gmail.com>

# Install Oracle Java 8
ENV JAVA_VER 8
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list && \
    echo 'deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list && \
    sed -i 's/archive\.ubuntu\.com/pl\.archive\.ubuntu\.com/' /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886 && \
    apt-get update && \
    apt-get install --no-install-recommends -y wget ca-certificates && \
    echo oracle-java${JAVA_VER}-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections && \
    apt-get install -y --force-yes --no-install-recommends oracle-java${JAVA_VER}-installer oracle-java${JAVA_VER}-set-default && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /var/cache/oracle-jdk${JAVA_VER}-installer

ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_MINOR_VERSION 8.0.11
ENV CATALINA_HOME /tomcat
ENV TOMCAT_PASS admin

# INSTALL TOMCAT
RUN wget "https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz" && \
    wget -qO- "https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5" | md5sum -c - && \
    tar zxf apache-tomcat-*.tar.gz && \
    rm apache-tomcat-*.tar.gz && \
    mv apache-tomcat* tomcat

RUN sed -i -r 's/<\/tomcat-users>//' ${CATALINA_HOME}/conf/tomcat-users.xml && \
    echo '<role rolename="manager-gui"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml && \
    echo '<role rolename="manager-script"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml && \
    echo '<role rolename="manager-jmx"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml && \
    echo '<role rolename="admin-gui"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml && \
    echo '<role rolename="admin-script"/>' >> ${CATALINA_HOME}/conf/tomcat-users.xml && \
    echo "<user username=\"admin\" password=\"${TOMCAT_PASS}\" roles=\"manager-gui,manager-script,manager-jmx,admin-gui, admin-script\"/>" >> ${CATALINA_HOME}/conf/tomcat-users.xml && \
    echo '</tomcat-users>' >> ${CATALINA_HOME}/conf/tomcat-users.xml && \
    echo "=> Done!"

RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

ENTRYPOINT ["${CATALINA_HOME}/bin/catalina.sh", "run"]
EXPOSE 8080

