# frozen_string_literal: true

Time::DATE_FORMATS[:short_with_time] = ->(date) { date.strftime('%m/%d/%Y at %l:%M%p').squeeze(' ') }