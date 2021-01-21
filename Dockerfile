FROM debian:buster-backports

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y; apt-get full-upgrade -y; apt-get install -y \
	wget \
	curl \
	git \
	dmidecode \
	ca-certificates \
	rsync

RUN curl -L https://bootstrap.saltstack.com | sh -s -- -x python3
RUN mkdir -p /srv/salt/states; mkdir -p /srv/salt/pillar ; apt-get clean; rm -rf /var/lib/apt/lists/*
RUN mkdir -p /opt/salt/base; mkdir -p /opt/salt/base{pillar,states,stack}
    
RUN echo "file_client: local" > /etc/salt/minion.d/minion.conf && \
    echo "pillar_roots:" > /etc/salt/minion.d/pillar_roots.conf && \
    echo "  base:" >> /etc/salt/minion.d/pillar_roots.conf && \
    echo "    - /opt/salt/base/pillar" >> /etc/salt/minion.d/pillar_roots.conf && \
    echo "file_roots:" > /etc/salt/minion.d/file_roots.conf && \
    echo "  base:" >> /etc/salt/minion.d/file_roots.conf && \
    echo "    - /opt/salt/base/states" >> /etc/salt/minion.d/file_roots.conf && \
    echo "top_file_merging_strategy: same" >> /etc/salt/minion.d/file_roots.conf

RUN salt-call --local -l debug service.restart salt-minion
