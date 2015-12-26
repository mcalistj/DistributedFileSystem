require_relative 'FileOperations.rb'

class FileRequests

    def initialize()
        @filesystem = FileOperations.new()
        
    end

    def request(client, request)
    	# \A - Matches beginning of string.7
    	# \z - Matches end of string
    	# \s* - Matches any number of whitespaces
        case request
        when /\AGET_FILE:\s*(\w*\.\w*).*\s*\z/
            @filesystem.get($1, client)
            return

        when /\APUT_FILE:\s*(\w*\.\w*).*\s*\z/
            return @filesystem.put($1, client)
            

        else
            client.puts "ERROR_CODE:4xx (Even though this isn't HTTP)"
            client.puts "ERROR:Malformatted request"
            return
        end

        return true
    end

end