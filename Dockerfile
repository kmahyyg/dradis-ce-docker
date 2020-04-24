FROM debian:sid-slim
LABEL SOFTWARE_VERSION "-git"
LABEL UPDATED_ON "20200424"
LABEL MAINTAINER "kmahyyg <i@kmahyyg.xyz>"

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8
VOLUME /var/lib/redis

RUN sed -i 's/sid main/sid main contrib non-free/g' /etc/apt/sources.list && \
    apt update -y && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    apt install locales -y && \
    apt install supervisor python3-pip redis-server libsqlite3-dev zlib1g-dev git build-essential wget curl ca-certificates procps -y && \
    gpg --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - && \
    curl -sSL https://get.rvm.io | bash -s stable && \
    usermod -aG rvm root 
RUN /bin/bash -l -c "umask u=rwx,g=rwx,o=rx && . /etc/profile.d/rvm.sh && rvm install 2.4.1 && ruby -v && gem install bundler && rm -rf /var/cache/apt/*"

WORKDIR /etc/redis
RUN sed -i 's/save 900 1//g' /etc/redis/redis.conf && \
    sed -i 's/save 300 10//g' /etc/redis/redis.conf && \
    sed -i 's/save 60 10000//g' /etc/redis/redis.conf

WORKDIR /root
RUN /bin/bash -l -c "git clone https://github.com/dradis/dradis-ce.git && cd dradis-ce && ./bin/setup"

EXPOSE 3000
COPY supervisord.conf /root/supervisord.conf
CMD ["/bin/bash", "-l", "-c", "/usr/bin/supervisord", "-c", "/root/supervisord.conf"]

