# frozen_string_literal: true

class AgeRange < ApplicationRecord
  validates :min, :max, presence: true, numericality: { only_integer: true }
  validates :max,
            numericality: { greater_than_or_equal_to: :min,
                            message:                  'must be greater than or equal to min age' }
  has_and_belongs_to_many :users

  def to_s
    "#{min}-#{max}"
  end
end
