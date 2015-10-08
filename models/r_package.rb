require './lib/r_model'
require './models/r_contributor'

class RPackage < RModel

	SEP = '[:|:]'

	def dependencies
		@data["Depends"].split(",").collect{|d| d.split(" ")}
	end
	
	def authors
		@data["Author"].sub(' and ', ', ').split(", ").collect{|a| a.trim.split(' ')}
	end
	
	def maintainers
		@data["Maintainer"].sub(' and ', ', ').split(", ").collect{|m| m.trim.split(' ')}
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
		def authors.each do |a|
			Contributor.authored(a[0], @key, a[1])
		end
		def maintainers.each do |a|
			Contributor.maintained(a[0], @key, a[1])
		end
		super
	end
	
end

