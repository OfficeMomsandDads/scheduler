# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NeedPolicy do
  subject { described_class.new(user, record) }

  let(:creator) { build :user, role: 'social_worker' }
  let(:record) { create :need, user: creator }
  let(:user)   { build(:user) }

  context 'when for volunteers' do
    let(:user) { create :user, role: 'volunteer' }

    context 'when of the office' do
      before { record.office.users << user }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to forbid_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to permit_action(:mark_unavailable) }
      it { is_expected.to forbid_action(:view_responses) }

      describe '.scope' do
        it 'scopes the query' do
          expect(described_class::Scope.new(user.reload, Need.all).resolve)
            .to include(record)
        end
      end
    end

    context 'when not of the office' do
      it { is_expected.to permit_action(:index) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:mark_unavailable) }
      it { is_expected.to forbid_action(:view_responses) }

      describe '.scope' do
        it 'scopes the query' do
          expect(described_class::Scope.new(user.reload, Need.all).resolve)
            .not_to include(record)
        end
      end
    end
  end

  context 'when for social workers' do
    let(:user) { create :user, role: 'social_worker' }

    before { record.office.users << user }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:mark_unavailable) }
    it { is_expected.to permit_action(:view_responses) }

    describe '.scope' do
      it 'scopes the query' do
        expect(described_class::Scope.new(user.reload, Need.all).resolve)
          .to include(record)
      end
    end
  end

  context 'when for admins' do
    let(:user) { create(:user, role: 'admin') }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:mark_unavailable) }
    it { is_expected.to permit_action(:view_responses) }

    describe '.scope' do
      it 'scopes the query' do
        expect(described_class::Scope.new(user.reload, Need.all).resolve)
          .to match_array Need.all
      end
    end
  end

  describe '#index?' do
    it 'index?' do
      result = subject.index?

      expect(result).to be true
    end
  end

  describe '#show?' do
    it 'show?' do
      result = subject.show?

      expect(result).to be false
    end
  end

  describe '#create?' do
    it 'create?' do
      result = subject.create?

      expect(result).to be false
    end
  end

  describe '#new?' do
    it 'new?' do
      result = subject.new?

      expect(result).to be false
    end
  end

  describe '#edit?' do
    it 'edit?' do
      result = subject.edit?

      expect(result).to be false
    end
  end

  describe '#update?' do
    it 'update?' do
      result = subject.update?

      expect(result).to be false
    end
  end

  describe '#destroy?' do
    it 'destroy?' do
      result = subject.destroy?

      expect(result).to be false
    end
  end

  describe '#permitted_attributes_for_create' do
    it 'permitted_attributes_for_create' do
      result = subject.permitted_attributes_for_create

      expect(result).to be_an(Array)
    end
  end

  describe '#permitted_attributes' do
    it 'permitted_attributes' do
      result = subject.permitted_attributes

      expect(result).to be_an(Array)
    end
  end

end
