# Liferay 6.2 CE GA6
#
# VERSION 1.0
# Based on ctliv/liferay:6.2
#

# 1.0 : initial file with liferay 6.2-ce-ga6

FROM ubuntu

MAINTAINER Bruno Freire <bmofreire@gmail.com>

# Users and groups
# RUN groupadd -r tomcat && useradd -r -g tomcat tomcat
RUN echo "root:Docker!" | chpasswd

# Install packages
RUN apt-get update && \
	apt-get install -y curl unzip ssh vim net-tools git && \
	apt-get clean
	
# Export TERM as "xterm"
RUN echo -e "\nexport TERM=xterm" >> ~/.bashrc
	
# Install Java 8 JDK 
RUN apt-get install software-properties-common -y && \
	add-apt-repository ppa:openjdk-r/ppa && \
	apt-get update && \
    apt-get install openjdk-8-jdk -y && \
	apt-get clean
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV JRE_HOME=$JAVA_HOME/jre 
ENV PATH=$PATH:$JAVA_HOME/bin

# Install liferay (removing sample application "welcome-theme")
ENV LIFERAY_BASE=/opt
ENV LIFERAY_VER=liferay-portal-6.2-ce-ga6
ENV LIFERAY_HOME=${LIFERAY_BASE}/${LIFERAY_VER} 
ENV TOMCAT_VER=tomcat-7.0.62 
ENV TOMCAT_HOME=${LIFERAY_HOME}/${TOMCAT_VER} 
RUN cd /tmp && \
	curl -o ${LIFERAY_VER}.zip -k -L -C - \
	"http://sourceforge.net/projects/lportal/files/Liferay%20Portal/6.2.5%20GA6/liferay-portal-tomcat-6.2-ce-ga6-20160112152609836.zip" && \
	unzip ${LIFERAY_VER}.zip -d /opt && \
	rm ${LIFERAY_VER}.zip && \
	rm -fr ${TOMCAT_HOME}/webapps/welcome-theme && \
	mkdir -p ${LIFERAY_HOME}/deploy && \
	mkdir -p ${LIFERAY_BASE}/script

# Add symlinks to HOME dirs
RUN ln -fs ${LIFERAY_HOME} /var/liferay && \
	ln -fs ${TOMCAT_HOME} /var/tomcat
	
# Add configuration files to liferay home
ADD conf/* ${LIFERAY_HOME}/

# Add default plugins to auto-deploy directory
#ADD deploy/* ${LIFERAY_HOME}/deploy/

# Add startup scripts
ADD script/* ${LIFERAY_BASE}/script/
RUN chmod +x ${LIFERAY_BASE}/script/*.sh

VOLUME ${LIFERAY_HOME}

# Ports
EXPOSE 8080 8443

# EXEC
CMD ["/opt/script/start.sh"]
