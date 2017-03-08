FROM resin/nuc-debian:jessie

RUN apt-get update && \
	apt-get install -y openjdk-7-jre-headless \
		ca-certificates \
		curl \
		openssl \
		btrfs-tools \
		aufs-tools \
		e2fsprogs \	
		iptables \
		xfsprogs \
		xz-utils \
		wget \
		git \
	&& cd / \
	&& wget https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/2.2/swarm-client-2.2-jar-with-dependencies.jar -O swarm-client.jar	

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.13.0
ENV DOCKER_SHA256 fc194bb95640b1396283e5b23b5ff9d1b69a5e418b5b3d774f303a7642162ad6

RUN set -x \
	&& curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
	&& echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
	&& tar -xzvf docker.tgz \
	&& mv docker/* /usr/local/bin/ \
	&& rmdir docker \
	&& rm docker.tgz \
	&& docker -v

# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
RUN set -x \
	&& addgroup --system dockremap \
	&& adduser --system --ingroup dockremap dockremap \
	&& echo 'dockremap:165536:65536' >> /etc/subuid \
	&& echo 'dockremap:165536:65536' >> /etc/subgid

VOLUME /data

ENV INITSYSTEM on

COPY services/docker.service /etc/systemd/system/
RUN systemctl enable docker.service

COPY services/autohat_jenkins_slave@.service /etc/systemd/system/
COPY services/run_slave.sh /etc/autohat/services/run_slave.sh

COPY services/manage_autohat_slaves.service /etc/systemd/system/
COPY services/manage_autohat_slaves.timer /etc/systemd/system/
COPY services/manage_autohat_slaves.sh /etc/autohat/services/manage_autohat_slaves.sh
RUN systemctl enable manage_autohat_slaves.timer

COPY start /start

CMD /start
