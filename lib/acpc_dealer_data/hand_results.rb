
require 'dmorrill10-utils/class'

class HandResults

  exceptions :unable_to_parse_state

  def self.parse_state(state_string)
    if state_string.match(
      /^STATE:\d+:[cfr\d\/]+:[^:]+:([\d\-|]+):([\w|]+)$/
      )
       
      stack_changes = $1.split '|'
      players = $2.split '|'
         
      players.each_index.inject({}) do |player_results, j|
         player_results[players[j]] = stack_changes[j].to_i
         player_results
      end
    else
      raise UnableToParseState, state_string
    end
  end

  def self.parse_file(acpc_log_file_path)
    File.open(acpc_log_file_path, 'r') do |file| 
     HandResults.parse file
    end
  end

  alias_new :parse

  def initialize(acpc_log_statements)
    acpc_log_statements.each do |log_line|
      
    end
  end
end