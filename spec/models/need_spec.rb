# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Need, type: :model do
  let(:need) { create(:need) }
  let(:shift) { create(:shift, need: need) }
  let(:english) { Language.find_by!(name: 'English') }
  let(:new_user) { create(:user) }

  it 'has a valid factory' do
    expect(need.valid?).to be(true)
  end

  describe '#effective_start_at' do
    it 'returns need start at if no shifts' do
      result = need.effective_start_at

      expect(result).to eql(need.start_at)
    end

    it 'returns need start at if no shifts are earlier' do
      need.shifts << build(:shift, start_at: need.start_at)

      result = need.effective_start_at

      expect(result.to_s(:db)).to eql(need.start_at.to_s(:db))
    end

    it 'returns earliest shift start at if earlier than need start at' do
      starts = need.start_at.advance(hours: -1)
      need.shifts << build(:shift, start_at: starts)
      need.save!

      result = need.effective_start_at

      expect(result.to_s(:db)).to eql(starts.to_s(:db))
    end
  end

  describe '.current' do # scope test
    it 'supports named scope current' do
      expect(described_class.limit(3).current).to all(be_a(described_class))
    end
  end

  context 'when reporting' do
    let(:wa_address1) { build(:address, :wa) }
    let(:wa_address2) { build(:address, :wa, county: 'Lewis') }
    let(:wa_office1) { create(:wa_office, address: wa_address1) }
    let(:wa_office2) { create(:wa_office, address: wa_address2) }
    let(:or_office) { create(:or_office) }
    let(:wa_sw1) { create(:user, role: 'social_worker', offices: [wa_office1]) }
    let(:wa_sw2) { create(:user, role: 'social_worker', offices: [wa_office2]) }
    let(:or_sw) { create(:user, role: 'social_worker', offices: [or_office]) }
    let(:wa_user1) { create(:user, offices: [wa_office1]) }
    let(:wa_user2) { create(:user, offices: [wa_office2]) }
    let(:or_user) { create(:user, offices: [or_office]) }
    let(:wa_need1) do
      create(:need_with_shifts,
             user:               wa_sw1,
             children_count:     1,
             expected_duration:  120,
             office:             wa_office1)
    end
    let(:wa_need2) do
      create(:need_with_shifts,
             user:               wa_sw2,
             children_count:     2,
             expected_duration:  240,
             office:             wa_office2)
    end
    let!(:unmet_wa_need) do
      create(:need_with_shifts,
             user:               wa_sw2,
             children_count:     2,
             expected_duration:  120,
             office:             wa_office2)
    end
    let(:or_need) do
      create(:need_with_shifts,
             user:               or_sw,
             children_count:     3,
             expected_duration:  120,
             office:             or_office)
    end

    before do
      or_need.shifts.first.update(user: or_user) # 3 child served
      wa_need1.shifts.first.update(user: wa_user1) # 1 child served
      wa_need1.shifts.last.update(user: wa_user2) # 1 child served
      wa_need2.shifts.update_all(user_id: wa_user2.id) # 2 child served (total of 3)
    end

    describe '.total_children_served' do
      it 'returns the total number of children served' do
        expect(described_class.total_children_served)
          .to eql(wa_need1.number_of_children +
                    wa_need2.number_of_children +
                    or_need.number_of_children)
      end
    end
  end

  describe '#preferred_language' do
    it 'is a Language' do
      result = need.preferred_language

      expect(result).to be_an_instance_of(Language)
    end

    it 'can be set to English' do
      need.preferred_language = english

      result = need.preferred_language

      expect(result).to eql(english)
    end
  end

  describe '#end_at' do
    it 'end_at' do
      result = need.end_at

      expect(result).to be_within(5.seconds).of(Time.zone.now.advance(hours: 2))
    end
  end

  describe '#expired?' do
    it 'expired?' do
      result = need.expired?

      expect(result).to be false
    end

    it 'returns true if expired' do
      need.start_at = Time.zone.now.advance(hours: -3)

      result = need.expired?

      expect(result).to be true
    end
  end

  describe '#notification_candidates' do
    subject { need.notification_candidates }

    context 'when user is not in office' do
      it { is_expected.to be_empty }
    end

    context 'when user is in office' do
      before { need.office.users << new_user }

      it { is_expected.to eq([new_user]) }

      context 'when user has already been notified' do
        before { need.update notified_user_ids: [new_user.id] }

        it { is_expected.to eq([new_user]) }
      end

      context 'when user has marked themselves unavailable' do
        before { need.update unavailable_user_ids: [new_user.id] }

        it { is_expected.to be_empty }
      end
    end
  end

  describe '#users_to_notify' do
    it 'returns only the need user if there are no shifts' do
      result = need.users_to_notify

      expect(result).to eq([need.user])
    end

    it 'returns shift users and the need user' do
      need.office.users << new_user
      need.shifts << shift
      new_user.age_ranges << shift.age_ranges

      result = need.users_to_notify

      expect(result.to_a).to eq([new_user, need.user])
    end
  end

  describe '.has_claimed_shifts' do # scope test
    it 'supports named scope has_claimed_shifts' do
      result = described_class.has_claimed_shifts

      expect(result).to all(be_an_instance_of(described_class))
    end
  end

  describe '#unavailable_users' do
    subject { need.unavailable_users }

    before { need.update(unavailable_user_ids: [new_user.id]) }

    it { is_expected.to eq([new_user]) }
  end

  describe '#users_pending_response' do
    subject { need.users_pending_response }

    let(:unavailable_user) { create(:user) }
    let(:accepted_user) { create(:user, shifts: [shift]) }
    let(:pending_user) { create(:user) }

    before do
      need.update!(
        unavailable_user_ids: [unavailable_user.id],
        notified_user_ids:    [unavailable_user.id, accepted_user.id, pending_user.id]
      )
    end

    it { is_expected.to eq([pending_user]) }
  end

  describe 'validates :intentional_start_at' do
    before { need.start_at = '' }

    it 'falls back to presence validation when start_at is blank' do
      expect(need.valid?).to be false
    end
  end

  describe 'validates :intentional_start_at' do
    before { need.start_at = need.start_at.midnight }

    it 'adds a validation error when start_at is midnight' do
      expect(need.valid?).to be false
      expect(need.errors[:start_at]).to eq ['must not be midnight']
    end
  end
end
