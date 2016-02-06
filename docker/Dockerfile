FROM docker.io/debian:jessie
LABEL organization="NCAR EOL"

ARG user=armcross
ARG uid=1000
ARG group=armcross
ARG gid=1000

RUN apt-get update
RUN apt-get install -y --no-install-recommends apt-utils vim curl sudo git ca-certificates build-essential fakeroot libncurses-dev bc dh-make
RUN apt-get install -y sudo

# Get cross tools from emdebian
RUN echo "deb http://emdebian.org/tools/debian/ jessie main" >> /etc/apt/sources.list.d/crosstools.list
RUN curl http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | apt-key add -

RUN dpkg --add-architecture armel
RUN apt-get update
RUN apt-get install -y --no-install-recommends crossbuild-essential-armel

RUN addgroup --gid $gid $group
RUN adduser --ingroup $group --disabled-password --uid $uid --gecos '' $user && echo "${user}:${user}" | chpasswd && adduser $user sudo

RUN echo "%sudo   ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudo_group

USER $user
WORKDIR /home/$user

