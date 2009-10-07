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
  exchange = MQ.topic('my-topic-exchange')
  queue = MQ.queue('my-topic-queue')
  queue.bind(exchange, :key => key).subscribe do |header, body|
    yield header, body
  end
end

def send_to_exchange(message, key)
  exchange = MQ.topic('my-topic-exchange')
  exchange.publish message, :routing_key => key
end

subscribe_to_queue('hello.*.message.#') do |header, body|
  p "I received a message: #{body}"
end

send_to_exchange 'Hello', 'hello.world.message.example.in.ruby'
send_to_exchange 'Cruel', 'cruel.world.message'
send_to_exchange 'World', 'hello.world.message'
event_loop.join
