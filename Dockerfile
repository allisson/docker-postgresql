# Postgresql
#
# VERSION               0.1

FROM ubuntu:latest
MAINTAINER Allisson Azevedo <allisson@gmail.com>

# avoid debconf and initrd
ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No

# apt config
ADD source.list /etc/apt/sources.list
ADD 25norecommends /etc/apt/apt.conf.d/25norecommends

# avoid upgrade error
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl
ADD policy-rc.d /usr/sbin/policy-rc.d
RUN dpkg-divert --divert /usr/bin/ischroot.debianutils --rename /usr/bin/ischroot
RUN ln -s /bin/true /usr/bin/ischroot

# upgrade distro
RUN apt-get update && apt-get upgrade -y 
RUN locale-gen en_US
RUN apt-get install lsb-release -y

# install packages
RUN apt-get install -y openssh-server postgresql supervisor

# make /var/run/sshd
RUN mkdir /var/run/sshd

# copy supervisor conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# setup postgresql
ADD set-psql-password.sh /tmp/set-psql-password.sh
RUN /bin/sh /tmp/set-psql-password.sh
RUN sed -i "/^#listen_addresses/i listen_addresses='*'" /etc/postgresql/9.1/main/postgresql.conf
RUN sed -i "/^# DO NOT DISABLE\!/i # Allow access from any IP address" /etc/postgresql/9.1/main/pg_hba.conf
RUN sed -i "/^# DO NOT DISABLE\!/i host all all 0.0.0.0/0 md5\n\n\n" /etc/postgresql/9.1/main/pg_hba.conf

# set root password
RUN echo "root:root" | chpasswd

# clean packages
RUN apt-get clean
RUN rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# expose postgresql port
EXPOSE 22 5432

# start supervisor
CMD ["/usr/bin/supervisord"]
