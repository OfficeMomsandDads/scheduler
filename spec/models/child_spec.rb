# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Child, type: :model do
  let(:need) { build :need }
  let(:child) { build :child, need: need }

  it 'has a valid factory' do
    expect(child.valid?).to be(true)
  end
end
