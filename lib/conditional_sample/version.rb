#!/usr/bin/env ruby
# Encoding: UTF-8

module ConditionalSample

  ##
  # The number of the current version.
  #
  def self.version_number
    major = 0
    minor = 1
    tiny  = 0
    pre   = nil

    string = [major, minor, tiny, pre].compact.join('.')
  end

  ##
  # The date of the current version.
  #
  def self.version_date
    '2017-06-27'
  end
end
