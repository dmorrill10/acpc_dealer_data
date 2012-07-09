
require 'dmorrill10-utils/class'

require_relative 'match_definition'

class HandData

  exceptions :player_names_do_not_match, :invalid_data

  attr_reader :chip_distribution, :match_def, :turn_number, :data, :seat

  # State messages are organized by seat
  Turn = Struct.new :state_messages, :action_message

  def initialize(match_def, action_data, result)
    @match_def = match_def
    
    @chip_distribution = []
    result.each do |player_name, amount|
      begin
        @chip_distribution[@match_def.player_names.index(player_name.to_s)] = amount
      rescue TypeError
        raise PlayerNamesDoNotMatch
      end
    end

    number_of_state_messages = @match_def.game_def.number_of_players

    @data = []
    message_number = 0
    while message_number < action_data.length
      state_messages = action_data[message_number..message_number+number_of_state_messages-1]

      if state_messages.any? { |message| !message[:action].nil? }
        raise InvalidData, state_messages.find do |message| 
          !message[:action].nil?
        end.inspect
      end

      state_messages = state_messages.inject([]) do |messages, raw_messages|
        messages[raw_messages[:seat]] = raw_messages[:state]
        messages
      end

      if state_messages.any? { |message| message.nil? }
        raise InvalidData, state_messages.find { |message| message.nil? }.inspect
      end
      
      message_number += number_of_state_messages

      action_message = if message_number < action_data.length && 
        action_data[message_number][:action]

        message_number += 1
        action_data[message_number-1]
      else
        if message_number+1 < action_data.length && 
          state_messages.last.round == action_data[message_number+1][:state].round
          raise InvalidData, action_data[message_number].inspect
        end

        nil
      end

      @data << Turn.new(state_messages, action_message)
    end
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
  
  def last_match_state(seat=@seat)
    if @turn_number && @turn_number != 0
      @data[@turn_number-1].state_messages[seat]
    else
      nil
    end
  end
end