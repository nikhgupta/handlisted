server "handlisted.in", user: 'handlisted', roles: %w{app db web}, port: ENV['DEPLOY_PORT']
set :branch, :master

