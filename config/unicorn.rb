# config/unicorn.rb

# Allows the use of pry with unicorn in development.
if ENV["RAILS_ENV"] == "development" || ENV["RAILS_ENV"] == "docker"
  worker_processes 1
  timeout 10000
else
  worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
  timeout 30
  preload_app true
end

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
