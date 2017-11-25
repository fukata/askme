require 'logger'
require 'sinatra'
require 'sinatra/reloader'
require 'omniauth'
require 'omniauth-twitter'
require 'json'
require 'active_record'
require 'mysql2'

Dir[File.dirname(__FILE__)+"/models/*.rb"].each {|file| require file }

logger = Logger.new('log/app.log')

enable :sessions

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
post '/api/questions' do
  content_type :json
  begin
    logger.info "create question. to=#{params[:to_username]} commnet=#{params[:comment]}"
    user = User.where(username: params[:to_username], deleted_at: nil).first
    if user
      logger.debug "create question. to=#{user.id}"
      user.questions.build(comment: params[:comment])
      user.save!
    end

    { status: "successful" }.to_json
  rescue => e
    { status: "failed" }.to_json
  end
end
