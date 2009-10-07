require 'rubygems'
require 'mq'

event_loop = Thread.new do
  EM.run do
    EM.add_timer(1) do
      EM.stop
    end
  end
end

# connect to the rabbitmq demonstration broker server (http://www.rabbitmq.com/examples.html#demoserver)
AMQP.start :host => 'dev.rabbitmq.com', :port => 5672, :user => 'guest', :password => 'guest', :vhost => 'localhost'
event_loop.join
