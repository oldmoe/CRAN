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
	@packages = RPackage.find(params[:name])
	erb :packages
end

get '/packages/:name/:version' do
	@title = "#{params[:name]} version #{params[:version]}"
	@package = RPackage.find(params[:name], params[:version])
	p @package
	erb :package
end


