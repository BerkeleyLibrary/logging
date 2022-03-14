require 'standalone_helper'

module BerkeleyLibrary
  module Logging
    describe SafeSerializer do
      describe :serialize do
        it 'returns primitives unchanged' do
          values = [
            nil,
            false,
            true,
            1,
            1.0,
            '1/3'.to_r,
            'a string',
            :a_symbol,
            Date.today,
            Time.now
          ]

          aggregate_failures do
            values.each do |original|
              actual = SafeSerializer.serialize(original)
              expect(actual).to be(original)
            end
          end
        end

        it 'returns an object as a string' do
          value = Object.new
          expect(SafeSerializer.serialize(value)).to eq(value.to_s)
        end

        it 'returns a hash as a hash' do
          hash = { a: 1, b: 2 }
          expect(SafeSerializer.serialize(hash)).to eq(hash)
        end

        it 'returns an array as an array' do
          arr = [0, 1, 2, 'elvis', false]
          expect(SafeSerializer.serialize(arr)).to eq(arr)
        end

        it 'cleans nested values' do
          b_value = Object.new
          c_key = Object.new
          d_value = Object.new

          d_array = ['d', :d, { d: "\ud7ff", 'd' => d_value }]

          h = {
            a: 1,
            b: b_value,
            c_key => 'c value',
            0xd => d_array,
            "\uEEEE" => 0xe
          }

          expected = {
            a: 1,
            b: b_value.to_s,
            c_key.to_s => 'c value',
            0xd => ['d', :d, { d: "\ud7ff", 'd' => d_value.to_s }],
            "\uEEEE" => 0xe
          }

          actual = SafeSerializer.serialize(h)
          expect(actual).to eq(expected)
        end

        it 'handles recursive structures' do
          a = []
          h = { a: a }
          a << h

          h_expected = { a: [SafeSerializer.placeholder_for(h)] }
          a_expected = [{ a: SafeSerializer.placeholder_for(a) }]

          expect(SafeSerializer.serialize(h)).to eq(h_expected)
          expect(SafeSerializer.serialize(a)).to eq(a_expected)
        end

        context 'exceptions' do
          # rubocop:disable Lint/ConstantDefinitionInBlock
          before do
            class ::TestError < StandardError
              attr_writer :cause

              def cause
                @cause || super
              end
            end
          end
          # rubocop:enable Lint/ConstantDefinitionInBlock

          after do
            Object.send(:remove_const, :TestError)
          end

          # rubocop:disable Naming/RescuedExceptionsVariableName
          it 'handles exceptions' do
            msg_outer = 'Help I am trapped in the outer part of a unit test'
            msg_inner = 'Help I am trapped in the inner part of a unit test'

            begin
              raise TestError, msg_inner
            rescue TestError => ex_inner
              begin
                raise TestError, msg_outer
              rescue TestError => ex_outer
                ex_inner.cause = ex_outer
              end
            end

            expect(ex_outer.cause).to eq(ex_inner) # just to be sure
            expect(ex_inner.cause).to eq(ex_outer) # just to be sure

            expected = {
              name: 'TestError',
              message: msg_outer,
              stack: ex_outer.backtrace,
              cause: {
                name: 'TestError',
                message: msg_inner,
                stack: ex_inner.backtrace
              }
            }

            expect(SafeSerializer.serialize(ex_outer)).to eq(expected)
          end
          # rubocop:enable Naming/RescuedExceptionsVariableName

        end
      end
    end
  end
end
