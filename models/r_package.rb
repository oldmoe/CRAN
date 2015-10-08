require 'lmdb'
require 'oj'

class RPackage

	SEP = '[:|:]'
	attr_accessor :name, :version, :data, :saved

	def initialize(name, version, data, saved = false)
		@name = name
		@version = version
		@data = data
		@saved = saved
	end
	
	def self.find(name, version = nil)
		if version
			if data = db.get(key(name, version))
				return RPackage.new(name, version, Oj.load(data), true)
			end 
		else
			results = []
			self.db.cursor do |cursor|
				record = cursor.set_range(name)
				if record && record[0].split(SEP)[0] == name
					results << record
					while record = cursor.next
						break unless record[0].split(SEP)[0] == name
						results << record
					end
				end
			end
			return results.collect do |rec| 	
				RPackage.new(name, rec[0].split(SEP)[1], Oj.load(rec[1]), true)
			end
		end
	end
	
	def self.all
		results = []
		self.db.cursor do |cursor|
			if record = cursor.first
				results << load(record)
				while record = cursor.next
					results << load(record)
				end
			end
		end
		results
	end

	def self.load(record)
		name, version = record[0].split(SEP)
		RPackage.new(name, version, Oj.load(record[1]), true)
	end
	
	def self.key(name, version)
		"#{name}#{SEP}#{version}"
	end
	
	def save
		self.class.db[self.class.key(@name, @version)] = Oj.dump(@data)
		@saved = true
	end
	
	def self.db
		@db ||= env.database('packages', :create => true)
	end
	
	def self.env
		@@env ||= LMDB.new("./db", :mapsize => 1024*1024*1024)
	end	
	
end

