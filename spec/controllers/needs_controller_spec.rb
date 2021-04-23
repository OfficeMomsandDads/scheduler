# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NeedsController, type: :controller do
  let(:user) { need.user }
  let(:need) { create(:need_with_shifts) }

  before { sign_in user }

  describe '#index' do
    let!(:tomorrow_need) do
      create(:need, start_at: 1.day.from_now, user: user, office: need.office)
    end
    let!(:yesterday_need) { create(:need, start_at: 1.day.ago) }

    it 'returns ok' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(assigns(:needs).to_a).to eql([need, tomorrow_need])
    end

    context 'when a date is provided' do
      subject { get :index, params: { date: Date.current.yesterday.to_s } }

      it 'ignores date and returns normal result' do
        subject
        expect(assigns(:needs).to_a).to eql([need, tomorrow_need])
      end

      context 'when user is an admin' do
        let(:user) { create(:user, role: 'admin') }

        it 'returns appropriate needs for that date' do
          subject
          expect(assigns(:needs).to_a).to eql([yesterday_need])
        end
      end
    end
  end

  describe '#show' do
    it 'returns ok and sets expected variables' do
      get :show, params: { id: need.id }
      expect(response).to have_http_status(:ok)
      expect(flash[:alert]).to be nil
    end
  end

  describe '#create' do
    it 'POST create' do
      expect do
        post :create, params: {
          need: { children_attributes:   [{ age: 5, sex: 'female' }],
                  expected_duration:     2,
                  start_at:              Time.zone.now.advance(weeks: 1).to_param,
                  office_id:             need.office_id.to_param,
                  age_range_ids:         [AgeRange.first!.id],
                  preferred_language_id: 1 }
        }
      end.to change(Need, :count).by(1)

      expect(response).to have_http_status(:found)
    end
  end

  describe '#edit' do
    it 'GET edit' do
      get :edit, params: { id: need.id }

      expect(response).to have_http_status(:ok)
    end
  end

  describe '#update' do
    it 'PATCH update' do
      expect { 
        patch :update, params: { id: need.id, need: { notes: 'Foobar' } }
      }.to change { need.reload.notes }.to('Foobar')
      expect(response).to have_http_status(:found)
    end
  end

  describe '#destroy' do
    it 'DELETE destroy' do
      delete :destroy, params: { id: need.id }

      expect(response).to have_http_status(:found)
      expect { need.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#mark_unavailable' do
    subject { patch :mark_unavailable, params: { id: need.id } }

    it { is_expected.to redirect_to(need) }
  end
end
