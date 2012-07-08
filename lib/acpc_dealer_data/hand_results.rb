
require 'dmorrill10-utils/class'

class HandResults

  exceptions :unable_to_parse_state, :unable_to_parse_score

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
      raise UnableToParseState, state_string
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
      raise UnableToParseScore, score_string
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
      begin
        begin
          accumulating_data << HandResults.parse_state(log_line)
        rescue UnableToParseState
          @final_score = HandResults.parse_score(log_line)
        end
      rescue UnableToParseScore # Skip lines that neither parse method understand
      end

      accumulating_data
    end
  end
end