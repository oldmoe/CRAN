require 'socket'
require 'logger'
require 'http/parser'
require 'dcf'
require 'net/http'
require './models/r_package'
require 'rubygems/package'
require 'zlib'

module RPackageIndexer
	
	class Master

	# nothing to do here for the moment, could be used later for initial settings
	def initialize
		@header_sep = "\r\n"
		@headers_sep = "\r\n\r\n"
		@package_sep = "\n"
		@http_parser = Http::Parser.new
		@packages_path = "/src/contrib/" 
		@packages_list_path = "#{@packages_path}PACKAGES"
		@logger = Logger.new(STDOUT)
		@key_fields = ["Package", "Version"]
		@desc_fields = ["Date/Publication", "Title", "Description", "Author", "Maintainer"]
		@workers = []
		@worker_count = 4
		init_workers(@worker_count)
	end
	
	
	# initialize worker processes
	def init_workers(count)
		count.times do
			rd, wr = IO.pipe
			@workers << wr # master keeps the write end of the pipe
			if !fork
				require './lib/worker'
				worker = RPackageIndexer::Worker.new(rd) # worker receives the read end of the pipe
				worker.run # never ending loop
				break
			end
		end
	end
	
	# connects to the url and streams the package descriptions for indexing
	def index_http(host, force_fetch = false)
		@host = host
		@logger.info "Processing packages from #{host}"
		t = Time.now
		socket = TCPSocket.open(host, 80)
		socket.write(request(host, @packages_list_path))
		content_length = nil # add to closure
		@http_parser.on_headers_complete = proc do |env|
			#we now have the content length, use that to run through the stream
  		content_length = env["Content-Length"].to_i rescue nil
		end
		@http_parser << socket.gets(@headers_sep) # parse the headers
		processed = index(socket, content_length, force_fetch)
		socket.close		
		@logger.info "Processed #{processed} packages in #{Time.now - t} seconds"
	end
	
	#an alternative source for data
	def index_file(path, force_fetch = false)
		file = File.open(path, "r") do
			processed = index(file, file.size, force_fetch)
		end
	end
	
	# given an IO stream (File, Socket, StringIO, etc) this method will
	# run through the stream and extract package info, then will pass the
	# package info to the package indexing function, returns the number of
  # processed package infos
	def index(stream, length, force_fetch = false)
		processed_bytes = 0
		processed_packages = 0
		package_desc = ""
		while line = stream.gets
				if line != "\n"
					package_desc << line
				else
					#index_package package_desc, force_fetch
					@workers[processed_packages % @workers.length] << package_desc << @package_sep
					processed_packages = processed_packages + 1
					return 10 if processed_packages == 10 # for quick testing
					package_desc = ""
				end
				processed_bytes = processed_bytes + line.length
				break unless processed_bytes < length
		end
		processed_packages
	end
	 
	# helpers
	private
	
	def request(host, path)
		"GET #{path} HTTP/1.1#{@header_sep}Host: #{host}#{@headers_sep}"
	end
	
	def package_path(name, version)
		"#{@packages_path}#{name}_#{version}.tar.gz"
	end
	
	end
	
end
