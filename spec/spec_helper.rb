require 'rack/test'
require 'rspec'
require 'factory_bot'
require 'database_cleaner'

ENV['RACK_ENV'] = 'test'
ENV['TWITTER_CONSUMER_KEY'] ||= ''
ENV['TWITTER_CONSUMER_SECRET'] ||= ''

require File.expand_path '../../app.rb', __FILE__

# For RSpec 2.x and 3.x
RSpec.configure do |config|
  include Rack::Test::Methods
  def app() Sinatra::Application end

  # see http://j-caw.co.jp/blog/?p=1042
  FactoryBot.definition_file_paths = %w{./factories ./test/factories ./spec/factories}
  FactoryBot.find_definitions

  # fix for
  # ActiveRecord::ConnectionNotEstablished:
  #   No connection pool with 'primary' found.
  ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
  ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[ENV.fetch('RACK_ENV'){'test'}])

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
