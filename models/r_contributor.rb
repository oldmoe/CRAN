require './lib/r_model'
require './models/r_contributior_email'

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
			c = RContributor.new(key, data)
			c.authored << package
			c.data["email"] = email if email
			c.save
	end 
	
	def self.maintained(key, package, email = nil)
			data = db.get(key)
			c = RContributor.new(key, data)
			c.maintained << package
			c.data["email"] = email if email
			c.save
	end
	
	def self.find_by_email(email)
		if name = RContributorEmail.find(email)
			self.find(name)
		end
	end
	
	def save
		if data["email"]
			RContributorEmail.new(data["email"], key).save	
		end
		super
	end
	
end

