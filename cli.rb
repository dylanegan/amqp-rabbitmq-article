require 'rubygems'
require 'mq'

PATH_TO_RABBITMQCTL = '/opt/local/sbin/rabbitmqctl'

event_loop = Thread.new { EM.run }

def subscribe_to_logger
  random_name = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
  exchange = MQ.topic('amq.rabbitmq.log')
  queue = MQ.queue(random_name, :autodelete => true, :exclusive => true)
  binding = queue.bind(exchange, :key => '#')
  binding.subscribe do |header, body|
    body.split("\n").each do |message|
      yield header, message
    end
  end
end

def exchange_info(vhost = '/')
  info :exchange, vhost, %w(name type durable auto_delete arguments)
end

def queue_info(vhost = '/')
  info :queue, vhost, %w(name durable auto_delete arguments node messages_ready messages_unacknowledged messages_uncommitted messages acks_uncommitted consumers transactions memory)
end

def binding_info(vhost = '/')
  info :binding, vhost
end

def connection_info
  info :exchange, nil, %w(node address port peer_address peer_port state channels user vhost timeout frame_max recv_oct recv_cnt send_oct send_cnt send_pend)
end

def info(about, vhost = nil, items = [])
  column_length = 20
  puts "#{about} info\n"
  cmd = "#{PATH_TO_RABBITMQCTL} list_#{about}s"
  cmd << " -p #{vhost}" if vhost
  cmd << " #{items.join(' ')} 2>&1"
  pipe = IO.popen(cmd)
  pipe.readlines.map do |line| 
    line.chomp.split("\t").map do |item| 
      item.ljust(column_length)[0,column_length]
    end
  end.slice(1..-2).each do |exchange|
    print exchange.join(' ') + "\n"
  end
end

subscribe_to_logger do |message|
  p "RabbitMQ logger: #{message}"
end

%w(connection exchange queue binding).each do |method|
  self.send "#{method}_info".to_sym
end

event_loop.join
