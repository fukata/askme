require 'logger'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cross_origin'
require 'omniauth'
require 'omniauth-twitter'
require 'json'
require 'active_record'
require 'mysql2'

Dir[File.dirname(__FILE__)+"/models/*.rb"].each {|file| require file }

logger = Logger.new('log/app.log')

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :expire_after => 2592000, # In seconds
                           :secret => 'some_secret'

enable :cross_origin

WEB_ENDPOINT = ENV.fetch('WEB_ENDPOINT'){'http://localhost:3000'} unless defined?(WEB_ENDPOINT)

##############################################
# Configuration
##############################################

# database
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
  user.profile_image_url = auth.info.image
  user.last_logined_at = Time.current
  user.save!

  session[:user] = {
    id: user.id,
    username: user.username,
  }
  logger.debug "logined user=#{session[:user]}"
  redirect WEB_ENDPOINT
end

get "/auth/failure" do
  "FAILED"
end

##############################################
# Hook
##############################################
before do
  response.headers['Access-Control-Allow-Origin'] = "http://localhost:3000"
  response.headers["Access-Control-Allow-Credentials"] = "true"
end

# CORS
options "*" do
  response.headers["Allow"] = "GET, POST, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept"
  response.headers["Access-Control-Allow-Origin"] = "http://localhost:3000"
  200
end

##############################################
# Page
##############################################
get '/' do
  @user = User.where(id: session[:user][:id], deleted_at: nil).first if session[:user]
  erb :index
end

get '/logout' do
  session[:user] = nil
  redirect WEB_ENDPOINT
end

##############################################
# API
##############################################
get '/api/config' do
  content_type :json
  data = {
    env: ENV.fetch('RACK_ENV'){'development'},
  }
  @user = User.where(id: session[:user][:id], deleted_at: nil).first if session[:user]
  if @user
    data[:user] = {
      username: @user.username,
      profile_image: @user.profile_image_url,
    }
  end

  { data: data }.to_json
end

get '/api/users/:username' do |username|
  content_type :json

  user = User.where(username: username, deleted_at: nil).first
  if user
    {
      status: 'successful',
      user: {
        username: user.username,
        profile_image: user.profile_image_url.gsub(/normal\.jpg/, '400x400.jpg'), # デフォルトのサイズから400x400の画像URLに変換
      },
    }.to_json
  else
    status 404
    { status: 'failure' }.to_json
  end
end

post '/api/questions/:username' do |username|
  content_type :json
  begin
    params = JSON.parse(request.body.read, symbolize_names: true)
    logger.info "create question. to=#{username} comment=#{params[:comment]}, params=#{params}"
    user = User.where(username: username, deleted_at: nil).first
    if user
      logger.debug "create question. to=#{user.id}"
      Question.create!(user: user, comment: params[:comment])
    end

    { status: "successful" }.to_json
  rescue => e
    logger.error e
    status 500
    { status: "failed" }.to_json
  end
end
