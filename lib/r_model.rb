require 'lmdb'
require 'oj'

class RModel

	attr_accessor :key, :data, :saved

	def initialize(key, data, saved = false)
		@key = key
		@data = data
		@saved = saved
	end
	
	def self.find(id)
		if data = self.db.get(id)
			return self.new(id, Oj.load(data), true)
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
		self.new(record[0], Oj.load(record[1]), true)
	end
	
		
	def save
		self.class.db[@key] = Oj.dump(@data)
		@saved = true
	end
	
	def self.db
		@db ||= env.database(self.class.name.downcase, :create => true)
	end
	
	def self.env
		return @@env rescue nil
		@@env = LMDB.new("./db", :mapsize => 1024*1024*1024)
		at_exit { @@env.close } # cleanup after yourself
		@@env
	end	
	
end

