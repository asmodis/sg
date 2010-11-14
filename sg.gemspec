# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sg/version"

Gem::Specification.new do |s|
  s.name        = "sg"
  s.version     = Sg::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Gunther Diemant"]
  s.email       = ["g.diemant@gmx.net"]
  s.homepage    = "http://rubygems.org/gems/sg"
  s.summary     = %q{Implementation of a semigroup.}
  s.description = %q{For more information see the README file.}

  s.rubyforge_project = "sg"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
