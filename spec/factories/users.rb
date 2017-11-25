FactoryBot.define do
  factory :user do
    sequence(:username) {|n| "name#{n}"}
    sequence(:twitter_account_id) {|n| "u#{n}"}
    last_logined_at { Time.current }
  end
end
