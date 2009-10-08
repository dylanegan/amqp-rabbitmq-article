require 'rubygems'
require 'mq'

event_loop = Thread.new do
  EM.run do
    EM.add_timer(5) do
      EM.stop
    end
  end
end

def subscribe_to_queue
  exchange = MQ.fanout('my-fanout-exchange')
  queue = MQ.queue('my-fanout-queue')
  queue.bind(exchange).pop do |header, body|
    yield header, body
  end

  EM.add_periodic_timer(0.25) do
    queue.pop
  end
end

def send_to_exchange(message)
  exchange = MQ.fanout('my-fanout-exchange')
  exchange.publish message
end

received = 0

subscribe_to_queue do |header, body|
  p "I received a message: #{body}"
end

send_to_exchange 'Hello'
send_to_exchange 'World'

event_loop.join
