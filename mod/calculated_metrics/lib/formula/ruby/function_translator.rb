module Formula
  class Ruby < Calculator
    # Translates Wolfram Language function calls to ruby code
    class FunctionTranslator
      FUNC_KEY_MATCHER = FUNCTIONS.keys.join("|").freeze

      class SyntaxError < StandardError; end

      class << self
        # @param [String] the formula to translate
        # @param [Integer] index were we are in the original formula.
        #   only used for error messages
        # @return [String] Wolfram functions calls in formula replaced
        #   with ruby method calls
        def translate formula, offset=0
          with_next_match formula do |replacement, pos, i_arg_start|
            arg, rest = tr_after_match formula, offset, i_arg_start
            [formula[0, pos], "[#{arg}].flatten.#{replacement}", rest].join
          end
        end

        def with_next_match part
          return unless part.present?
          match = part.match FUNC_KEY_MATCHER
          return part unless match
          yield FUNCTIONS[match[0]], match.begin(0), match.end(0)
        end

        def tr_part formula, offset, start, stop=-1
          translate formula[start..stop], offset + start
        end

        # Translate the part right after a function name match.
        # We divide that part into the argument for the function and the rest
        # and translate both separately
        # @param formula [String]
        # @param offset [Integer] where are we in the whole formula
        # @param arg_start [Integer] position of opening '['
        # @return [String, String] the translated argument and the translated rest
        def tr_after_match formula, offset, arg_start
          syntax_error :opening_bracket, offset + arg_start if formula[arg_start] != "["
          arg_end = arg_end arg_start, formula, offset
          [tr_part(formula, offset, arg_start + 1, arg_end - 1),
           tr_part(formula, offset, arg_end + 1)]
        end


        def syntax_error type, pos
          pos += 1 # 1-based index in error message
          message =
            case type
            when :closing_bracket
              "invalid formula: no closing ']' found for '[' at #{pos}"
            when :opening_bracket
              "invalid formula: expected '[' at #{pos}"
            else
              "invalid formula: syntax error at #{pos}"
            end
          raise SyntaxError, message
        end

        private

        def arg_end arg_start, formula, offset
          i = arg_start + 1
          br_cnt = 1 # bracket count
          while br_cnt.positive?
            i += 1
            syntax_error :closing_bracket, offset + arg_start if i == formula.size
            br_cnt += 1 if formula[i] == "["
            br_cnt -= 1 if formula[i] == "]"
          end
          i
        end
      end
    end
  end
end
