require 'socket'
require 'logger'
require 'http/parser'
require 'dcf'
require 'net/http'
require './models/r_package'
require 'rubygems/package'
require 'zlib'

module RPackageIndexer

	class Worker

	# nothing to do here for the moment, could be used later for initial settings
	def initialize(inpipe)
		@header_sep = "\r\n"
		@headers_sep = "\r\n\r\n"
		@package_sep = "\n"
		@http_parser = Http::Parser.new
		@packages_path = "/src/contrib/" 
		@packages_list_path = "#{@packages_path}PACKAGES"
		@logger = Logger.new(STDOUT)
		@key_fields = ["Package", "Version"]
		@desc_fields = ["Date/Publication", "Title", "Description", "Author", "Maintainer"]
		@inpipe = inpipe
	end
	
	#loop forever and recieve indexing requests from your parent
	def run
		loop do
			package_desc = @inpipe.gets("\n\n")
			puts package_desc
			index_package(package_desc)
		end
	end
		
	# uses a package description to index it
	def index_package(package_desc, force_fetch = false)
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
	
end