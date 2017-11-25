require 'logger'
require 'sinatra'
require 'sinatra/reloader'
require 'omniauth'
require 'omniauth-twitter'

require 'active_record'
require 'mysql2'
require './models/user.rb'
require './models/question.rb'

logger = Logger.new('logs/app.log')

enable :sessions

##############################################
# Configuration
##############################################

# database
logger.debug "RACK_ENV=#{ENV.fetch('RACK_ENV'){'development'}}"
ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[ENV.fetch('RACK_ENV'){'development'}])

# oauth
# see http://tnakamura.hatenablog.com/entry/20120203/sinatra_omniauth
use OmniAuth::Builder do
  # Twitter の OAuth を使う
  provider :twitter, ENV.fetch('TWITTER_CONSUMER_KEY'), ENV.fetch('TWITTER_CONSUMER_SECRET')
end

get "/auth/:provider/callback" do
  auth = request.env["omniauth.auth"]
  logger.info auth.inspect
  user = User.where(twitter_account_id: auth.uid)
    .first_or_initialize(twitter_account_id: auth.uid, username: auth.info.nickname)
  user.last_logined_at = Time.current
  user.save!

  session[:user] = {
    id: user.id,
    username: user.username,
  }
  logger.debug "logined user=#{session[:user]}"
  redirect "/"
end

##############################################
# Page
##############################################
get '/' do
  @user = User.where(id: session[:user][:id], deleted_at: nil).first if session[:user]
  erb :index
end

get '/logout' do
  session.delete :user
  redirect '/'
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
