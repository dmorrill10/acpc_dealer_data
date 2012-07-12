
require 'dmorrill10-utils/class'

class HandResults

  attr_reader :data, :final_score

  def self.parse_state(state_string)
    if state_string.strip.match(
      /^STATE:\d+:[cfr\d\/]+:[^:]+:([\d\-\.|]+):([\w|]+)$/
      )
       
      stack_changes = $1.split '|'
      players = $2.split '|'
         
      players.each_index.inject({}) do |player_results, j|
         player_results[players[j].to_sym] = stack_changes[j].to_r
         player_results
      end
    else
      nil
    end
  end

  def self.parse_score(score_string)
    if score_string.strip.match(
      /^SCORE:([\d\-\.|]+):([\w|]+)$/
      )
       
      stack_changes = $1.split '|'
      players = $2.split '|'
         
      players.each_index.inject({}) do |player_results, j|
         player_results[players[j].to_sym] = stack_changes[j].to_r
         player_results
      end
    else
      nil
    end
  end

  def self.parse_file(acpc_log_file_path)
    File.open(acpc_log_file_path, 'r') do |file| 
      HandResults.parse file
    end
  end

  alias_new :parse

  def initialize(acpc_log_statements)
    @data = acpc_log_statements.inject([]) do |accumulating_data, log_line|
      parsed_message = HandResults.parse_state(log_line)
      if parsed_message
        accumulating_data << parsed_message
      else
        @final_score = HandResults.parse_score(log_line) unless @final_score
      end
      
      accumulating_data
    end
  end
end