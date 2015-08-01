web: bundle exec thin start -e ${RAILS_ENV:-production} -p $PORT
guard: bundle exec guard
sidekiq: bundle exec sidekiq -C config/sidekiq.yml
