require './lib/r_model'
require './models/r_contributor_email'

class RContributor < RModel

	def initialize(key, data=nil, saved = false)
		@key = key
		@data = data || {"authored"=>[], "maintained"=>[]}
		@saved = saved
	end
	
	def authored
		data["authored"]
	end
	
	def maintained
		data["maintained"]
	end
	
	def self.authored(key, package, email = nil)
			data = db.get(key)
			data = Oj.load(data) if data
			c = RContributor.new(key, data)
			c.authored << package
			c.data["email"] = email if email
			c.save
	end 
	
	def self.maintained(key, package, email = nil)
			data = db.get(key)
			data = Oj.load(data) if data
			c = RContributor.new(key, data)
			c.maintained << package
			c.data["email"] = email if email
			c.save
	end
	
	def self.find_by_email(email)
		if record = RContributorEmail.find(email)
			self.find(record.data)
		end
	end
	
	def save
		if data["email"]
			RContributorEmail.new(data["email"], key).save	
		end
		super
	end
	
end

