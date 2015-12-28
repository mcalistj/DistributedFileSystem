require "socket"

require_relative 'ClientSideHandler.rb'

class Client
  def initialize( server )
    @server = server
    @request = nil
    @response = nil
    @file_operations = ClientSideHandler.new()
    listen
    send
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop {
        msg = @server.gets.chomp
        response = @file_operations.response(@server, msg)
      }
    end
  end

  def send
    puts "Enter the username:"
    msg = $stdin.gets.chomp
    msg = "USERNAME: #{msg}"
    @file_operations.request(@server, msg)
    @request = Thread.new do
      loop {
        msg = $stdin.gets.chomp
        ack = @file_operations.request(@server, msg)
      }
    end
  end
end

hostname = "localhost"
$port = ARGV[0]
connection = TCPSocket.open(hostname, $port)
Client.new(connection)