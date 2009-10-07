require 'rubygems'
require 'mq'
event_loop = Thread.new do
  EM.run do
    EM.add_timer(1) do
      EM.stop
    end
  end
end

def subscribe_to_queue(key)
 exchange = MQ.direct('my-direct-exchange')
 queue = MQ.queue('my-direct-queue')
 queue.bind(exchange, :key => key).subscribe do |header, body|
   yield header, body
 end
end

def send_to_exchange(message, key)
 exchange = MQ.direct('my-direct-exchange')
 exchange.publish message, :routing_key => key
end

subscribe_to_queue('hello_world') do |header, body|
  p "I received a message: #{body}"
end

send_to_exchange 'Hello', 'hello_world'
send_to_exchange 'Cruel', 'ignored'
send_to_exchange 'World', 'hello_world'
event_loop.join
