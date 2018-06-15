FROM repo.it2.vm/ruby2.4.4-alpine3.7pm:latest

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . ./

EXPOSE 8081

HEALTHCHECK --interval=5s --timeout=3s CMD curl -f http://localhost:8081/version || exit 1

ENTRYPOINT ["/init"]
CMD ["bundle","exec","foreman","start"]
