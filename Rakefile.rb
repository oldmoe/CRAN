require 'bundler/setup'

task :test_cron do
	puts "hello from cron at #{Time.now}"
end

task :run_indexer do
	require './lib/r_package_indexer'
	indexer = RPackageIndexer::Master.new
	indexer.index_http('cran.r-project.org')
end

task :reindex do
	require './lib/r_package_indexer'
	indexer = RPackageIndexer.new
	indexer.index_http('cran.r-project.org', true)
end

task :test_models do
	require './models/r_package'
	package = RPackage.new(RPackage.key("oss", "3.0.1"), {"Package" => "oss", "Version" => "3.0.1"}).save
	package = RPackage.new(RPackage.key("oss", "3.1.2"), {"Package" => "oss", "Version" => "3.1.2"}).save
	puts RPackage.find(RPackage.key("oss", "3.0.3")).nil?
	puts RPackage.find(RPackage.key("oss", "3.0.1")).data["Package"] == "oss"
	puts RPackage.find(RPackage.key("oss", "3.0.1")).data["Version"] == "3.0.1"
	puts RPackage.find_partial("oss").collect{|p| p.data["Version"]} == ["3.0.1", "3.1.2"]
	puts RPackage.all.length == 2
  pack = RPackage.new(RPackage.key("oss", "3.0.1"), {"Package" => "abc", "Version" => "3.0.0", "Author" => "David, Ossama, Rafael <rafael@rafael.com>, Timothy <tim@thy.com>", "Maintainer" => "Michael, Ossama, Timothy <tim@thy.com>"})
	p pack.maintainers
	pack.save
	puts RContributor.all.length == 5
	puts RContributor.find("Timothy").data["email"] == "<tim@thy.com>"
	p RContributor.find_by_email("<tim@thy.com>") #.key == "Timothy" 
end


