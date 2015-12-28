require 'uri'

class FileOperations

    def initialize() #initialize(dir_ip, dir_port, port_no)
        @root_dir = "server_file_directory#{$port}"
        @mutex_locks = Hash.new
        create_directory

    end

    def create_directory()
    	directory_name = "#{@root_dir}"
    	Dir.mkdir(directory_name) unless File.exists?(directory_name)
    end

    def read(filename, client, replicate)
        path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
        if File.file?(path)
            file = File.open(path, 'r')
            file_contents = file.read
            unless replicate == 1
                client.puts "READ_FILE: #{filename}"
            end
            client.puts "#{URI.escape(file_contents)}"
            file.close
            client.puts "Use an editor of your choice to read the file #{filename} and make local changes ONLY\n"
        else
            client.puts "ERROR:#{filename} does not exist"
        end
    end

    def get_and_lock(filename, client)
        path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
        if File.file?(path)
            if @mutex_locks[filename]    # Check if file is locked
                unless @mutex_locks.fetch(filename) == client
                    client.puts "LOCKED: A lock is acquired on this file. Cannot write at the time being"
                    return
                end
            else   
            unless @mutex_locks[filename]
                @mutex_locks = {filename => client}
            end
            file = File.open(path, 'r')
            file_contents = file.read
            client.puts "READ_FILE: #{filename}"
            client.puts "#{URI.escape(file_contents)}"
            file.close
            client.puts "Use an editor of your choice to edit the file #{filename}. You have acquired a lock on this file\n"
            end
        else
            client.puts "ERROR:#{filename} does not exist"
        end
    end

    def put(filename, client)
        path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__) 
        if not File.exists?("#{path}")
          client.puts "New file named #{filename} created\n"
        end
        if @mutex_locks[filename]    # Check if file is locked
            unless @mutex_locks.fetch(filename) == client
                return 0
            end
        end
        file = File.open(path, 'wb')
        content = client.gets
        File.write(file, URI.unescape(content))
        puts "Contents written to #{filename} on this server\n"
        client.puts "Contents written to #{filename} on the server\n"
        file.close
        if @mutex_locks[filename]    # Check if lock needs to be released
            @mutex_locks.delete(filename)
        end
        return 1
    end

end
