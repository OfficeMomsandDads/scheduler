class Child < ApplicationRecord
  belongs_to :need, counter_cache: :number_of_children
  enum sex: { male: 0, female: 1 }

  validates :age, 
            :sex, 
             presence: true
end