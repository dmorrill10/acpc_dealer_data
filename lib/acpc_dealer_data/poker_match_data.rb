
require 'dmorrill10-utils/class'

require 'celluloid'

require_relative 'action_messages'
require_relative 'hand_data'
require_relative 'hand_results'
require_relative 'match_definition'

class PokerMatchData

  exceptions :match_definitions_do_not_match, :final_scores_do_not_match

  attr_reader :chip_distribution, :match_def, :hand_number, :data, :seat

  def self.parse_files(action_messages_file, result_messages_file, player_names, dealer_directory)
    parsed_action_messages = Celluloid::Future.new { ActionMessages.parse_file action_messages_file, player_names, dealer_directory }
    parsed_hand_results = Celluloid::Future.new { HandResults.parse_file result_messages_file, player_names, dealer_directory }

    PokerMatchData.new parsed_action_messages.value, parsed_hand_results.value, player_names, dealer_directory
  end

  def self.parse(action_messages, result_messages, player_names, dealer_directory)
    parsed_action_messages = ActionMessages.parse action_messages, player_names, dealer_directory
    parsed_hand_results = HandResults.parse result_messages, player_names, dealer_directory

    PokerMatchData.new parsed_action_messages, parsed_hand_results, player_names, dealer_directory
  end

  def initialize(parsed_action_messages, parsed_hand_results, player_names, dealer_directory)
    if (
      parsed_action_messages.match_def.nil? ||
      parsed_hand_results.match_def.nil? ||
      parsed_action_messages.match_def != parsed_hand_results.match_def
    )
      raise MatchDefinitionsDoNotMatch
    end

    if (
      parsed_action_messages.final_score.nil? ||
      parsed_hand_results.final_score.nil? ||
      parsed_action_messages.final_score != parsed_hand_results.final_score
    )
      raise FinalScoresDoNotMatch
    end

    @match_def = parsed_hand_results.match_def

    set_chip_distribution! parsed_hand_results.final_score

    set_data! parsed_action_messages, parsed_hand_results

    @seat = nil
  end

  def for_every_seat!
    match_def.game_def.number_of_players.times do |seat|
      @seat = seat

      yield seat
    end
  end

  def player_name(seat=@seat) @match_def.player_names[seat] end
  def chip_stack(seat=@seat) @match_def.game_def.chip_stacks[seat] end
  def chip_balance(seat=@seat) -@chip_distribution[seat] end

  def for_every_hand!
    @data.each_index do |i|
      @hand_number = i

      yield @hand_number
    end

    @hand_number = nil
    self
  end

  def current_hand
    if @hand_number then @data[@hand_number] else nil end
  end

  def final_hand?
    if @hand_number then @data.length <= @hand_number else nil end
  end

  protected

  def set_chip_distribution!(final_score)
    @chip_distribution = []
    final_score.each do |player_name, amount|
      begin
        @chip_distribution[@match_def.player_names.index(player_name.to_s)] = amount
      rescue TypeError
        raise PlayerNamesDoNotMatch
      end
    end
  end

  def set_data!(parsed_action_messages, parsed_hand_results)
    @data = []
    parsed_action_messages.data.zip(parsed_hand_results.data).each do |action_messages_by_hand, hand_result|
      @data << HandData.new(
        @match_def,
        action_messages_by_hand,
        hand_result
      )
    end
  end
end