require "socket"

require_relative 'FileRequests.rb'

class Server
  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @FileRequests = FileRequests.new()
    run

  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        nick_name = client.gets.chomp.to_sym
        puts "#{nick_name} #{client}"
        client.puts "Connection established, Thank you for joining! Happy chatting"
        listen_user_messages( nick_name, client )
      end
    }.join
  end

  def listen_user_messages( username, client )
    loop {
      msg = client.gets.chomp
      if msg.include? "KILL_SERVICE" then
        client.puts "Server shutdown"
        client.close
        @server.close
      elsif msg.include? "HELO" then
        client.puts "#{line}" + "IP:#{get_ip_address()}\nPort:#{$port}\nStudentID:02484893aa070fa3e7d2f5b2d14c90823425659e554bab3ddb69890974f95ada\n"
      else
        @FileRequests.request(client, msg)
      end
    }
  end
end

Server.new( 3000, "localhost" )