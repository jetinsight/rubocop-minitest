# frozen_string_literal: true

module RuboCop
  module Cop
    module Minitest
      # This cop enforces the use of `refute_equal(expected, object)`
      # over `assert_equal(expected != actual)` or `assert(! expected == actual)`.
      #
      # @example
      #   # bad
      #   assert("rubocop-minitest" != actual)
      #   assert(! "rubocop-minitest" == actual)
      #
      #   # good
      #   refute_equal("rubocop-minitest", actual)
      #
      class RefuteEqual < Cop
        MSG = 'Prefer using `refute_equal(%<preferred>s)` over ' \
              '`assert(%<over>s)`.'

        def_node_matcher :assert_not_equal, <<~PATTERN
          (send nil? :assert ${(send $_ :!= $_) (send (send $_ :! ) :== $_) } $... )
        PATTERN

        def on_send(node)
          preferred, over = process_not_equal(node)
          return unless preferred && over

          message = format(MSG, preferred: preferred, over: over)
          add_offense(node, message: message)
        end

        def autocorrect(node)
          lambda do |corrector|
            assert_not_equal(node) do |_, first_arg, second_arg, rest_args|
              autocorrect_node(node, corrector, first_arg, second_arg, rest_args)
            end
          end
        end

        private

        def autocorrect_node(node, corrector, first_arg, second_arg, rest_args)
          custom_message = rest_args.first
          replacement = preferred_usage(first_arg, second_arg, custom_message)
          corrector.replace(node.loc.expression, "refute_equal(#{replacement})")
        end

        def preferred_usage(first_arg, second_arg, custom_message = nil)
          [first_arg, second_arg, custom_message]
            .compact.map(&:source).join(', ')
        end

        def original_usage(first_part, custom_message)
          [first_part, custom_message].compact.join(', ')
        end

        def process_not_equal(node)
          assert_not_equal(node) do |over, first_arg, second_arg, rest_args|
            custom_message = rest_args.first
            preferred = preferred_usage(first_arg, second_arg, custom_message)
            over = original_usage(over.source, custom_message&.source)
            return [preferred, over]
          end
        end
      end
    end
  end
end
