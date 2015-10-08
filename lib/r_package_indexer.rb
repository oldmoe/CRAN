require 'socket'
require 'logger'
require 'http/parser'
require 'dcf'
require 'net/http'
require './models/r_package'
require 'rubygems/package'
require 'zlib'

class RPackageIndexer

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
		@logger.info "Processing packages from #{host}"
		file = File.open(path, "r") do
			processed = index(file, file.size, force_fetch)
		end
		@logger.info "Processed #{processed} packages in #{Time.now - t} seconds"
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
					index_package package_desc, force_fetch
					processed_packages = processed_packages + 1
					#return 10 if processed_packages == 10 # for quick testing
					package_desc = ""
				end
				processed_bytes = processed_bytes + line.length
				break unless processed_bytes < length
		end
		processed_packages
	end
	
	# uses a package description to index it
	def index_package(package_desc, force_fetch)
		key = Dcf.parse(package_desc)[0]
		package = RPackage.find(key["Package"], key["Version"])
		if !package or force_fetch 
			desc = fetch_package_description(package_path(key["Package"], key["Version"]))[0]
			data = {}
			@desc_fields.each{|f| data[f] = desc[f]}
			package = RPackage.new(key["Package"], key["Version"], data)
			package.save
		end
	end
	
	
	def fetch_package_description(path)
			data = Net::HTTP.get(@host, path)
			tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.new(StringIO.new(data)))
			tar_extract.rewind # The extract has to be rewinded after every iteration
			tar_extract.each do |entry|
				if entry.full_name.split("/").last == "DESCRIPTION"
				 data = entry.read
				 tar_extract.close
				 return Dcf.parse(data)
				end
			end
			tar_extract.close
			return {}
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
