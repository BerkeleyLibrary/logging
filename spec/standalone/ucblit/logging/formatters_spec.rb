require 'standalone_helper'
require 'json'
require 'berkeley_library/logging'

module BerkeleyLibrary
  module Logging
    describe Formatters do
      describe :new_json_formatter do
        it 'supports tagged logging' do
          out = StringIO.new
          logger = Logger.new(out)
          logger.formatter = Formatters.new_json_formatter

          logger = ActiveSupport::TaggedLogging.new(logger)

          expected_tag = 'hello'
          expected_msg = 'this is a test'

          logger.tagged(expected_tag) { logger.info(expected_msg) }

          logged_json = JSON.parse(out.string)
          expect(logged_json['msg']).to eq(expected_msg)
          expect(logged_json['tags']).to eq([expected_tag])
        end
      end

      describe :ensure_hash do
        it 'returns an empty hash for nil' do
          expect(Formatters.ensure_hash(nil)).to eq({})
        end

        it 'returns the original hash for a hash' do
          original_hash = { a: 1, b: 2 }
          expect(Formatters.ensure_hash(original_hash)).to equal(original_hash)
        end

        it 'wraps anything else in a hash' do
          message = 'this is a message'
          expect(Formatters.ensure_hash(message)).to eq({ msg: message })
        end
      end
    end
  end
end
