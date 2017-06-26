#!/usr/bin/env ruby
# Encoding: UTF-8

################################################################################

require File.dirname(__FILE__) + '/spec_helper.rb'

################################################################################

describe ConditionalSample, "basic behaviour" do

  # Input values.
  let(:numbers) { (1..5).to_a }
  let(:conditions) {
    [
      proc { |arr, elem| elem < 2},
      proc { |arr, elem| elem > 4},
      proc { |arr, elem| elem > 1}
    ]
  }
  let(:output_sample) { [1, 5, 2] }
  let(:output_permutation) { [1, 5, 2, 3, 4] }

  it "should output the correct results" do
    result = numbers.conditional_sample(conditions)
    expect(result).to eq output_sample

    result = numbers.conditional_permutation(conditions)
    expect(result).to eq output_permutation
  end

  it "when shuffled, should output an array of the correct length" do
    result = numbers.shuffle.conditional_sample(conditions)
    expect(result.count).to be conditions.count
    expect(result[0]).to be 1
    expect(result[1]).to be 5

    result = numbers.shuffle.conditional_permutation(conditions)
    expect(result.count).to be numbers.count
    expect(result[0]).to be 1
    expect(result[1]).to be 5
  end
end

################################################################################

describe ConditionalSample, "mixin behaviour" do

  # Input and output values.
  let(:numbers) { (1..5).to_a }
  let(:conditions) {
    [
      proc { |arr, elem| elem < 2},
      proc { |arr, elem| elem > 4},
      proc { |arr, elem| elem > 1}
    ]
  }
  let(:output_sample) { [1, 5, 2] }
  let(:output_permutation) { [1, 5, 2, 3, 4] }

  it "should correctly work with a Struct implementing #to_a" do

    # Attempt to mix in using extend on a Struct instance.
    struct = Struct.new(:contents) do
      def to_a
        contents.to_a
      end
    end.new numbers
    struct.extend ConditionalSample::MixMe

    # Run the methods, and compare results.
    result = struct.conditional_sample(conditions)
    expect(result).to eq output_sample

    result = struct.conditional_permutation(conditions)
    expect(result).to eq output_permutation
  end

  it "should fail on a Struct not implementing #to_a" do

    # Attempt to mix in using extend on a Struct instance.
    struct = Struct.new(:contents).new numbers
    struct.extend ConditionalSample::MixMe

    # Run the methods, and expect that they will fail.
    expect do
      struct.conditional_sample(conditions)
    end.to raise_error NoMethodError

    expect do
      struct.conditional_permutation(conditions)
    end.to raise_error NoMethodError
  end
end

################################################################################
