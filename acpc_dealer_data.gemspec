# -*- encoding: utf-8 -*-
require File.expand_path('../lib/acpc_dealer_data/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dustin Morrill"]
  gem.email         = ["morrill@ualberta.ca"]
  gem.description   = %q{ACPC Dealer data}
  gem.summary       = %q{Gem to parse, manipulate, and use data from the ACPC Dealer program.}
  gem.homepage      = "https://github.com/dmorrill10/acpc_dealer_data"

  gem.add_dependency 'acpc_dealer'
  gem.add_dependency 'acpc_poker_types'
  gem.add_dependency 'celluloid'
  gem.add_dependency 'dmorrill10-utils', '>=1.0.0'


  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'turn'
  gem.add_development_dependency 'pry-rescue'
  gem.add_development_dependency 'awesome_print'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "acpc_dealer_data"
  gem.require_paths = ["lib"]
  gem.version       = AcpcDealerData::VERSION
end
