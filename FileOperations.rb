require 'uri'

class FileOperations

    def initialize() #initialize(dir_ip, dir_port, port_no)
        @root_dir = "server_file_directory"
        create_directory

    end

    def create_directory()
    	directory_name = "#{@root_dir}"
    	Dir.mkdir(directory_name) unless File.exists?(directory_name)
    end

    def get(filename, client)
        path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
        puts "#{path}"

        if File.file?(path)
            file = File.open(path, 'r')
            file_contents = file.read
            client.puts "GET_FILE: #{filename}"
            client.puts "#{URI.escape(file_contents)}"
            file.close
        else
            client.puts "ERROR:#{filename} does not exist"
        end
    end

    def put(filename, client)
        path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
        if not File.exists?("#{path}")
          client.puts "New file named #{filename} created\n"
        end
        file = File.open(path, 'wb')
        content = client.gets
        client.puts "PUT_FILE: #{filename}"
        File.write(file, URI.unescape(content))
        puts "Contents written to #{filename} on this machine\n"
        client.puts "Contents written to #{filename} on the server\n"
        file.close
    end

end
