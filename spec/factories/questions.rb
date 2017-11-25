FactoryBot.define do
  factory :question do
    sequence(:comment) {|n| "comment #{n}"}
  end
end
