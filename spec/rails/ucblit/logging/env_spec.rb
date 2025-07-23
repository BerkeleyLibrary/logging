require 'rails_helper'

module BerkeleyLibrary
  describe Logging do

    attr_reader :orig_rails_env

    before do
      @orig_rails_env = Rails.env
    end

    after do
      Rails.env = orig_rails_env
    end

    describe :env= do
      it 'sets Rails.env' do
        expect(defined?(Rails)).to be_truthy # just to be sure
        Logging.env = 'elvis'
        expect(Rails.env).to eq('elvis')
        expect(Rails.env.elvis?).to be(true)
      end
    end
  end
end
