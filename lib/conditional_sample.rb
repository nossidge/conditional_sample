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

end
