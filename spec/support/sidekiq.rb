require 'sidekiq/testing'

module Sidekiq::Worker::ClassMethods
  # Inject server middlewares when testing Sidekiq using job queues, so that we
  # are able to test the Sidekiq::Status gem appropriately.
  def execute_job(worker, args)
    Sidekiq::Status::ServerMiddleware.new.call(worker, nil, nil) do
      worker.perform(*args)
    end
    # Sidekiq.server_middleware.entries.map(&:klass).each do |mw|
    #   mw.new.call(worker, job, 'default') do
    #     worker.perform(*job['args'])
    #   end
    # end
  end
end

RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Testing.fake!
  end
end


