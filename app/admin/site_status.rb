# frozen_string_literal: true

ActiveAdmin.register_page 'Site Status' do

  page_action :update_site_status, method: :post do
    if params[:need_creation_disabled].present?
      redis.set('need_creation_disabled', true)
    else
      redis.del('need_creation_disabled')
    end

    redis.set('need_creation_disabled_msg', params[:need_creation_disabled_msg])

    flash[:notice] = 'Updated site status'

    redirect_to "/admin/site_status"
  end

  content do
    form action: "site_status/update_site_status", method: :post do |f|
      f.input name: :need_creation_disabled, id: :need_creation_disabled, type: :checkbox, checked: need_creation_disabled?
      f.label 'Need creation disabled', for: :need_creation_disabled

      f.label 'Message', for: :need_creation_disabled_msg, style: 'display: block;'
      f.textarea redis.get('need_creation_disabled_msg'), name: :need_creation_disabled_msg, id: :need_creation_disabled_msg, :rows => 5, style: 'width: 400px;'

      f.input :submit, type: :submit, style: 'display: block;'
    end
  end

  controller do
    skip_before_action :verify_authenticity_token
  end
end
