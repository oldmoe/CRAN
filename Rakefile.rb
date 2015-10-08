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
	package = RPackage.new("oss", "3.0.1", {})
	package.save
	package = RPackage.new("oss", "3.1.2", {})
	package.save
	puts RPackage.find("oss", "3.0.3").nil?
	puts RPackage.find("oss", "3.0.1").name == "oss"
	puts RPackage.find("oss", "3.0.1").version == "3.0.1"
	puts RPackage.find("oss").collect{|p| p.version} == ["3.0.1", "3.1.2"]
	puts RPackage.all.length == 2
end


