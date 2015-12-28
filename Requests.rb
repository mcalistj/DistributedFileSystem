require "socket"

require_relative 'FileOperations.rb'

class Requests

    def initialize()
        @filesystem = FileOperations.new()
        
    end

    def request(client, request, otherServerPorts)
    	# \A - Matches beginning of string.7
    	# \z - Matches end of string
    	# \s* - Matches any number of whitespaces
        case request
        when /\AREAD_FILE:\s*(\w*\.\w*).*\s*\z/
            @filesystem.read($1, client, 0)
            return

        when /\AGET_AND_LOCK_FILE:\s*(\w*\.\w*).*\s*\z/
            @filesystem.get_and_lock($1, client)
            return

        when /\APUT_FILE:\s*(\w*\.\w*).*\s*\z/
            filename = $1
            @filesystem.put($1, client)
            request =  "REPLICATE_FILE: " + filename
            otherServerPorts.each do |port|
                replica_server = TCPSocket.open("localhost", port)
                replica_server.puts(request)
                @filesystem.read(filename, replica_server, 1)
                replica_server.close
            end
            return 
        
        when /\AREPLICATE_FILE:\s*(\w*\.\w*).*\s*\z/
            return @filesystem.put($1, client)

        when /\AIDENTIFY_DFS: I am listening at (\w*) on (\w*)\z/   
            otherServerPorts << $2
            client.puts "MY_IDENTITY: I am listening at host:local on port:#{$port}"
            client.close
            return

        when /\AMY_IDENTITY: I am listening at host:(\w*) on port:(\w*)\z/   
            otherServerPorts << $2
            client.close
            return

        when /\AUSERNAME: (\w*)\z/
            client.puts "Happy file editing #{$1}\n"
            return

        else
            client.puts "ERROR_CODE:4xx (Even though this isn't HTTP)"
            client.puts "ERROR:Malformatted request"
            return
        end

        return true
    end

end