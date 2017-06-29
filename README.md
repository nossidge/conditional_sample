# Conditional Sample

by Paul Thompson - nossidge@gmail.com

This is a Ruby gem that will patch the Array class with a couple of
nice methods for sampling based on the results of an array or hash of
Boolean procs. Array is sampled using the procs as conditions that each
specific array index element must conform to.

I'm using this primarily for procedural generation, where I have an
array of possible values and a certain sample I need to extract, or an
order in which I want the values arranged.

This code was spun off into a gem from my poetry generation project
https://github.com/nossidge/poefy


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'conditional_sample'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install conditional_sample


## Usage

When you require the gem, two extra methods are added to Array.

```ruby
array.conditional_permutation(conditions, seconds)
array.conditional_sample(conditions, seconds)
```

`#conditional_permutation` returns a permutation of the array where
each element validates to the same index in a 'conditions' array of
procs that return Boolean. At the end of the 'conditions' array, if
there are any elements in the array that have not been assigned, they
are appended without comparison.

`#conditional_sample` returns values from 'array' where each element
validates to the same index in a 'conditions' array of procs that
return Boolean. At the end of the 'conditions' array, no further
elements from the input array are appended.


### The 'conditions' argument

This is an array of boolean procs that evaluate true if an element is
allowed to be placed in that position.

The arguments for each proc are |arr, elem|
* **arr**  is a reference to the current array that has been built up
           through the recursion chain.
* **elem** is a reference to the current element being considered.

This can also be a hash. In that case, the key will correspond to
the element in the output array. Non-Integer keys are ignored, and
there is no implicit call to #to_i.


### The 'seconds' argument

This optional argument will force the method to give up and return an
empty array after a given number of seconds.

If you've ever tried to run `Array#permutation` on an array of even a
seemingly moderate size, you will know that it is very computationally
expensive. The results are [factorial][1], and get exponentially larger
the more elements there are in the input array.

For example, this code takes my machine two whole minutes to run.
```ruby
puts (1..12).to_a.permutation.count
```

These methods are not usually as computationally expensive, as there is
only one array for the output, but they can take a very long time to run
depending on how many rejected permutations there are before a valid one.
If there are no valid permutations for the given conditions array, all
permutations will be compared before simply outputting an empty array.
And that will take even longer than `Array#permutation`.

The methods have an optional argument to assuage this. This takes a
number that represents a time in seconds (which can be a fraction) and
returns an empty array if a valid sample is not found in that time.

Below is an example. If it fails to resolve in, say, two seconds, then
it's probably not possible to fit the conditions to the lines:

```ruby
lines.shuffle.conditional_sample(conditions, 2)
```

This is **strongly** recommended when first developing a project, as it
may not be transparent how computationally expensive a condition array
will be, especially on input arrays larger than about 10.

**It's really useful, honest. I wouldn't have built this in to the
methods if it wasn't super needed.**

Example programs can be found in the `spec` directory.

[1]: https://en.wikipedia.org/wiki/Factorial


## Examples

All of these examples can be found in `spec/examples_spec.rb`, and
are evaluated when using the `$ rspec` or `$ rake test` commands.


### Basic example

```ruby
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
p permut  # => [1, 4, 2, 3, 5]
p sample  # => [1, 4, 2]

# To get a random sample, #shuffle the array first.
# These results will vary based on the shuffle.
shuf = numbers.shuffle
shuf_permut = shuf.conditional_permutation(conditions)
shuf_sample = shuf.conditional_sample(conditions)
p shuf_permut  # => [2, 5, 4, 1, 3]
p shuf_sample  # => [2, 5, 4]
```


### Condition hash example

```ruby
# 8 element input array.
array = [1, 2, 3, 4, 'f', 5, nil, 6]

# Conditions hash.
# * [3] is the largest Integer key, so the resulting
#   array will have four elements.
# * Keys ['1'] and [nil] aren't Integers, so are ignored.
# * Key [2] is given the default value of:
#   proc { |arr, elem| true }
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
p permut  # => ['f', 2, 1, 6, 3, 4, 5, nil]
p sample  # => ['f', 2, 1, 6]

# To get a random sample, #shuffle the array first.
# These results will vary based on the shuffle.
shuf = array.shuffle
shuf_permut = shuf.conditional_permutation(conditions)
shuf_sample = shuf.conditional_sample(conditions)
p shuf_permut  # => ['f', 3, 5, 6, 2, 1, nil, 4]
p shuf_sample  # => ['f', 3, 5, 6]
```


### Random rhyming lines

A really simple way to extract rhyming lines from an input array.

```ruby
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
puts lines.shuffle.conditional_sample(couplet_conditions)
#   Who said, 'It is just as I feared!—
#   There was an Old Man with a beard,

# Output a jumbled limerick from the input lines.
limerick_conditions = [
  proc { |arr, elem| true },
  proc { |arr, elem| elem.to_phrase.rhyme_key == arr[0].to_phrase.rhyme_key },
  proc { |arr, elem| elem.to_phrase.rhyme_key != arr[0].to_phrase.rhyme_key },
  proc { |arr, elem| elem.to_phrase.rhyme_key == arr[2].to_phrase.rhyme_key },
  proc { |arr, elem| elem.to_phrase.rhyme_key == arr[0].to_phrase.rhyme_key }
]
puts lines.shuffle.conditional_sample(limerick_conditions)
#   to a seat in the uppermost gallery.
#   who drew but a very small salary.
#   Two Owls and a Hen,
#   four Larks and a Wren,
#   There was a young rustic named Mallory,
```


### Logic puzzle

You can use this to solve simple one-dimensional logic puzzles, such as
determining seating order, or racehorse results. Here's an example I just
made up:

**It's E's birthday!** Her good buddies have invited her for a big ol'
birthday meal at the fanciest restaurant in the whole prefecture. They'll
be sitting at the Top Bench, getting to look down at all the nonbirthdaying
plebs. E's gonna love it! All that needs sorting out now is the seating
arrangement, but A isn't worried. He knows he just has to follow the simple
rules below:

1. E has to be in the middle, obviously. It's her birthday!
2. B and D are besties. They must always sit together.
3. B and E are beasties. They can't sit together, or they'll beast out
   all over each other.
4. For religious reasons, C and D must have exactly two people between them.
5. For different (but equally culturally valid) religious reasons, A must
   always sit to the left of C.

```ruby
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

# Conditions array that implements all the rules.
conditions = people.count.times.map do
  proc { |arr, elem| apply_all(rules, arr, elem) }
end

# Output the permutation that satisfies all rules.
p people.conditional_permutation(conditions)
#   ['b', 'd', 'e', 'a', 'c']
```


### Logic puzzle 2

Puzzle found at: http://www.braingle.com/brainteasers/teaser.php?id=20962

At the wedding reception, there are five guests, Colin, Emily, Kate,
Fred, and Irene, who are not sure where to sit at the dinner table.
They ask the bride's mother, who responds, "As I remember, Colin is
not next to Kate, Emily is not next to Fred or Kate. Neither Kate or
Emily are next to Irene. And Fred should sit on Irene's left." As you
look at them from the opposite side of the table, can you correctly
seat the guests from left to right?

```ruby
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
p people.conditional_permutation(conditions).reverse
#   ['Emily', 'Colin', 'Irene', 'Fred', 'Kate']
```
