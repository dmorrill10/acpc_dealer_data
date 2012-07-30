
require 'acpc_poker_types/player'

require 'celluloid'

require 'dmorrill10-utils/class'

require_relative 'action_messages'
require_relative 'hand_data'
require_relative 'hand_results'
require_relative 'match_definition'

class PokerMatchData

  exceptions :match_definitions_do_not_match, :final_scores_do_not_match, :player_data_inconsistent

  attr_reader :chip_distribution, :match_def, :hand_number, :data, :players
  attr_accessor :seat

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

    @seat = 0
    @players = @match_def.player_names.length.times.map do |seat|
      Player.join_match(
        @match_def.player_names[seat], 
        seat,
        @match_def.game_def.chip_stacks[seat]
      )
    end
  end

  def for_every_seat!
    match_def.game_def.number_of_players.times do |seat|
      @seat = seat

      @players = @match_def.player_names.length.times.map do |seat_j|
        Player.join_match(
          @match_def.player_names[seat_j], 
          seat_j,
          @match_def.game_def.chip_stacks[seat_j]
        )
      end

      yield seat
    end

    self
  end

  def player_name(seat=@seat) @players[seat].name end
  def chip_balance(seat=@seat) @players[seat].chip_balance end
  def hole_cards(seat=@seat) @players[seat].hole_cards end
  def actions_taken_this_hand(seat=@seat) @players[seat].actions_taken_this_hand end
  def folded?(seat=@seat) @players[seat].folded? end
  def all_in?(seat=@seat) @players[seat].all_in? end
  def active?(seat=@seat) @players[seat].active? end

  def for_every_hand!
    @data.each_index do |i|
      @hand_number = i

      @players.each_with_index do |player, seat|
        player.start_new_hand!(
          @match_def.game_def.blinds[@seat],
          @match_def.game_def.chip_stacks[@seat],
          current_hand.data.first.state_messages[seat].users_hole_cards
        )
      end

      yield @hand_number
    end

    if @chip_distribution != @players.map { |p| p.chip_balance }
      raise PlayerDataInconsistent, "chip distribution: #{@chip_distribution}, player balances: #{@players.map { |p| p.chip_balance }}"
    end

    @hand_number = nil
    self
  end

  def for_every_turn!
    current_hand.for_every_turn!(@seat) do |turn_number|
      @players.each_with_index do |player, seat|
        last_match_state = current_hand.last_match_state(seat)
        match_state = current_hand.current_match_state(seat)

        if current_hand.next_action && player.seat == current_hand.next_action[:seat]
          player.take_action!(current_hand.next_action[:action])
        end

        if !match_state.first_state_of_first_round? && match_state.round > last_match_state.round
          player.start_new_round!
        end

        if current_hand.final_turn?
          player.take_winnings!(
            current_hand.chip_distribution[seat] + @match_def.game_def.blinds[@seat]
          )
        end
      end

      yield turn_number
    end

    self
  end

  def current_hand
    if @hand_number then @data[@hand_number] else nil end
  end

  def final_hand?
    if @hand_number then @hand_number >= @data.length - 1 else nil end
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

    self
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

    self
  end
end