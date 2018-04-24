FROM repo.it2.vm/ruby2.4.4-alpine3.7pm:latest

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . ./

EXPOSE 8095

ENTRYPOINT ["/init"]
CMD ["bundle","exec","foreman","start"]
