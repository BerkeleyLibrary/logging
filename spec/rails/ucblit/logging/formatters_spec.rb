require 'rails_helper'
require 'json'
require 'colorize'
require 'berkeley_library/logging'

module BerkeleyLibrary
  module Logging
    describe Formatters do
      describe :new_json_formatter do
        attr_reader :out, :logger

        before do
          @out = StringIO.new
          @logger = Logger.new(out)
          logger.formatter = Formatters.new_json_formatter
        end

        it 'supports tagged logging' do
          tagged_logger = ActiveSupport::TaggedLogging.new(logger)

          expected_tag = 'hello'
          expected_msg = 'this is a test'

          tagged_logger.tagged(expected_tag) { tagged_logger.info(expected_msg) }

          logged_json = JSON.parse(out.string)
          expect(logged_json['msg']).to eq(expected_msg)
          expect(logged_json['tags']).to eq([expected_tag])
        end

        it 'decolorizes ANSI-colored strings' do
          colors = %i[red green yellow blue magenta cyan]
          colorized_string = colors.map { |c| c.to_s.colorize(c) }.join(' ')
          expect(colorized_string).to include("\u001b") # just to be sure

          expected_string = colors.map(&:to_s).join(' ')

          logger.info(colorized_string)
          logged_json = JSON.parse(out.string)
          msg = logged_json['msg']
          expect(msg).not_to include("\u001b")
          expect(msg).to eq(expected_string)
        end

        it 'decolorizes ANSI-colored strings in attached data' do
          colors = %i[red green yellow blue magenta cyan]
          colorized_string = colors.map { |c| c.to_s.colorize(c) }.join(' ')
          expect(colorized_string).to include("\u001b") # just to be sure

          expected_string = colors.map(&:to_s).join(' ')

          data = {
            the_string: colorized_string,
            additional_data: {
              not_a_string: 12,
              another_string: colorized_string,
              more_strings: [colorized_string, colorized_string]
            }
          }
          logger.info('a colorized string', data)

          logged_json = JSON.parse(out.string)
          data = logged_json
          expect(data['the_string']).to eq(expected_string)
          additional_data = data['additional_data']
          expect(additional_data['not_a_string']).to eq(12)
          expect(additional_data['another_string']).to eq(expected_string)
          expect(additional_data['more_strings']).to eq([expected_string, expected_string])
        end

        # rubocop:disable Layout/LineLength
        it 'removes ANSI formatting from ActiveRecord logs' do
          original = "  \e[1m\e[36mLendingItem Load (2.0ms)\e[0m  \e[1m\e[34mSELECT \"lending_items\".* FROM \"lending_items\" WHERE \"lending_items\".\"directory\" = $1 LIMIT $2\e[0m  [[\"directory\", \"b135297126_C068087930\"], [\"LIMIT\", 1]]"
          expected = '  LendingItem Load (2.0ms)  SELECT "lending_items".* FROM "lending_items" WHERE "lending_items"."directory" = $1 LIMIT $2  [["directory", "b135297126_C068087930"], ["LIMIT", 1]]'
          logger.info(original)
          logged_json = JSON.parse(out.string)
          msg = logged_json['msg']
          expect(msg).to eq(expected)
        end
        # rubocop:enable Layout/LineLength
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
