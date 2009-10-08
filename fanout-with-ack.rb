require 'rubygems'
require 'mq'

event_loop = Thread.new do
  EM.run do
    EM.add_timer(1) do
      EM.stop
    end
  end
end

def subscribe_to_queue
  exchange = MQ.fanout('my-fanout-exchange-with-acks')
  queue = MQ.queue('my-fanout-queue-with-acks')
  queue.bind(exchange).subscribe(:ack => true) do |header, body|
    yield header, body
    header.ack unless body == 'Cruel'
  end
end

def send_to_exchange(message)
  exchange = MQ.fanout('my-fanout-exchange-with-acks')
  exchange.publish message
end

subscribe_to_queue do |header, body|
  p "I received a message: #{body}"
end

send_to_exchange 'Hello'
send_to_exchange 'Cruel'
send_to_exchange 'World'
event_loop.join

__END__

First run:
"I received a message: Hello"
"I received a message: Cruel"
"I received a message: World"

Second run:
"I received a message: Cruel"
"I received a message: Hello"
"I received a message: Cruel"
"I received a message: World"
... and so forth
