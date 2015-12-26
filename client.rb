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
    @request = Thread.new do
      loop {
        msg = $stdin.gets.chomp
        ack = @file_operations.request(@server, msg)
      }
    end
  end
end

hostname = "localhost"
port = 3000
connection = TCPSocket.open(hostname, port)
Client.new(connection)