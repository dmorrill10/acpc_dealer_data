# -*- encoding: utf-8 -*-
require File.expand_path('../lib/acpc_dealer_data/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dustin Morrill"]
  gem.email         = ["morrill@ualberta.ca"]
  gem.description   = %q{ACPC Dealer data}
  gem.summary       = %q{Gem to parse, manipulate, and use data from the ACPC Dealer program.}
  gem.homepage      = "https://github.com/dmorrill10/acpc_dealer_data"

  gem.add_dependency 'acpc_dealer', '~> 0.0'
  gem.add_dependency 'acpc_poker_types', '~> 0.0'
  gem.add_dependency 'celluloid', '~> 0.13'
  gem.add_dependency 'dmorrill10-utils', '~> 1.0'

  gem.add_development_dependency 'minitest', '~> 4.7'
  gem.add_development_dependency 'mocha', '~> 0.13'
  gem.add_development_dependency 'simplecov', '~> 0.7'
  gem.add_development_dependency 'turn', '~> 0.9'
  gem.add_development_dependency 'pry-rescue', '~> 1.1'
  gem.add_development_dependency 'awesome_print', '~> 1.1'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "acpc_dealer_data"
  gem.require_paths = ["lib"]
  gem.version       = AcpcDealerData::VERSION
end
