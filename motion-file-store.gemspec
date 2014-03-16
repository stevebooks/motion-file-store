# -*- encoding: utf-8 -*-
require File.expand_path('../lib/motion_file_store/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "motion-file-store"
  s.version     = MotionFileStore::VERSION
  s.authors     = ["Steve Books"]
  s.homepage    = "https://github.com/stevebooks/motion-file-store"
  s.summary     = "Easily store data in files with RubyMotion"
  s.description = "Easily store data in files with RubyMotion"

  s.files         = `git ls-files`.split($\)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency 'bubble-wrap', '>=1.1.5'
  s.add_development_dependency 'rake'
end
