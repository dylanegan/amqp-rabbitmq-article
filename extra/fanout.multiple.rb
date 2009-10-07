require 'rubygems'
require 'mq'
event_loop = Thread.new do
  EM.run do
    EM.add_timer(1) do
      EM.stop
    end
  end
end

def subscribe_to_queue(fanout, queue)
 exchange = MQ.fanout(fanout)
 queue = MQ.queue(queue)
 queue.bind(exchange).subscribe do |header, body|
   yield header, body
 end
end

def send_to_exchange(message)
 exchange = MQ.fanout('my-fanout-exchange')
 exchange.publish message
end

subscribe_to_queue('my-fanout-exchange', 'my-fanout-queue') do |header, body|
  p "I received a message: #{body}"
end

subscribe_to_queue('my-fanout-exchange', 'my-second-fanout-queue') do |header, body|
  p "I also received a message: #{body}"
end

send_to_exchange 'Hello'
send_to_exchange 'World'
event_loop.join
