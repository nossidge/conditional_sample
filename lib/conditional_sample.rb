#!/usr/bin/env ruby
# Encoding: UTF-8

require 'timeout'

module ConditionalSample

  ##
  # Require everything in the subdirectory.
  #
  Dir[File.dirname(__FILE__) + '/*/*.rb'].each { |file| require file }

  ##
  # Add the instance methods to the Array class.
  #
  Array.include ConditionalSample::MixMe

  ##
  # Raise an error if an object does not respond to a specific method.
  #
  def self.method_assert object, method_name
    unless object.respond_to?(method_name)
      raise NoMethodError, "Missing method ##{method_name}"
    end
  end

  ##
  # Convert a hash to array, with key as index.
  # Fill any missing elements with a default value.
  #
  def self.to_conditions_array input, default = nil
    return input if input.is_a? Array

    # Get a list of all Integer keys.
    # Use the biggest key, and make an array of that length + 1.
    keys = input.keys.select { |i| i.is_a? Integer }
    keys.max.next.times.map  { |i| input[i] || default }
  end

end
