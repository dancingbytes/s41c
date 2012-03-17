# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "s41c/version"

Gem::Specification.new do |s|
  s.name        = "s41c"
  s.version     = S41C::VERSION
  s.authors     = ["redfield"]
  s.email       = ["up.redfield@gmail.com"]
  s.homepage    = "https://github.com/dancingbytes/s41c"
  s.summary     = %q{}
  s.description = %q{TCP-socket сервер и клиент для 1С:Предприятие}

  s.rubyforge_project = "s41c"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

end
