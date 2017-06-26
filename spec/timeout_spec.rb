#!/usr/bin/env ruby
# Encoding: UTF-8

################################################################################

require File.dirname(__FILE__) + '/spec_helper.rb'

################################################################################

# Using the timeout function is recommended when first developing a
# project, as it may not be transparent how computationally expensive
# a condition array will be.

describe ConditionalSample, "timeout" do

  # Even if a conditions array can be fulfilled using the corpus array,
  # it may just take too long.
  it "should output [] or valid array if conditions are possible but long" do

    # Read in the Rakefile, just as an example.
    # Multiply the array, so there's more rows.
    # Add just a few unique needles to this haystack.
    lines = File.read('Rakefile').split("\n")
    lines *= 500000
    lines << 'unique_string_1'
    lines << 'unique_string_2'
    lines << 'unique_string_3'

    # The first 3 will be easy to fill, as there are multiple valid lines.
    # The rest will be harder, as only one line matches each.
    conditions = [
      proc { |arr, elem| elem.match(/spec/i) },
      proc { |arr, elem| elem.match(/core/i) },
      proc { |arr, elem| elem.match(/rspec/i) },
      proc { |arr, elem| elem.match(/unique_string_1/i) },
      proc { |arr, elem| elem.match(/unique_string_2/i) },
      proc { |arr, elem| elem.match(/unique_string_3/i) }
    ]

    # Exact timing will depend on the results of the 'Array#shuffle'.
    # So this may or may not succeed.
    results = lines.shuffle.conditional_sample(conditions, 2.5)

    # Output will either be a 6 element or an empty array.
    expect([0, 6]).to include(results.count)
  end

  ##############################################################################

  # Example of using the Timeout module to ensure CPUs aren't locked up
  # until the heat-death of the universe.
  #
  # This will never succeed, because the corpus array and the conditions
  # array are incompatible. Without a timeout, it would calculate all
  # permutations, in factorial time, before telling you it's impossible.
  #
  # Using the timeout function is recommended when first developing a
  # project, as it may not be transparent how computationally expensive
  # a condition array will be.
  it "should output [] if conditions are impossible" do

    # Read in the Rakefile, just as an example.
    # Multiply the array, so there's more rows.
    # Add just a few unique needles to this haystack.
    lines = File.read('Rakefile').split("\n")
    lines *= 500000
    lines << 'unique_string_1'
    lines << 'unique_string_2'
    lines << 'unique_string_3'

    # Look at the last condition! It will never return true!
    # So this will take ages, unless we use the timer argument.
    conditions = [
      proc { |arr, elem| elem.match(/core/i) },
      proc { |arr, elem| elem.match(/rspec/i) },
      proc { |arr, elem| elem.match(/unique_string_1/i) },
      proc { |arr, elem| elem.match(/unique_string_2/i) },
      proc { |arr, elem| elem.match(/unique_string_3/i) },
      proc { |arr, elem| elem.match(/unique_string_4/i) }
    ]

    # Give up after some time.
    results = lines.shuffle.conditional_sample(conditions, 2.5)

    # Output will always be [], no matter how long we give it.
    expect(results).to eq []
  end

end

################################################################################
