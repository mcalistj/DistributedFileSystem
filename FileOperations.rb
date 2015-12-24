require 'socket'
require 'uri'

class FileOperations

    def initialize() #initialize(dir_ip, dir_port, port_no)
        @root_dir = "dfs_file_directory"
        create_directory

    end

    def create_directory()
    	directory_name = "#{@root_dir}"
    	Dir.mkdir(directory_name) unless File.exists?(directory_name)

    def get(filename, client)
        path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
        puts "#{path}"

        if File.file?(path)
            file = File.open(path, 'r')
            file_contents = file.read
            client.puts "CONTENT_LENGTH:#{file_contents.length}"
            client.puts "CONTENT:#{URI.escape(file_contents)}"
            file.close
        else
            client.puts "ERROR:#{filename} does not exist"
        end
    end

    def put(filename, client)
        path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
        file = File.open(path, 'wb')

        file.close
    end

end