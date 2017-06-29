#!/usr/bin/env ruby
# Encoding: UTF-8

################################################################################

require File.dirname(__FILE__) + '/spec_helper.rb'

################################################################################

describe ConditionalSample, "examples" do

  it "should output the correct results: Basic example" do

    # 5 element input array.
    numbers = (1..5).to_a

    # 3 element conditions array.
    conditions = [
      proc { |arr, elem| elem < 3 },
      proc { |arr, elem| elem > 3 },
      proc { |arr, elem| elem > 1 }
    ]

    # These will always return the below output
    # because they are the first values that match.
    permut = numbers.conditional_permutation(conditions)
    sample = numbers.conditional_sample(conditions)
    expect(permut).to eq [1, 4, 2, 3, 5]
    expect(sample).to eq [1, 4, 2]

    # To get a random sample, #shuffle the array first.
    # These results will vary based on the shuffle.
    srand(42)
    shuf = numbers.shuffle
    shuf_permut = shuf.conditional_permutation(conditions)
    shuf_sample = shuf.conditional_sample(conditions)
    expect(shuf_permut).to eq [2, 5, 3, 1, 4]
    expect(shuf_sample).to eq [2, 5, 3]
  end

  ##############################################################################

  it "should output the correct results: Condition hash example" do

    # 8 element input array.
    array = [1, 2, 3, 4, 'f', 5, nil, 6]

    # 4 element conditions hash.
    conditions = {
      1   => proc { |arr, elem| elem.to_i > 1 },
      3   => proc { |arr, elem| elem.to_i > 5 },
      0   => proc { |arr, elem| elem == 'f' },
      '1' => proc { |arr, elem| false },
      nil => proc { |arr, elem| false }
    }

    # These will always return the below output
    # because they are the first values that match.
    permut = array.conditional_permutation(conditions)
    sample = array.conditional_sample(conditions)
    expect(permut).to eq ['f', 2, 1, 6, 3, 4, 5, nil]
    expect(sample).to eq ['f', 2, 1, 6]

    # To get a random sample, #shuffle the array first.
    # These results will vary based on the shuffle.
    srand(37)
    shuf = array.shuffle
    shuf_permut = shuf.conditional_permutation(conditions)
    shuf_sample = shuf.conditional_sample(conditions)
    expect(shuf_permut).to eq ['f', 3, 5, 6, 2, 1, nil, 4]
    expect(shuf_sample).to eq ['f', 3, 5, 6]
  end

  ##############################################################################

  it "should output the correct results: Random rhyming lines" do

    # Use this gem to get the rhyme of the line's final word.
    require 'ruby_rhymes'

    # Input lines, just two limericks concat together.
    lines = [
      "There was a young rustic named Mallory,",
      "who drew but a very small salary.",
      "When he went to the show,",
      "his purse made him go",
      "to a seat in the uppermost gallery.",
      "There was an Old Man with a beard,",
      "Who said, 'It is just as I feared!—",
      "Two Owls and a Hen,",
      "four Larks and a Wren,",
      "Have all built their nests in my beard.'"
    ]

    # Output a couplet of any two lines that rhyme.
    couplet_conditions = [
      proc { |arr, elem| true },
      proc { |arr, elem| elem.to_phrase.rhyme_key == arr.last.to_phrase.rhyme_key }
    ]
    srand(42)
    results = lines.shuffle.conditional_sample(couplet_conditions)
    expect(results).to eq ["four Larks and a Wren,", "Two Owls and a Hen,"]

    # Output a jumbled limerick from the input lines.
    limerick_conditions = [
      proc { |arr, elem| true },
      proc { |arr, elem| elem.to_phrase.rhyme_key == arr[0].to_phrase.rhyme_key },
      proc { |arr, elem| elem.to_phrase.rhyme_key != arr[0].to_phrase.rhyme_key },
      proc { |arr, elem| elem.to_phrase.rhyme_key == arr[2].to_phrase.rhyme_key },
      proc { |arr, elem| elem.to_phrase.rhyme_key == arr[0].to_phrase.rhyme_key }
    ]
    srand(42)
    results = lines.shuffle.conditional_sample(limerick_conditions)
    expect(results).to eq ["who drew but a very small salary.",
      "There was a young rustic named Mallory,",
      "four Larks and a Wren,",
      "Two Owls and a Hen,",
      "to a seat in the uppermost gallery."
    ]

  end

  ##############################################################################

  it "should output the correct results: Logic puzzle 1" do

    # Create an array of procs, one for each rule.
    rules = []

    # E has to be in the middle.
    rules << proc do |arr, elem|
      !(arr.count == 2) || elem == 'e'
    end

    # B and D must always sit together.
    rules << proc do |arr, elem|
      if elem == 'b' and arr.include?('d')
        arr.last == 'd'
      elsif elem == 'd' and arr.include?('b')
        arr.last == 'b'
      else
        true
      end
    end

    # B and E can't sit together.
    rules << proc do |arr, elem|
      if elem == 'b'
        arr.last != 'e'
      elsif elem == 'e'
        arr.last != 'b'
      else
        true
      end
    end

    # C and D must have exactly two people between them.
    rules << proc do |arr, elem|
      if elem == 'c' and arr.include?('d')
        arr[-3] == 'd'
      elsif elem == 'd' and arr.include?('c')
        arr[-3] == 'c'
      else
        true
      end
    end

    # A must always sit to the left of C.
    rules << proc do |arr, elem|
      !(elem == 'c') || arr.include?('a')
    end

    # Method to apply all the rules to a given |arr, elem|
    def apply_all(rules, arr, elem)
      rules.all? { |p| p.call(arr, elem) }
    end

    # The names of E and her friends.
    people = ['a', 'b', 'c', 'd', 'e']

    # Conditions array that implements all the rules
    conditions = people.count.times.map do
      proc { |arr, elem| apply_all(rules, arr, elem) }
    end

    # Output the permutation that satisfies all rules.
    20.times do
      result = people.shuffle.conditional_permutation(conditions)
      expect(result).to eq ['b', 'd', 'e', 'a', 'c']
    end
  end

  ##############################################################################

  it "should output the correct results: Logic puzzle 2" do

    # Make sure certain people don't sit next to each other.
    # e.g. "A is not next to B (or C, or D)"
    def person_not_next_to(arr, elem, subject, *people)
      if elem == subject
        people.all? do |person|
          !arr.include?(person) || arr.last != person
        end
      elsif people.include?(elem)
        !arr.include?(subject) || arr.last != subject
      else
        true
      end
    end

    # Create an array of procs, one for each rule.
    rules = []

    # Colin is not next to Kate.
    rules << proc do |arr, elem|
      person_not_next_to(arr, elem, 'Colin', 'Kate')
    end

    # Emily is not next to Fred or Kate.
    rules << proc do |arr, elem|
      person_not_next_to(arr, elem, 'Emily', 'Fred', 'Kate')
    end

    # Neither Kate or Emily are next to Irene.
    rules << proc do |arr, elem|
      person_not_next_to(arr, elem, 'Irene', 'Kate', 'Emily')
    end

    # And Fred should sit on Irene's left.
    rules << proc do |arr, elem|
      !(elem == 'Irene') || arr.last == 'Fred'
    end

    # Method to apply all the rules to a given |arr, elem|
    def apply_all(rules, arr, elem)
      rules.all? { |p| p.call(arr, elem) }
    end

    # The names of the wedding guests.
    people = ['Colin', 'Emily', 'Kate', 'Fred', 'Irene']

    # Conditions array that implements all the rules.
    conditions = people.count.times.map do
      proc { |arr, elem| apply_all(rules, arr, elem) }
    end

    # Output the permutation that satisfies all rules.
    20.times do
      result = people.shuffle.conditional_permutation(conditions).reverse
      expect(result).to eq ['Emily', 'Colin', 'Irene', 'Fred', 'Kate']
    end
  end

end

################################################################################
