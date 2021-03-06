FactoryBot.define do
  factory :announcement do
    message { "MyText" }
    user_ids { [create(:user).id] }
    association :author, factory: :admin
  end
end
