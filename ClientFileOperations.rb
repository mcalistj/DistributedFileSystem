require 'uri'

class ClientFileOperations

    def initialize() #initialize(dir_ip, dir_port, port_no)
        @root_dir = "client_file_directory"
        create_directory

    end

    def create_directory()
    	directory_name = "#{@root_dir}"
    	Dir.mkdir(directory_name) unless File.exists?(directory_name)
    end

    def get(filename, server)
        path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
        file = File.open(path, 'wb')
        msg = server.gets
        puts "#{msg}"
        File.write(file, URI.unescape(msg))
        file.close
        puts "Use an editor of your choose to modify the file #{filename}\n"
    end

    def put(filename, server)
        path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
        puts "#{path}"

        if File.file?(path)
            file = File.open(path, 'r')
            file_contents = file.read
            server.puts "PUT_FILE: #{filename}"
            server.puts "#{URI.escape(file_contents)}"
            file.close
            File.delete(path) # Optional Delete file locally?
        else
            puts "ERROR:#{filename} does not exist"
        end
    end

end
