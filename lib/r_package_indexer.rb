require 'socket'
require 'http/parser'
require 'dcf'

class RPackageIndexer

	# nothing to do here for the moment, could be used later for initial settings
	def initialize
		@header_sep = "\r\n"
		@headers_sep = "\r\n\r\n"
		@package_sep = "\n"
		@http_parser = Http::Parser.new
		@packages_path = "/src/contrib/" 
		@packages_list_path = "#{@packages_path}PACKAGES"
	end
	
	# connects to the url and streams the package descriptions for indexing
	def index_http(host)
		socket = TCPSocket.open(host, 80)
		socket.write(request(host))
		content_length = nil # add to closure
		@http_parser.on_headers_complete = proc do |env|
			#we now have the content length, use that to run through the stream
  		content_length = env["Content-Length"].to_i rescue nil
		end
		@http_parser << socket.gets(@headers_sep) # parse the headers
		index(socket, content_length)
		socket.close		
	end
	
	#an alternative source for data
	def index_file(path)
		file = File.open(path, "r") do
			index(file, file.size)
		end
	end
	
	# given an IO stream (File, Socket, StringIO, etc) this method will
	# run through the stream and extract package info, then will pass the
	# package info to the package indexing function
	def index(stream, length)
		processed_bytes = 0
		package_desc = ""
		while line = stream.gets
				if line != "\n"
					package_desc << line
				else
					index_package package_desc
					package_desc = ""
				end
				processed_bytes = processed_bytes + line.length
				break unless processed_bytes < length
		end
	end
	
	# uses a package description to index it
	def index_package(package_desc)
		puts Dcf.parse(package_desc)
	end
	
	# helpers
	def request(host)
		"GET #{@packages_list_path} HTTP/1.1#{@header_sep}Host: #{host}#{@headers_sep}"
	end
	
end
