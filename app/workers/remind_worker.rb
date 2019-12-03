class RemindWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  def perform
    needs = Need.joins(:shifts).
      where("shifts.created_at < ?", 1.hour.ago).
      where("shifts.start_at > ?", Time.now).
      where("shifts.user_id IS NULL").distinct
    needs.each do |need|
      recipients = need.users_pending_response
      if recipients.any?
        phone_numbers = recipients.map(&:phone)
        message = "A need still has available shifts #{need_url(need)}"
        Services::TextMessageEnqueue.send_messages(phone_numbers, message)
      end
    end
  end
end

Sidekiq::Cron::Job.create(
  name: 'Reminders', cron: '0 9-20 * * *', class: 'RemindWorker'
)