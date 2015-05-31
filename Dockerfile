FROM muzili/centos-base:latest
MAINTAINER Joshua lee <muzili@gmail.com>

ENV JENKINS_UC https://updates.jenkins-ci.org
ENV JENKINS_HOME /data/jenkins
ENV JENKINS_UID 1000

RUN wget --progress=bar -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo && \
    rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key && \
    yum -y install java-1.8.0-openjdk-headless jenkins && \
    yum clean all

# Create the sleleton 1st run
ADD scripts /scripts
RUN chmod +x /scripts/*.sh && touch /first_run

# `/usr/share/jenkins/ref/` contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d
COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-angent-port.groovy

# Install the plugins
COPY plugins.txt /plugins.txt
RUN /scripts/plugins.sh /plugins.txt

# Jenkins is ran with user `jenkins`, uid = 1000
# If you bind mount a volume from host/vloume from a data container,
# ensure you use same uid
RUN chown -R jenkins /usr/share/jenkins/ref

# Expose our web root and log directories log.
VOLUME ["/var/log", "/data"]

# Export our port
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

# Kicking in
CMD ["/scripts/start.sh"]
