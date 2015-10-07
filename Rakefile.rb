require 'socket'
require 'bundler/setup'
require './lib/r_package_indexer'


task :run_http_indexer do
	indexer = RPackageIndexer.new
	indexer.index_http('cran.r-project.org')
end

task :test do

end
