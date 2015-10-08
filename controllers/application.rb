require 'sinatra'
require './models/r_package'

set :views, settings.root + '/../views'

get '/' do
	@title = "Packages"
	@packages = RPackage.all
	erb :packages
end

get '/packages/:name' do
	@title = params[:name]
	@packages = RPackage.find_partial(params[:name])
	erb :packages
end

get '/packages/:name/:version' do
	@title = "#{params[:name]} version #{params[:version]}"
	puts RPackage.key(params[:name], params[:version])
	@package = RPackage.find(RPackage.key(params[:name], params[:version]))
	p @package
	erb :package
end

get '/authors/:name' do
	@contributor = RContributor.find(params[:name])
	erb :author
end

get '/contributors/:name' do

end


