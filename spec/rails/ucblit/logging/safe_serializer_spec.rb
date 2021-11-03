require 'rails_helper'

require 'active_support/time'

module BerkeleyLibrary
  module Logging
    describe SafeSerializer do
      describe :serialize do
        it 'handles ActiveSupport::TimeWithZone' do
          Time.zone = 'America/Los_Angeles'

          t = Time.current
          expect(t).to be_a(ActiveSupport::TimeWithZone) # just to be sure

          expect(SafeSerializer.serialize(t)).to be(t)

          h = { time: t }
          expect(SafeSerializer.serialize(h)).to eq(h)
        end
      end
    end
  end
end
