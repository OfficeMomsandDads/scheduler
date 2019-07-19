# frozen_string_literal: true

module Services
  class BuildNeedShifts
    include Procto.call
    include Concord.new(:need)
    include Adamantium::Flat

    SHIFT_LENGTH = 60

    delegate :duration, :start_at, to: :need

    def call
      calculate_shift_lengths.map.with_index do |length, index|
        Shift.new(
          start_at: start_at.advance(minutes: SHIFT_LENGTH * index),
          duration: length
        )
      end
    end

    private

    def calculate_shift_lengths
      shift_count = duration / SHIFT_LENGTH
      Array.new(shift_count) do |i|
        next SHIFT_LENGTH unless i.equal?(shift_count - 1)

        SHIFT_LENGTH + (duration % SHIFT_LENGTH)
      end
    end
  end
end
