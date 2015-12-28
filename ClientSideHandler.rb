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

        when /\AGET_AND_LOCK_FILE:*/
            server.puts(request)
            return

        when /\APUT_FILE:\s*(\w*\.\w*).*\s*\z/
            server.puts "LOCK_REQUIRED: #{$1}"
            return

        when /\AWRITE_FILE:\s*(\w*\.\w*).*\s*\z/
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
            puts "#{response}"
            return

        when /\ALOCK_REQUIRED:\s*(\w*\.\w*)\s*([0-9])*\z/
            $lock = $2
            if $lock.to_i == 0
                server_request = "WRITE_FILE: #{$1}" 
                value = request(server, server_request)
            else
                puts "This file has a lock placed on it.\nUnable to put the file on the server!"
            end
            return

        when /\ALOCKED:.*\z/
            puts "#{response}"

        else
            puts "#{response}"
            return
        end

        return true
    end

end