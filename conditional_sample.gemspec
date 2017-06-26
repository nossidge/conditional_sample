# Encoding: UTF-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'conditional_sample/version.rb'

Gem::Specification.new do |s|
  s.name          = 'conditional_sample'
  s.authors       = ['Paul Thompson']
  s.email         = ['nossidge@gmail.com']

  s.summary       = %q{Array sampling based on an input array of Boolean procs}
  s.description   = %q{Patch the Array with a couple of nice methods for sampling based on the results of an array of Boolean procs. Array is sampled using the procs as conditions that each specific array index element must conform to.}
  s.homepage      = 'https://github.com/nossidge/conditional_sample'

  s.version       = ConditionalSample.version_number
  s.date          = ConditionalSample.version_date
  s.license       = 'GPL-3.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency('bundler',     '~> 1.13')
  s.add_development_dependency('rake',        '~> 10.0')
  s.add_development_dependency('rspec',       '~> 3.0')
  s.add_development_dependency('ruby_rhymes', '~> 0.1')
end
