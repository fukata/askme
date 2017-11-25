require 'sinatra'
require 'sinatra/reloader'

##############################################
# Page
##############################################
get '/' do
  erb :index
end

get '/logout' do
  'logout'
end

##############################################
# API
##############################################
post '/api/users' do
  '/api/users'
end

post '/api/questions' do
  '/api/questions'
end
