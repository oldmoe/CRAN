require './lib/r_model'
require './models/r_contributor'

class RPackage < RModel

	SEP = '[:|:]'

	def dependencies
		if @data["Depends"]
			@data["Depends"].split(",").collect{|d| d.split(" ")}
		end
	end
	
	def authors
		if @data["Author"]
				@data["Author"].sub(' and ', ', ').split(", ").collect{|a| a.split(' ')} 
		else
			[]
		end
	end
	
	def maintainers
		if @data["Maintainer"]
				@data["Maintainer"].sub(' and ', ', ').split(", ").collect{|m| m.split(' ')} 
		else
			[]
		end
	end

	def self.find_partial(partial_key)
			results = []
			self.db.cursor do |cursor|
				record = cursor.set_range(partial_key)
				if record && record[0].split(SEP)[0] == partial_key
					results << record
					while record = cursor.next
						break unless record[0].split(SEP)[0] == partial_key
						results << record
					end
				end
			end
			return results.collect do |rec| 	
				RPackage.new(rec[0], Oj.load(rec[1]), true)
			end		
	end

		
	def self.key(name, version)
		"#{name}#{SEP}#{version}"
	end

	def save
=begin
		authors.each do |a|
			RContributor.authored(a[0], @key, a[1])
		end
		maintainers.each do |a|
			RContributor.maintained(a[0], @key, a[1])
		end
=end
		super
	end
	
end

