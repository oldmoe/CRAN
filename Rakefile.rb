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

task :test_packages do
	require './models/r_package'
	package = RPackage.new(RPackage.key("oss", "3.0.1"), {"Package" => "oss", "Version" => "3.0.1"})
	package.save
	package = RPackage.new(RPackage.key("oss", "3.1.2"), {"Package" => "oss", "Version" => "3.1.2"})
	package.save
	puts RPackage.find(RPackage.key("oss", "3.0.3")).nil?
	p RPackage.find(RPackage.key("oss", "3.0.1"))
	puts RPackage.find(RPackage.key("oss", "3.0.1")).data["Package"] == "oss"
	puts RPackage.find(RPackage.key("oss", "3.0.1")).data["Version"] == "3.0.1"
	puts RPackage.find_partial("oss").collect{|p| p.data["Version"]} == ["3.0.1", "3.1.2"]
	puts RPackage.all.length == 2
end


