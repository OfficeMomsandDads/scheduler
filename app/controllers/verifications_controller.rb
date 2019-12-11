class VerificationsController < ApplicationController
  VERIFY_SID = Rails.application.credentials.twilio[:verify_sid]
  skip_before_action :enforce_verification

  def index
  end

  def send_code
    $twilio.verify.services(VERIFY_SID).verifications.
      create(to: current_user.e164_phone, channel: 'sms')
    redirect_to verify_path, flash: { notice: 'Verification code has been sent' }
  end

  def check_code
    code = params[:code]
    check = $twilio.verify.services(VERIFY_SID).verification_checks.
      create(to: current_user.e164_phone, code: code)
    if check.status == 'approved'
      current_user.update(verified: true)
      flash[:notice] = 'Phone number has been verified!'
      redirect_to root_path
    else
      flash[:notice] = 'Verification failed'
      redirect_to verify_path
    end
  end
end
