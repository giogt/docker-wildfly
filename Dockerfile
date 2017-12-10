FROM giogt/jdk:1.8.0
MAINTAINER Giorgio Carlo Gili Tos <giorgio.gilitos@gmail.com>

# install packages necessary to run EAP
RUN yum -y install xmlstarlet saxon augeas && \
  yum clean all

# create wildfly user and group
RUN groupadd -r wildfly -g 1000 && useradd -u 1000 -r -g wildfly -m -d /home/wildfly -s /sbin/nologin -c "wildfly user" wildfly

# set wildfly version
ENV WILDFLY_VERSION 11.0.0.Final

# install jboss wildfly
RUN curl http://download.jboss.org/wildfly/${WILDFLY_VERSION}/wildfly-${WILDFLY_VERSION}.tar.gz | tar zx --directory="/home/wildfly"  && \
mv /home/wildfly/wildfly-${WILDFLY_VERSION} /home/wildfly/current

# set wildfly and jboss home
ENV WILDFLY_HOME /home/wildfly/current
ENV JBOSS_HOME /home/wildfly/current

# set working directory
WORKDIR /home/wildfly/current

# create a directory for external deployments
RUN mkdir /home/wildfly/current/deployments.ext

# copy additional files
COPY wildfly /home/wildfly/current

# change ownership and fix executable permissions
RUN chown -R wildfly:wildfly /home/wildfly/current && \
chmod ug+rwx "/home/wildfly/current/bin"/*.sh

# switch to wildfly user
USER wildfly

# add wildfly admin user for management
RUN /home/wildfly/current/bin/add-user.sh --silent=true admin admin123 > /tmp/wildfly-add-user.log 2>&1

# expose ports used by wildfly
EXPOSE 8080 8443 9990 9993 8787

# run wildfly launcher on container start
CMD ["/home/wildfly/current/bin/wildfly.sh"]
