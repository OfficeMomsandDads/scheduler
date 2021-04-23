# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Needs', type: :request do
  let(:need) { create :need }

  before { sign_in need.user }

  describe '#index' do
    it 'is successful' do
      get needs_path

      expect(response).to be_successful
    end
  end

  describe '#show' do
    it 'is successful' do
      get need_path(need)

      expect(response).to be_successful
    end

    it 'fails' do
      get need_path('foobar')

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eql("Sorry, we couldn't find that need.")
    end
  end

  describe '#new' do
    it 'is successful' do
      get new_need_path

      expect(response).to be_successful
    end

    context 'when need creation is disabled' do
      before do
        allow_any_instance_of(NeedsController).to receive(:need_creation_disabled?).and_return(true)
      end

      it 'redirects to the root path' do
        get new_need_path
        expect(response).to be_redirect
      end
    end
  end

  describe '#create' do
    context 'when success' do
      let(:params) do
        {
          need: attributes_for(:need).merge(office_id:     need.office_id,
                                            age_range_ids: [AgeRange.first.id],
                                            children_attributes: [{age: 5, sex: 'female'}])
        }
      end

      it 'is redirects to the need' do
        expect(Services::BuildNeedShifts).to receive(:call).and_return([]).once
        expect(Services::TextMessageEnqueue)
          .to receive(:send_messages).once.with(Array, String)

        post needs_path, params: params

        expect(response).to redirect_to(assigns(:need))
      end
    end

    context 'when failure' do
      it 'renders the new view' do
        expect_any_instance_of(Need).to receive(:valid?).and_return(false)

        post needs_path,
             params: { need: attributes_for(:need)
                               .merge(office_id: need.office_id) }

        expect(response).to render_template(:new)
      end
    end
  end

  describe '#edit' do
    it 'is successful' do
      get edit_need_path(need)

      expect(response).to be_successful
    end
  end

  describe '#update' do
    context 'when success' do
      it 'redirects to the need' do
        expect(Services::TextMessageEnqueue)
          .to receive(:send_messages).once.with(Array, String)

        put need_path(need), params: { need: { children_count: 20 } }

        expect(response).to redirect_to(assigns(:need))
      end
    end

    context 'when failure' do
      it 'renders the edit view' do
        expect_any_instance_of(Need).to receive(:save).and_return(false)

        put need_path(need), params: { need: { children_count: 20 } }

        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#destroy' do
    context 'when success' do
      it 'redirects to the index view with success message' do
        expect(Services::TextMessageEnqueue)
          .to receive(:send_messages).once.with(Array, String)

        delete need_path(need)

        expect(response).to redirect_to(needs_path)
        expect(flash[:success]).to eql('Need successfully deleted')
      end
    end

    context 'when failure' do
      it 'redirects to the index view' do
        expect_any_instance_of(Need).to receive(:destroy).and_return(false)

        delete need_path(need)

        expect(response).to redirect_to(needs_path)
        expect(flash[:error]).to eql('Failed to delete Need')
      end
    end
  end
end
