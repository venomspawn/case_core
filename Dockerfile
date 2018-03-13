FROM registry.it.vm:6000/ruby2.4.3-alpine3.7:latest

RUN apk update && \
    apk add \
        postgresql-dev \
	vim && \
    rm -f /var/cache/apk/*

RUN echo "export TERM=xterm" >> /root/.bashrc && echo "export PS1=\"[\d \A]\u:\w$ \"" >> /root/.bashrc

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . ./

EXPOSE 8095

ENTRYPOINT ["/usr/local/bin/dumb-init","--"]
CMD ["bundle","exec","foreman","start"]
