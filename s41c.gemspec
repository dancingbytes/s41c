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
  
  s.files      = Dir['**/*']
  s.require_paths = ["lib"]

end
