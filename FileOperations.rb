require 'uri'
require 'socket'

class FileOperations

    attr_writer :mutex_locks

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

    def get_and_lock(filename, client, otherServerPorts)
        path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__)
        if File.file?(path)
            if @mutex_locks[filename]    # Check if file is locked
                unless @mutex_locks.fetch(filename) == client
                    client.puts "LOCKED: A lock is acquired on this file. Cannot write at the time being"
                    return
                end
            else   
            unless @mutex_locks[filename]
                if @mutex_locks.empty?
                    @mutex_locks = {filename => client}
                else
                    @mutex_locks["#{filename}"] = client
                end
                puts @mutex_locks
                propagate_all_locks(filename, client, otherServerPorts)
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

    def lock_required(filename, client)
        path = File.expand_path("../#{@root_dir}/#{filename}", __FILE__) 
        if not File.exists?("#{path}")
          return 0
        end
        puts @mutex_locks
        if @mutex_locks[filename]    # Check if file is locked
            unless @mutex_locks.fetch(filename) == client
                return 1
            end
        end
        return 0
    end

    def propagate_all_locks(filename, client, otherServerPorts)
        otherServerPorts.each do |port|
            unless port == $port
                puts port
                replica_server = TCPSocket.open("localhost", port)
                request = "PROPAGATE_LOCKS: #{filename} #{client}\n"
                puts request
                replica_server.puts "#{request}"
                replica_server.close
            end
        end
    end

    def add_to_locks(filename, client)
        if @mutex_locks.empty?
            @mutex_locks = {filename => client}
        else
            @mutex_locks["#{filename}"] = client
        end
        puts @mutex_locks
    end

end
