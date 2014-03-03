$:.unshift(File.dirname(__FILE__))
require 'socket'

def send_data_graphite(name, data)

  graphite_server ="graphite.servername.com"
  graphite_port   ="2003"
  time = Time.new
  epoch = time.to_i
  s = TCPSocket.open(#{graphite_server}, #{graphite_port})
  s.write("#{name} #{data}  #{epoch}\n")
  s.close
end

