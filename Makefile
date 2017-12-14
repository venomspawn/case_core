install:
	bundle install

debug:
	bundle exec bin/irb_debug

run:
	bundle exec foreman start

test:
	CC_LOG_LEVEL=unknown bundle exec rspec --fail-fast

.PHONY: doc
doc:
	bin/json_schemas_to_md
	bundle exec yard doc --quiet

.PHONY: doc_stats
doc_stats:
	bundle exec yard stats --list-undoc

migrate:
	bundle exec rake case_core:migrate
