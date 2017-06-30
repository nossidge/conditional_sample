#!/usr/bin/env ruby
# Encoding: UTF-8

module ConditionalSample

  ##
  # The number of the current version.
  #
  def self.version_number
    major = 1
    minor = 0
    tiny  = 0
    pre   = nil

    string = [major, minor, tiny, pre].compact.join('.')
  end

  ##
  # The date of the current version.
  #
  def self.version_date
    '2017-06-30'
  end
end
