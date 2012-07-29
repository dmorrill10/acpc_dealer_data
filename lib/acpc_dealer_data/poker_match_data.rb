
require 'dmorrill10-utils/class'

require_relative 'action_messages'
require_relative 'hand_data'
require_relative 'hand_results'
require_relative 'match_definition'

class PokerMatchData

  exceptions :match_definitions_do_not_match, :final_scores_do_not_match

  attr_reader :chip_distribution, :match_def, :hand_number, :data, :seat

  def initialize(action_messages, result_messages, player_names, dealer_directory)
    parsed_action_messages = ActionMessages.parse action_messages, player_names, dealer_directory
    parsed_hand_results = HandResults.parse result_messages, player_names, dealer_directory

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
  end

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