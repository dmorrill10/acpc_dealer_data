
require 'dmorrill10-utils/class'

require_relative 'match_definition'

# Monkey patch for easy boundary checking
class Array
  def in_bounds?(i)
    i < length
  end
end

class HandData

  exceptions :match_definitions_do_not_match, :invalid_data

  attr_reader :chip_distribution, :match_def, :turn_number, :data, :seat

  # State messages are organized by seat
  Turn = Struct.new :state_messages, :action_message

  def initialize(match_def, action_data, result)
    @match_def = match_def
    
    set_chip_distribution! result

    set_data! action_data

    @turn_number = nil
    @seat = nil
  end

  def ==(other)
    @match_def == other.match_def &&
    @chip_distribution == other.chip_distribution &&
    @data == other.data
  end

  def for_every_turn!(seat)
    @seat = seat
    @data.each_index do |i|
      @turn_number = i

      yield @turn_number
    end

    @turn_number = nil
    self
  end

  def current_match_state(seat=@seat)
    if @turn_number
      @data[@turn_number].state_messages[seat]
    else
      nil
    end
  end

  def next_action
    if @turn_number
      @data[@turn_number].action_message
    else
      nil
    end
  end

  def last_match_state(seat=@seat)
    if @turn_number && @turn_number != 0
      @data[@turn_number-1].state_messages[seat]
    else
      nil
    end
  end

  def last_action
    if @turn_number && @turn_number != 0
      @data[@turn_number-1].action_message
    else
      nil
    end
  end

  def final_turn?
    if @turn_number
      @data.length <= @turn_number
    else
      nil
    end
  end

  protected

  def set_chip_distribution!(result)
    @chip_distribution = []
    result.each do |player_name, amount|
      begin
        @chip_distribution[@match_def.player_names.index(player_name.to_s)] = amount
      rescue TypeError
        raise PlayerNamesDoNotMatch
      end
    end
  end

  def set_data!(action_data)
    number_of_state_messages = @match_def.game_def.number_of_players

    @data = []
    message_number = 0
    while message_number < action_data.length
      state_messages = action_data[message_number..message_number+number_of_state_messages-1]

      assert_messages_have_no_actions state_messages

      state_messages = process_state_messages state_messages

      assert_messages_are_well_defined state_messages

      message_number += number_of_state_messages

      action_message = if action_data.in_bounds?(message_number) && 
        action_data[message_number][:action]

        message_number += 1
        action_data[message_number-1]
      else
        assert_message_is_from_final_turn action_data, message_number, state_messages

        nil
      end

      @data << Turn.new(state_messages, action_message)
    end
  end

  private

  def process_state_messages(state_messages)
    state_messages.inject([]) do |messages, raw_messages|
      messages[raw_messages[:seat]] = raw_messages[:state]
      messages
    end
  end

  def assert_messages_have_no_actions(state_messages)
    if state_messages.any? { |message| !message[:action].nil? }
      raise InvalidData, state_messages.find do |message| 
        !message[:action].nil?
      end.inspect
    end
  end

  def assert_messages_are_well_defined(state_messages)
    if state_messages.any? { |message| message.nil? }
      raise InvalidData, state_messages.find { |message| message.nil? }.inspect
    end
  end

  def assert_message_is_from_final_turn(action_data, message_number, state_messages)
    if action_data.in_bounds?(message_number+1) && 
      state_messages.last.round == action_data[message_number+1][:state].round
      raise InvalidData, action_data[message_number].inspect
    end
  end
end