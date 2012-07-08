
require 'simplecov'
SimpleCov.start

require 'minitest/spec'
require 'minitest/autorun'

begin 
  require 'turn/autorun'

  Turn.config do |c|
    # use one of output formats:
    # :outline  - turn's original case/test outline mode [default]
    # :progress - indicates progress with progress bar
    # :dotted   - test/unit's traditional dot-progress mode
    # :pretty   - new pretty reporter
    # :marshal  - dump output as YAML (normal run mode only)
    # :cue      - interactive testing
    c.format  = :pretty
    # use humanized test names (works only with :outline format)
    c.natural = true
  end
rescue LoadError
end
