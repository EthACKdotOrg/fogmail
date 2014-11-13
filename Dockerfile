FROM debian:jessie

RUN echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d//50-ignore-recommends
RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d//50-ignore-recommends
RUN apt-get update -q
RUN apt-get dist-upgrade -qy
RUN apt-get install -qy wget puppet curl git-core lsb-release


ADD puppet /
RUN puppet apply --modulepath=/modules /mailserver.pp --verbose --show_diff

EXPOSE 443 80 465 993 995

CMD ["/usr/local/sbin/startall"]
