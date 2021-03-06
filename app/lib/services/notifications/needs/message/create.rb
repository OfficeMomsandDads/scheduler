# frozen_string_literal: true

module Services
  module Notifications
    class Needs
      class Message
        class Create
          include Adamantium::Flat
          include Concord.new(:need)
          include Rails.application.routes.url_helpers
          include StartAtHelper

          delegate :start_at,
                   to: :need

          def message
            "A new need starting #{starting_day} at #{start_time} has opened "\
              "up at your local office! #{url}".freeze
          end

          private

          def url
            need_url(need)
          end
        end
      end
    end
  end
end
