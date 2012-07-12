
require 'acpc_poker_types/match_state'
require 'acpc_poker_types/poker_action'

class ActionMessages

  attr_reader :data, :final_score

  def self.parse_to_message(to_message)
    if to_message.strip.match(
      /^TO\s*(\d+)\s*at\s*[\d\.]+\s+(\S+)$/
    )
      {seat: $1.to_i - 1, state: MatchState.parse($2)}
    else
      nil
    end
  end

  def self.parse_from_message(from_message)
    if from_message.strip.match(
/^FROM\s*(\d+)\s*at\s*[\d\.]+\s*(#{MatchState::LABEL}\S+):([#{PokerAction::LEGAL_ACPC_CHARACTERS.to_a.join('')}]\s*\d*)$/
    )
      {seat: $1.to_i - 1, state: MatchState.parse($2), action: PokerAction.new($3)}
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

  def self.parse_to_or_from_message(message)
    parsed_message = ActionMessages.parse_to_message(message)
    if parsed_message.nil?
      ActionMessages.parse_from_message(message)
    else
      parsed_message
    end
  end

  def self.parse_file(acpc_log_file_path)
    File.open(acpc_log_file_path, 'r') do |file| 
      ActionMessages.parse file
    end
  end

  alias_new :parse

  def initialize(acpc_log_statements)
    @data = acpc_log_statements.inject([]) do |accumulating_data, log_line|
      parsed_message = ActionMessages.parse_to_or_from_message(log_line)
      if parsed_message
        accumulating_data << parsed_message
      else
        @final_score = ActionMessages.parse_score(log_line) unless @final_score
      end

      accumulating_data
    end
  end
end