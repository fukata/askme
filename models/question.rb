class Question < ActiveRecord::Base
  validates :comment, presence: true, length: {maximum: 1000}
  belongs_to :user
end
