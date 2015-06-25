# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/openid_connect/providers/version'

Gem::Specification.new do |spec|
  spec.name          = "omniauth-openid_connect-providers"
  spec.version       = Omniauth::OpenidConnect::Providers::VERSION
  spec.authors       = ["Finn GmbH"]
  spec.email         = ["info@finn.de"]
  spec.summary       = %q{Offers a means to configure OmniAuth OpenIDConnect providers comfortably.}
  spec.homepage      = "https://github.com/finnlabs/omniauth-openid_connect-providers"
  spec.license       = "GPLv3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'omniauth-openid-connect', '>= 0.2.0'

  spec.add_development_dependency 'bundler', '>= 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.1.0'
  spec.add_development_dependency 'pry'
end
