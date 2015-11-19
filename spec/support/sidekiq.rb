require 'sidekiq/testing'

# Inject server middlewares when testing Sidekiq using job queues, so that we
# are able to test the Sidekiq::Status gem appropriately.
module Sidekiq::Worker::ClassMethods
  def execute_job(worker, args)
    Sidekiq::Status::ServerMiddleware.new.call(worker, nil, nil) do
      worker.perform(*args)
    end
  end
end
