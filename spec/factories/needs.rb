# frozen_string_literal: true

FactoryBot.define do
  factory :need do
    association :office, strategy: :build
    user { association :user, offices: [@instance.office], role: 'social_worker', strategy: :build }
    start_at { Time.zone.now }
    expected_duration { 120 }
    preferred_language_id { 1 }
    transient do
      children_count { 1 }
    end

    after(:build) do |need, evaluator|
      need.age_ranges << build(:age_range)

      evaluator.children_count.times do
        need.children << build(:child)
      end
    end

    factory :need_with_shifts do

      after(:create) do |need|
        create_list(:shift, need.expected_duration / 60, need: need)
      end
    end
  end
end
