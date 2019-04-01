# frozen_string_literal: true

class Office < ApplicationRecord
  has_one :address, as: :addressable
  has_and_belongs_to_many :users
  has_many :needs, dependent: :destroy
  validates :name, :address, presence: true
  validates :region, numericality: { only_integer: true }

  accepts_nested_attributes_for :address, update_only: true

  def skip_confirmation
    !!address&.send(:skip_api_validation)
  end

  def skip_confirmation!
    address.skip_api_validation!
  end
end
