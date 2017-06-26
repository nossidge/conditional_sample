#!/usr/bin/env ruby
# Encoding: UTF-8

module ConditionalSample

  module MixMe

    private

      ##
      # Run a bloc in a given number of 'seconds'. If the bloc completes in
      # time, then return the result of the bloc, else return 'rescue_value'.
      #
      def timeout_rescue seconds, rescue_value = nil
        begin
          Timeout::timeout(seconds.to_f) do
            yield
          end
        rescue Timeout::Error
          rescue_value
        end
      end

      ##
      # Delete the first matching value in an array.
      # Destructive to the first argument.
      #
      def delete_first! array, value
        array.delete_at(array.index(value) || array.length)
      end

      ##
      # Private recursive method.
      # #conditional_permutation is the public interface.
      #
      def conditional_permutation_recurse (
          array,
          conditions,
          current_iter = 0,
          current_array = [])

        output = []

        # Get the current conditional.
        cond = conditions[current_iter]

        # Loop through and return the first element that validates.
        valid = false
        array.each do |elem|

          # Test the condition. If we've run out of elements
          #   in the condition array, then allow any value.
          valid = cond ? cond.call(current_array, elem) : true
          if valid

            # Remove this element from the array, and recurse.
            remain = array.dup
            delete_first!(remain, elem)

            # If the remaining array is empty, no need to recurse.
            new_val = nil
            if !remain.empty?
              new_val = conditional_permutation_recurse(
                        remain,
                        conditions,
                        current_iter + 1,
                        current_array + [elem])
            end

            # If we cannot use this value, because it breaks future conditions.
            if !remain.empty? && new_val.empty?
              valid = false
            else
              output << elem << new_val
            end
          end

          break if valid
        end

        output.flatten.compact
      end

      ##
      # Private recursive method.
      # #conditional_sample is the public interface.
      #
      def conditional_sample_recurse (
          array,
          conditions,
          current_iter = 0,
          current_array = [])

        output = []

        # Get the current conditional.
        cond = conditions[current_iter]

        # Return nil if we have reached the end of the conditionals.
        return nil if cond.nil?

        # Loop through and return the first element that validates.
        valid = false
        array.each do |elem|

          # Test the condition. If we've run out of elements
          #   in the condition array, then allow any value.
          valid = cond.call(current_array, elem)
          if valid

            # Remove this element from the array, and recurse.
            remain = array.dup
            delete_first!(remain, elem)

            # If the remaining array is empty, no need to recurse.
            new_val = conditional_sample_recurse(
                      remain,
                      conditions,
                      current_iter + 1,
                      current_array + [elem])

            # If we cannot use this value, because it breaks future conditions.
            if new_val and new_val.empty?
              valid = false
            else
              output << elem << new_val
            end
          end

          break if valid
        end

        output.flatten.compact
      end

  end

end
