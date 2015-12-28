require_relative 'ClientFileOperations.rb'

class ClientSideHandler

    def initialize()
        @client_filesystem = ClientFileOperations.new()
        
    end

    def request(server, request)
    	# \A - Matches beginning of string.7
    	# \z - Matches end of string
    	# \s* - Matches any number of whitespaces
        case request
        when /\AREAD_FILE:*/
            server.puts(request)
            return

        when /\APUT_FILE:\s*(\w*\.\w*).*\s*\z/
            @client_filesystem.put($1, server)
            return

        else
            server.puts "#{request}"
            return
        end

        return true
    end

    def response(server, response)
        case response
        when /\AREAD_FILE:\s*(\w*\.\w*).*\s*\z/
            return @client_filesystem.get($1, server)
            
        when /\APUT_FILE:\s*(\w*\.\w*).*\s*\z/
            response = server.gets
            puts "#{response}"
            return

        else
            puts "#{response}"
            return
        end

        return true
    end

end