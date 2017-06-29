#!/usr/bin/env ruby
# Encoding: UTF-8

module ConditionalSample

  ##
  # This module is suitable as a mixin, using the results of self#to_a
  #
  # It is automatically included in Array, so each of these methods are added
  # to Array when you require 'conditional_sample'
  #
  # For both methods, the 'conditions' array must contain boolean procs
  # using args |arr, elem|
  # arr::  a reference to the current array that has been built up
  #        through the recursion chain.
  # elem:: a reference to the current element being considered.
  #
  module MixMe

    ##
    # Return a permutation of 'array' where each element validates to the
    # same index in a 'conditions' array of procs that return Boolean.
    #
    # The output is an array that is a complete permutation of the input array.
    # i.e. output.length == array.length
    #
    # Any elements in the array that are extra to the number of conditions
    # will be assumed valid.
    #
    #    array = [1,2,3,4,5].shuffle
    #    conditions = [
    #      proc { |arr, elem| elem < 2},
    #      proc { |arr, elem| elem > 2},
    #      proc { |arr, elem| elem > 1}
    #    ]
    #    array.conditional_permutation(conditions)
    #
    #    possible output => [1, 3, 4, 5, 2]
    #
    def conditional_permutation conditions, seconds = nil
      ConditionalSample::method_assert(self, 'to_a')
      timeout_rescue(seconds, []) do
        conditional_permutation_recurse(self.to_a, conditions).tap{ |i| i.pop }
      end
    end

    ##
    # Return values from 'array' where each element validates to the same
    # index in a 'conditions' array of procs that return Boolean.
    #
    # The output is an array of conditions.length that is a partial
    # permutation of the input array, where satisfies only the conditions.
    #
    # Any elements in the array that are extra to the number of conditions
    # will not be output.
    #
    #    array = [1,2,3,4,5].shuffle
    #    conditions = [
    #      proc { |arr, elem| elem < 2},
    #      proc { |arr, elem| elem > 2},
    #      proc { |arr, elem| elem > 1}
    #    ]
    #    array.conditional_sample(conditions)
    #
    #    possible output => [1, 5, 3]
    #
    def conditional_sample conditions, seconds = nil
      ConditionalSample::method_assert(self, 'to_a')

      # Would always return [] anyway if there are more conditions than
      # inputs, this just avoids running the complex recursion code.
      return [] if conditions.length > self.to_a.length

      timeout_rescue(seconds, []) do
        conditional_sample_recurse(self.to_a, conditions).tap{ |i| i.pop }
      end
    end

  end

end
