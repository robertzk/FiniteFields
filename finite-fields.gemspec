# -*- encoding: utf-8 -*-
require './lib/finite-fields/version'

Gem::Specification.new do |s|
  s.name        = 'finite-fields'
  s.version     = FiniteFields::VERSION
  s.date        = Date.today.to_s
  s.summary     = 'Perform finite field arithmetic in Ruby'
  s.description = %(Finite field arithmetic is frequently used in things like
    cryptography and plain fun pure mathematics. This gem lets you use it in your
    own works.
  ).strip.gsub(/\s+/, " ")
  s.authors     = ["Robert Krzyzanowski"]
  s.email       = 'rkrzyzanowski@gmail.com'
  s.license     = 'MIT'
  s.homepage    = 'https://github.com/robertzk/FiniteFields'

  s.platform = Gem::Platform::RUBY
  s.require_paths = %w[lib]
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  #s.add_dependency 'nokogiri', '>= 1.6.1'

  s.add_development_dependency 'rake', '>= 0.9.0'
  s.add_development_dependency 'test-unit', '>= 1.2.3'

  s.extra_rdoc_files = ['README.md', 'LICENSE']
end

