# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "leandocument/version"

Gem::Specification.new do |s|
  s.name        = "leandocument"
  s.version     = Leandocument::VERSION
  s.authors     = ["Atsushi Nakatsugawa"]
  s.email       = ["atsushi@moongift.jp"]
  s.homepage    = "http://leandocument.com/"
  s.summary     = "Ruby library for LeanDocument."
  s.description = "Ruby command and Web viewer for LeanDocument."

  s.rubyforge_project = "leandocument"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_dependency 'sinatra'
  s.add_dependency 'grit'
  s.add_dependency 'rdiscount'
  s.add_dependency 'sinatra-partial'
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
