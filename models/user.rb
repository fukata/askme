class User < ActiveRecord::Base
  validates_uniqueness_of :username
  validates_uniqueness_of :twitter_account_id, if: proc{|a| a.twitter_account_id.present?}
  has_many :questions
end
