FROM registry.it.vm:6000/ruby:2.4.3-alpine3.7

RUN apk update && \
    apk upgrade && \
    apk add \
        git \
        g++ \
        make \
        postgresql-dev \
        tzdata \
	curl \
	bash \
	vim

RUN rm -f /var/cache/apk/*

RUN cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime && echo "Europe/Moscow" >  /etc/timezone

RUN curl --fail -L -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 && \
    chmod +x /usr/local/bin/dumb-init

RUN echo "export TERM=xterm" >> /root/.bashrc && echo "export PS1=\"[\d \A]\u:\w$ \"" >> /root/.bashrc

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile .
COPY Gemfile.lock .

RUN bundle install

COPY . ./

EXPOSE 8095

ENTRYPOINT ["/usr/local/bin/dumb-init","--"]
CMD ["bundle","exec","foreman","start"]
