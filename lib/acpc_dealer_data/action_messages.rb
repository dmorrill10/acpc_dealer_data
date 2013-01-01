
require 'acpc_poker_types/match_state'
require 'acpc_poker_types/poker_action'

require_relative 'match_definition'

class ActionMessages

  attr_reader(
    :data, :final_score, :match_def
  )
    
  ToMessage = Struct.new(
    # @returns [Integer] Seat of the player receiving the message
    :seat,
    # @returns [MatchState] Match state received by the player
    :state
  )

  FromMessage = Struct.new(
    # @returns [Integer] Seat of the player acting
    :seat,
    # @returns [MatchState] Match state on which the action was taken
    :state,
    # @returns [PokerAction] Action taken
    :action
  )

  # @param [String] to_message TO message (message to player)
  def self.parse_to_message(to_message)
    if to_message.strip.match(
      /^TO\s*(\d+)\s*at\s*[\d\.]+\s+(\S+)$/
    )
      ToMessage.new(
        $1.to_i - 1,
        MatchState.parse($2)
      )
    else
      nil
    end
  end

  # @param [String] from_message FROM message (message from player)
  def self.parse_from_message(from_message)
    if from_message.strip.match(
/^FROM\s*(\d+)\s*at\s*[\d\.]+\s*(#{MatchState::LABEL}\S+):([#{PokerAction::LEGAL_ACPC_CHARACTERS.to_a.join('')}]\s*\d*)$/
    )
      FromMessage.new(
        $1.to_i - 1, 
        MatchState.parse($2), 
        PokerAction.new($3)
      )
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

  class LogFile < File
  end

  def self.parse_file(acpc_log_file_path, player_names, game_def_directory, num_hands=nil)
    LogFile.open(acpc_log_file_path, 'r') do |file| 
      ActionMessages.parse file, player_names, game_def_directory, num_hands
    end
  end

  alias_new :parse

  def initialize(acpc_log_statements, player_names, game_def_directory, num_hands=nil)
    @final_score = nil
    @match_def = nil
    @data = acpc_log_statements.inject([]) do |accumulating_data, log_line|
      if @match_def.nil?
        @match_def = MatchDefinition.parse(log_line, player_names, game_def_directory)
      else
        parsed_message = ActionMessages.parse_to_or_from_message(log_line)
        if parsed_message
          if (
            accumulating_data.empty? || 
            accumulating_data.last.first[:state].hand_number != parsed_message[:state].hand_number
          )
            break accumulating_data if accumulating_data.length == num_hands
            accumulating_data << []
          end

          accumulating_data.last << parsed_message
        else
          @final_score = ActionMessages.parse_score(log_line) unless @final_score
        end
      end

      accumulating_data
    end
  end
end