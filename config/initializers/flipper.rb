require 'flipper/adapters/redis'

Flipper.configure do |config|
  config.adapter { Flipper::Adapters::Redis.new(Redis.new) }
end
