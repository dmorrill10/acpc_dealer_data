# -*- encoding: utf-8 -*-
require File.expand_path('../lib/acpc_dealer_data/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dustin"]
  gem.email         = ["morrill@ualberta.ca"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.add_dependency 'acpc_dealer'
  gem.add_dependency 'acpc_poker_types'
  gem.add_dependency 'dmorrill10-utils', '~>0.0.5'

  gem.add_development_dependency 'mocha'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "acpc_dealer_data"
  gem.require_paths = ["lib"]
  gem.version       = AcpcDealerData::VERSION
end
