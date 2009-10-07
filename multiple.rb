require 'rubygems'
require 'mq'
event_loop = Thread.new do
  EM.run do
    EM.add_timer(1) do
      EM.stop
    end
  end
end

def subscribe_to_queue(*keys)
 exchange = MQ.direct('my-direct-exchange')
 queue = MQ.queue('my-direct-queue-with-multiple-bindings')
 bindings = keys.map do |key|
   queue.bind(exchange, :key => key)
 end
 bindings.last.subscribe do |header, body|
   yield header, body
 end
end

def send_to_exchange(message, key)
 exchange = MQ.direct('my-direct-exchange')
 exchange.publish message, :routing_key => key
end

subscribe_to_queue('foo', 'bar', 'wee') do |header, body|
  p "I received a message: #{body}"
end

send_to_exchange 'Hello', 'foo'
send_to_exchange 'You', 'gee'
send_to_exchange 'Cruel', 'bar'
send_to_exchange 'World', 'wee'
event_loop.join
