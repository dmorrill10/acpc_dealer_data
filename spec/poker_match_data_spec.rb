
# Spec helper (must include first to track code coverage with SimpleCov)
require_relative 'support/spec_helper'

require 'mocha'

require 'acpc_dealer'
require 'acpc_poker_types/match_state'
require 'acpc_poker_types/poker_action'

require_relative '../lib/acpc_dealer_data/hand_data'
require_relative '../lib/acpc_dealer_data/match_definition'
require_relative '../lib/acpc_dealer_data/poker_match_data'

describe PokerMatchData do
  before do
    @patient = nil
    @chip_distribution = nil
    @match_def = nil
    @match_def_line_index = nil
    @score_line_index = nil
    @player_names = nil
  end

  describe 'when given action and result messages' do
    describe 'raises an exception if' do
      it 'match definitions do not match' do
        init_data do |action_messages, result_messages|
          new_action_messages = action_messages.dup
          new_action_messages[@match_def_line_index] = '# name/game/hands/seed different_name holdem.limit.2p.reverse_blinds.game 2 0\n'
        
          ->() do
            PokerMatchData.new(
              new_action_messages, 
              result_messages,
              @player_names,
              AcpcDealer::DEALER_DIRECTORY
            )
          end.must_raise PokerMatchData::MatchDefinitionsDoNotMatch

          new_result_messages = result_messages.dup
          new_result_messages[@match_def_line_index] = '# name/game/hands/seed different_name holdem.limit.2p.reverse_blinds.game 2 0\n'

          ->() do            
            PokerMatchData.new(
              action_messages,
              new_result_messages,
              @player_names,
              AcpcDealer::DEALER_DIRECTORY
            )
          end.must_raise PokerMatchData::MatchDefinitionsDoNotMatch
        end
      end
      it 'the final scores from each set of messages do not match' do
        init_data do |action_messages, result_messages|
          new_action_messages = action_messages.dup
          new_action_messages.pop
          new_action_messages.pop
          new_action_messages << 'SCORE:9001|-9001:p1|p2'
        
          ->() do
            PokerMatchData.new(
              new_action_messages, 
              result_messages,
              @player_names,
              AcpcDealer::DEALER_DIRECTORY
            )
          end.must_raise PokerMatchData::FinalScoresDoNotMatch

          new_result_messages = result_messages.dup
          new_result_messages.pop
          new_result_messages.pop
          new_result_messages << 'SCORE:9001|-9001:p1|p2'

          ->() do            
            PokerMatchData.new(
              action_messages, 
              new_result_messages,
              @player_names,
              AcpcDealer::DEALER_DIRECTORY
            )
          end.must_raise PokerMatchData::FinalScoresDoNotMatch
        end
      end
    end
    it 'works properly' do
      init_data do |action_messages, result_messages|
        @patient = PokerMatchData.new(
          action_messages, 
          result_messages,
          @player_names,
          AcpcDealer::DEALER_DIRECTORY
        )

        check_patient
      end
    end
  end
  describe 'when given action and result log files' do
  end

  def check_patient
    @patient.match_def.must_equal @match_def
    @patient.chip_distribution.must_equal @chip_distribution
  end

  def init_data
    data.each do |game, data_hash|
      @chip_distribution = data_hash[:chip_distribution]
      @match_def_line_index = data_hash[:match_def_line_index]
      @player_names = data_hash[:player_names]
      @match_def = MatchDefinition.parse(
          data_hash[:result_messages][@match_def_line_index],
          @player_names,
          AcpcDealer::DEALER_DIRECTORY
        )
      @score_line_index = data_hash[:score_line_index]
        
      yield data_hash[:action_messages], data_hash[:result_messages]
    end
  end

  def data
    {
      two_player_limit: {
        action_messages:
          "# name/game/hands/seed 2p.limit.h1000.r0 holdem.limit.2p.reverse_blinds.game 2 0
          #--t_response 600000
          #--t_hand 600000
          #--t_per_hand 7000
          STARTED at 1341695999.222081
          TO 1 at 1341695999.222281 MATCHSTATE:0:0::5d5c|
          TO 2 at 1341695999.222349 MATCHSTATE:1:0::|9hQd
          FROM 2 at 1341695999.222410 MATCHSTATE:1:0::|9hQd:c
          TO 1 at 1341695999.222450 MATCHSTATE:0:0:c:5d5c|
          TO 2 at 1341695999.222496 MATCHSTATE:1:0:c:|9hQd
          FROM 1 at 1341695999.222519 MATCHSTATE:0:0:c:5d5c|:c
          TO 1 at 1341695999.222546 MATCHSTATE:0:0:cc/:5d5c|/8dAs8s
          TO 2 at 1341695999.222583 MATCHSTATE:1:0:cc/:|9hQd/8dAs8s
          FROM 1 at 1341695999.222605 MATCHSTATE:0:0:cc/:5d5c|/8dAs8s:c
          TO 1 at 1341695999.222633 MATCHSTATE:0:0:cc/c:5d5c|/8dAs8s
          TO 2 at 1341695999.222664 MATCHSTATE:1:0:cc/c:|9hQd/8dAs8s
          FROM 2 at 1341695999.222704 MATCHSTATE:1:0:cc/c:|9hQd/8dAs8s:r
          TO 1 at 1341695999.222734 MATCHSTATE:0:0:cc/cr:5d5c|/8dAs8s
          TO 2 at 1341695999.222770 MATCHSTATE:1:0:cc/cr:|9hQd/8dAs8s
          FROM 1 at 1341695999.222792 MATCHSTATE:0:0:cc/cr:5d5c|/8dAs8s:c
          TO 1 at 1341695999.222820 MATCHSTATE:0:0:cc/crc/:5d5c|/8dAs8s/4h
          TO 2 at 1341695999.222879 MATCHSTATE:1:0:cc/crc/:|9hQd/8dAs8s/4h
          FROM 1 at 1341695999.222904 MATCHSTATE:0:0:cc/crc/:5d5c|/8dAs8s/4h:c
          TO 1 at 1341695999.222932 MATCHSTATE:0:0:cc/crc/c:5d5c|/8dAs8s/4h
          TO 2 at 1341695999.222964 MATCHSTATE:1:0:cc/crc/c:|9hQd/8dAs8s/4h
          FROM 2 at 1341695999.223004 MATCHSTATE:1:0:cc/crc/c:|9hQd/8dAs8s/4h:c
          TO 1 at 1341695999.223033 MATCHSTATE:0:0:cc/crc/cc/:5d5c|/8dAs8s/4h/6d
          TO 2 at 1341695999.223069 MATCHSTATE:1:0:cc/crc/cc/:|9hQd/8dAs8s/4h/6d
          FROM 1 at 1341695999.223091 MATCHSTATE:0:0:cc/crc/cc/:5d5c|/8dAs8s/4h/6d:c
          TO 1 at 1341695999.223118 MATCHSTATE:0:0:cc/crc/cc/c:5d5c|/8dAs8s/4h/6d
          TO 2 at 1341695999.223150 MATCHSTATE:1:0:cc/crc/cc/c:|9hQd/8dAs8s/4h/6d
          FROM 2 at 1341695999.223189 MATCHSTATE:1:0:cc/crc/cc/c:|9hQd/8dAs8s/4h/6d:c
          TO 1 at 1341695999.223272 MATCHSTATE:0:0:cc/crc/cc/cc:5d5c|9hQd/8dAs8s/4h/6d
          TO 2 at 1341695999.223307 MATCHSTATE:1:0:cc/crc/cc/cc:5d5c|9hQd/8dAs8s/4h/6d
          TO 1 at 1341695999.223333 MATCHSTATE:1:1::|5dJd
          TO 2 at 1341695999.223366 MATCHSTATE:0:1::6sKs|
          FROM 1 at 1341695999.223388 MATCHSTATE:1:1::|5dJd:c
          TO 1 at 1341695999.223415 MATCHSTATE:1:1:c:|5dJd
          TO 2 at 1341695999.223446 MATCHSTATE:0:1:c:6sKs|
          FROM 2 at 1341695999.223485 MATCHSTATE:0:1:c:6sKs|:r
          TO 1 at 1341695999.223513 MATCHSTATE:1:1:cr:|5dJd
          TO 2 at 1341695999.223548 MATCHSTATE:0:1:cr:6sKs|
          FROM 1 at 1341695999.223570 MATCHSTATE:1:1:cr:|5dJd:c
          TO 1 at 1341695999.223596 MATCHSTATE:1:1:crc/:|5dJd/2sTh2h
          TO 2 at 1341695999.223627 MATCHSTATE:0:1:crc/:6sKs|/2sTh2h
          FROM 2 at 1341695999.223664 MATCHSTATE:0:1:crc/:6sKs|/2sTh2h:r
          TO 1 at 1341695999.223692 MATCHSTATE:1:1:crc/r:|5dJd/2sTh2h
          TO 2 at 1341695999.223728 MATCHSTATE:0:1:crc/r:6sKs|/2sTh2h
          FROM 1 at 1341695999.223749 MATCHSTATE:1:1:crc/r:|5dJd/2sTh2h:c
          TO 1 at 1341695999.223776 MATCHSTATE:1:1:crc/rc/:|5dJd/2sTh2h/Qh
          TO 2 at 1341695999.223807 MATCHSTATE:0:1:crc/rc/:6sKs|/2sTh2h/Qh
          FROM 2 at 1341695999.223863 MATCHSTATE:0:1:crc/rc/:6sKs|/2sTh2h/Qh:r
          TO 1 at 1341695999.223897 MATCHSTATE:1:1:crc/rc/r:|5dJd/2sTh2h/Qh
          TO 2 at 1341695999.223934 MATCHSTATE:0:1:crc/rc/r:6sKs|/2sTh2h/Qh
          FROM 1 at 1341695999.223956 MATCHSTATE:1:1:crc/rc/r:|5dJd/2sTh2h/Qh:r
          TO 1 at 1341695999.223984 MATCHSTATE:1:1:crc/rc/rr:|5dJd/2sTh2h/Qh
          TO 2 at 1341695999.224015 MATCHSTATE:0:1:crc/rc/rr:6sKs|/2sTh2h/Qh
          FROM 2 at 1341695999.224053 MATCHSTATE:0:1:crc/rc/rr:6sKs|/2sTh2h/Qh:c
          TO 1 at 1341695999.224081 MATCHSTATE:1:1:crc/rc/rrc/:|5dJd/2sTh2h/Qh/8h
          TO 2 at 1341695999.224114 MATCHSTATE:0:1:crc/rc/rrc/:6sKs|/2sTh2h/Qh/8h
          FROM 2 at 1341695999.224149 MATCHSTATE:0:1:crc/rc/rrc/:6sKs|/2sTh2h/Qh/8h:r
          TO 1 at 1341695999.224178 MATCHSTATE:1:1:crc/rc/rrc/r:|5dJd/2sTh2h/Qh/8h
          TO 2 at 1341695999.224213 MATCHSTATE:0:1:crc/rc/rrc/r:6sKs|/2sTh2h/Qh/8h
          FROM 1 at 1341695999.224235 MATCHSTATE:1:1:crc/rc/rrc/r:|5dJd/2sTh2h/Qh/8h:c
          TO 1 at 1341695999.224292 MATCHSTATE:1:1:crc/rc/rrc/rc:6sKs|5dJd/2sTh2h/Qh/8h
          TO 2 at 1341695999.224329 MATCHSTATE:0:1:crc/rc/rrc/rc:6sKs|5dJd/2sTh2h/Qh/8h
          FINISHED at 1341696000.058664
          SCORE:110|-110:p1|p2
          ".split("\n").map { |line| line += "\n" },
        result_messages: [
          "# name/game/hands/seed 2p.limit.h1000.r0 holdem.limit.2p.reverse_blinds.game 2 0\n",
          "#--t_response 600000\n",
          "#--t_hand 600000\n",
          "#--t_per_hand 7000\n",
          "STATE:0:cc/crc/cc/cc:5d5c|9hQd/8dAs8s/4h/6d:20|-20:p1|p2\n",
          "STATE:1:crc/rc/rrc/rc:6sKs|5dJd/2sTh2h/Qh/8h:90|-90:p2|p1\n",
          'SCORE:110|-110:p1|p2'
        ],
        hand_start_line_indices: [6, 35],
        match_def_line_index: 0,
        score_line_index: -1,
        player_names: ['p1', 'p2'],
        chip_distribution: [110, -110],
      }
    }
  end
end
