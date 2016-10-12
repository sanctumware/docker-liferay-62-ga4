# Liferay CE Portal 6.2 GA4
#
# VERSION 1.0
# Based on fmarco76/docker-liferay
# Based on ctliv/liferay:6.2
# Based on bfreire/docker-liferay-mysql
#

FROM alpine

MAINTAINER Michael Angelo B. Sevilla <msevilla@ms3-inc.com>

# Users and groups
#RUN groupadd -r tomcat && useradd -r -g tomcat tomcat
RUN echo "root:Docker!" | chpasswd

# Install packages
RUN apt-get update && \
	apt-get install -y curl unzip ssh openssh-server vim net-tools git && \
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
ENV LIFERAY_VER=liferay-ce-portal-6.2-ga4
ENV LIFERAY_HOME=${LIFERAY_BASE}/${LIFERAY_VER}
ENV TOMCAT_VER=tomcat-7.0.42
ENV TOMCAT_HOME=${LIFERAY_HOME}/${TOMCAT_VER}
RUN cd /tmp && \
	curl -o ${LIFERAY_VER}.zip -k -L -C - \
	# "http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/7.0.1%20GA2/liferay-ce-portal-tomcat-7.0-ga2-20160610113014153.zip" && \
	"https://sourceforge.net/projects/lportal/files/Liferay%20Portal/6.2.3%20GA4/liferay-portal-tomcat-6.2-ce-ga4-20150416163831865.zip" && \
	unzip ${LIFERAY_VER}.zip -d /opt && \
	rm ${LIFERAY_VER}.zip && \
	rm -fr ${TOMCAT_HOME}/webapps/welcome-theme && \
	mkdir -p ${LIFERAY_HOME}/deploy && \
	mkdir -p ${LIFERAY_BASE}/script

# Add symlinks to HOME dirs
RUN ln -fs ${LIFERAY_HOME} /var/liferay && \
	ln -fs ${TOMCAT_HOME} /var/tomcat

# Add configuration files to liferay home
#ADD conf/* ${LIFERAY_HOME}/

# Add default plugins to auto-deploy directory
#ADD deploy/* ${LIFERAY_HOME}/deploy/

# Add startup scripts
ADD script/* ${LIFERAY_BASE}/script/
RUN chmod +x ${LIFERAY_BASE}/script/*.sh

VOLUME ${LIFERAY_HOME}

# Ports
EXPOSE 8081 8443

# Start the ssh service
RUN service ssh start

# EXEC
CMD ["/opt/script/start.sh"]
