require "socket"

require_relative 'Requests.rb'

class Server
  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @fileRequests = Requests.new()
    @otherServerPorts = []
    identitfy_other_servers(ip)
    run

  end

  def identitfy_other_servers(this_server_ip)
  # Try establish possible 'distributed file server' ports
  # This CLI mustbe run from elevated privilege. This has only been tested on a Windows OS
  # This solution assumes all Distributed File Servers are running on the same machine 
    possible_ports = []
    pipe = IO.popen("netstat -abno | find \"[::1]\" | find \"LISTENING\" ") 
    while (line = pipe.gets)
      matchData = line.match(/\\*.\[::1\]:([0-9]{2,4}).*?.LISTENING/)
      possible_ports << matchData[1]
    end
    possible_ports.each do |port|
      unless port == $port 
        conn = TCPSocket.open(this_server_ip, port)
        begin
          conn.puts "IDENTIFY_DFS: I am listening at #{this_server_ip} on #{$port}"
          response = conn.gets.chomp
          @fileRequests.request(conn, response, @otherServerPorts)
          conn.close
        rescue
          # "Could not carry out request"
        end
      end
    end
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        #nick_name = client.gets.chomp.to_sym
        #puts "#{nick_name} #{client}"
        #client.puts "Connection established! Happy file editing"
        listen_user_messages( client )
      end
    }.join
  end

  def listen_user_messages( client )
    loop {
      #first_msg = client.gets.chomp
      #@fileRequests.request(client, first_msg, @otherServerPorts)
      #client.puts "Read from or write to the server using:\n
       #GET_FILE: 'name_of_file',\n
       #or PUT_FILE: 'name_of_file'"
      msg = client.gets.chomp
      if msg.include? "KILL_SERVICE" then
        client.puts "Server shutdown"
        client.close
        @server.close
      elsif msg.include? "HELO" then
        response_neccessary(client, msg)
      else
        receipt = @fileRequests.request(client, msg, @otherServerPorts)
      end
      client.puts "Read from or write to the server using:\n
       GET_FILE: 'name_of_file',\n
       or PUT_FILE: 'name_of_file'"
    }
  end
end

def response_neccessary(client, line)
  client.puts "#{line}" + "IP:#{get_ip_address()}\nPort:#{$port}\nStudentID:02484893aa070fa3e7d2f5b2d14c90823425659e554bab3ddb69890974f95ada\n"
  client.close
end

def get_ip_address()
  return "52.23.177.84"
  #wget http://ipinfo.io/ip -qO -
end

$port = ARGV[0]
Server.new( $port, "localhost" )
