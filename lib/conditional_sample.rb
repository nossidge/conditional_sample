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

end
