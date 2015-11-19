require 'sidekiq/testing'

Sidekiq::Testing.server_middleware do |chain|
  chain.add Sidekiq::Status::ServerMiddleware
end
