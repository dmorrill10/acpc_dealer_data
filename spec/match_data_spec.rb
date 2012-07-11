
# Spec helper (must include first to track code coverage with SimpleCov)
require_relative 'support/spec_helper'

require 'mocha'

require 'acpc_dealer'
require 'acpc_poker_types/match_state'
require 'acpc_poker_types/poker_action'

require_relative '../lib/acpc_dealer_data/match_data'
require_relative '../lib/acpc_dealer_data/match_definition'

describe MatchData do
  before do
    @patient = nil
  end

  describe 'given action data and hand result data' do
    it 'interprets the data properly' do
      skip 'IMPLEMENT!'
    end
  end
  describe 'given an action message log and a result message log' do
    it 'interprets the data properly' do
      skip 'IMPLEMENT!'
    end
  end

  def check_patient
  end

  def init_data
    data.each do |game, data_hash|
      @chip_distribution = data_hash[:chip_distribution]
      @match_def = data_hash[:match_def]
      @turn_data = data_hash[:turn_data]
        
      yield data_hash[:action_data], data_hash[:result]
    end
  end

  def data
    {
      two_player_limit: {
        action_data: [
          {seat: 0, state: MatchState.parse('MATCHSTATE:1:999:crc/cc/cc/:|TdQd/As6d6h/7h/4s')},
          {seat: 1, state: MatchState.parse('MATCHSTATE:0:999:crc/cc/cc/:Jc8d|/As6d6h/7h/4s')}, 
          {
            seat: 1, 
            state: MatchState.parse('MATCHSTATE:0:999:crc/cc/cc/:Jc8d|/As6d6h/7h/4s'),
            action: PokerAction.new('r')
          },
          {seat: 0, state: MatchState.parse('MATCHSTATE:1:999:crc/cc/cc/r:|TdQd/As6d6h/7h/4s')},
          {seat: 1, state: MatchState.parse('MATCHSTATE:0:999:crc/cc/cc/r:Jc8d|/As6d6h/7h/4s')},
          {
            seat: 0, 
            state: MatchState.parse('MATCHSTATE:1:999:crc/cc/cc/r:|TdQd/As6d6h/7h/4s'),
            action: PokerAction.new('c')
          },
          {seat: 0, state: MatchState.parse('MATCHSTATE:1:999:crc/cc/cc/rc:Jc8d|TdQd/As6d6h/7h/4s')},
          {seat: 1, state: MatchState.parse('MATCHSTATE:0:999:crc/cc/cc/rc:Jc8d|TdQd/As6d6h/7h/4s')}
        ],
        result: {p1: 60, p2: -60},
        chip_distribution: [60, -60],
        match_def: MatchDefinition.parse(
          '# name/game/hands/seed 2p.limit.h1000.r0 holdem.limit.2p.reverse_blinds.game 1000 0',
          ['p1', 'p2'],
          AcpcDealer::DEALER_DIRECTORY
        ),
        turn_data: [
          HandData::Turn.new(
            [
              MatchState.parse('MATCHSTATE:1:999:crc/cc/cc/:|TdQd/As6d6h/7h/4s'),
              MatchState.parse('MATCHSTATE:0:999:crc/cc/cc/:Jc8d|/As6d6h/7h/4s')
            ],
            {
              seat: 1, 
              state: MatchState.parse('MATCHSTATE:0:999:crc/cc/cc/:Jc8d|/As6d6h/7h/4s'),
              action: PokerAction.new('r')
            }
          ),
          HandData::Turn.new(
            [
              MatchState.parse('MATCHSTATE:1:999:crc/cc/cc/r:|TdQd/As6d6h/7h/4s'),
              MatchState.parse('MATCHSTATE:0:999:crc/cc/cc/r:Jc8d|/As6d6h/7h/4s')
            ],
            {
              seat: 0, 
              state: MatchState.parse('MATCHSTATE:1:999:crc/cc/cc/r:|TdQd/As6d6h/7h/4s'),
              action: PokerAction.new('c')
            }
          ),
          HandData::Turn.new(
            [
              MatchState.parse('MATCHSTATE:1:999:crc/cc/cc/rc:Jc8d|TdQd/As6d6h/7h/4s'),
              MatchState.parse('MATCHSTATE:0:999:crc/cc/cc/rc:Jc8d|TdQd/As6d6h/7h/4s')
            ],
            nil
          )
        ]
      },
      two_player_nolimit: {
        action_data: [     
          {seat: 0, state: MatchState.parse('MATCHSTATE:1:999::|TdQd')},
          {seat: 1, state: MatchState.parse('MATCHSTATE:0:999::Jc8d|')},
          {
            seat: 0, 
            state: MatchState.parse('MATCHSTATE:1:999::|TdQd'),
            action: PokerAction.new('f')
          },
          {seat: 0, state: MatchState.parse('MATCHSTATE:1:999:f:|TdQd')},
          {seat: 1, state: MatchState.parse('MATCHSTATE:0:999:f:Jc8d|')}
        ],
        result: {p1: 19718, p2: -19718},
        chip_distribution: [19718, -19718],
        match_def: MatchDefinition.parse(
          '# name/game/hands/seed 2p.nolimit.h1000.r0 holdem.nolimit.2p.reverse_blinds.game 1000 0',
          ['p1', 'p2'],
          AcpcDealer::DEALER_DIRECTORY
        ),
        turn_data: [
          HandData::Turn.new(
            [
              MatchState.parse('MATCHSTATE:1:999::|TdQd'),
              MatchState.parse('MATCHSTATE:0:999::Jc8d|')
            ],
            {
              seat: 0, 
              state: MatchState.parse('MATCHSTATE:1:999::|TdQd'),
              action: PokerAction.new('f')
            }
          ),
          HandData::Turn.new(
            [
              MatchState.parse('MATCHSTATE:1:999:f:|TdQd'),
              MatchState.parse('MATCHSTATE:0:999:f:Jc8d|')
            ],
            nil
          )
        ]
      },
      three_player_limit: {
        action_data: [
          {seat: 0, state: MatchState.parse('MATCHSTATE:0:999:ccc/ccc/rrcc/rrrfr:QsAs||/4d6d2d/5d/2c')},
          {seat: 1, state: MatchState.parse('MATCHSTATE:1:999:ccc/ccc/rrcc/rrrfr:|3s8h|/4d6d2d/5d/2c')},
          {seat: 2, state: MatchState.parse('MATCHSTATE:2:999:ccc/ccc/rrcc/rrrfr:||Qd3c/4d6d2d/5d/2c')},
          {
            seat: 2, 
            state: MatchState.parse('MATCHSTATE:2:999:ccc/ccc/rrcc/rrrfr:||Qd3c/4d6d2d/5d/2c'),
            action: PokerAction.new('c')
          },
          {seat: 0, state: MatchState.parse('MATCHSTATE:0:999:ccc/ccc/rrcc/rrrfrc:QsAs|3s8h|Qd3c/4d6d2d/5d/2c')},
          {seat: 1, state: MatchState.parse('MATCHSTATE:1:999:ccc/ccc/rrcc/rrrfrc:|3s8h|Qd3c/4d6d2d/5d/2c')},
          {seat: 2, state: MatchState.parse('MATCHSTATE:2:999:ccc/ccc/rrcc/rrrfrc:|3s8h|Qd3c/4d6d2d/5d/2c')}
        ],
        result: {p1: 360, p2: -190, p3: -170},
        chip_distribution: [360, -190, -170],
        match_def: MatchDefinition.parse(
          '# name/game/hands/seed 3p.limit.h1000.r0 holdem.limit.3p.game 1000 0',
          ['p1', 'p2', 'p3'],
          AcpcDealer::DEALER_DIRECTORY
        ),
        turn_data: [
          HandData::Turn.new(
            [
              MatchState.parse('MATCHSTATE:0:999:ccc/ccc/rrcc/rrrfr:QsAs||/4d6d2d/5d/2c'),
              MatchState.parse('MATCHSTATE:1:999:ccc/ccc/rrcc/rrrfr:|3s8h|/4d6d2d/5d/2c'),
              MatchState.parse('MATCHSTATE:2:999:ccc/ccc/rrcc/rrrfr:||Qd3c/4d6d2d/5d/2c')
            ],
            {
              seat: 2, 
              state: MatchState.parse('MATCHSTATE:2:999:ccc/ccc/rrcc/rrrfr:||Qd3c/4d6d2d/5d/2c'),
              action: PokerAction.new('c')
            }
          ),
          HandData::Turn.new(
            [
              MatchState.parse('MATCHSTATE:0:999:ccc/ccc/rrcc/rrrfrc:QsAs|3s8h|Qd3c/4d6d2d/5d/2c'),
              MatchState.parse('MATCHSTATE:1:999:ccc/ccc/rrcc/rrrfrc:|3s8h|Qd3c/4d6d2d/5d/2c'),
              MatchState.parse('MATCHSTATE:2:999:ccc/ccc/rrcc/rrrfrc:|3s8h|Qd3c/4d6d2d/5d/2c')
            ],
            nil
          )
        ]
      },
      three_player_nolimit: {
        action_data: [
          {seat: 0, state: MatchState.parse('MATCHSTATE:0:999:ccr12926r20000c:QsAs||')},
          {seat: 1, state: MatchState.parse('MATCHSTATE:1:999:ccr12926r20000c:|3s8h|')},
          {seat: 2, state: MatchState.parse('MATCHSTATE:2:999:ccr12926r20000c:||Qd3c')},
          {
            seat: 1, 
            state: MatchState.parse('MATCHSTATE:1:999:ccr12926r20000c:|3s8h|'),
            action: PokerAction.new('c')
          },
          {seat: 0, state: MatchState.parse('MATCHSTATE:0:999:ccr12926r20000cc///:QsAs|3s8h|Qd3c/4d6d2d/5d/2c')},
          {seat: 1, state: MatchState.parse('MATCHSTATE:1:999:ccr12926r20000cc///:QsAs|3s8h|Qd3c/4d6d2d/5d/2c')},
          {seat: 2, state: MatchState.parse('MATCHSTATE:2:999:ccr12926r20000cc///:QsAs|3s8h|Qd3c/4d6d2d/5d/2c')}
        ],
        result: {p1: 40000, p2: -20000, p3: -20000},
        chip_distribution: [40000, -20000, -20000],
        match_def: MatchDefinition.parse(
          '# name/game/hands/seed 3p.nolimit.h1000.r0 holdem.nolimit.3p.game 1000 0',
          ['p1', 'p2', 'p3'],
          AcpcDealer::DEALER_DIRECTORY
        ),
        turn_data: [
          HandData::Turn.new(
            [
              MatchState.parse('MATCHSTATE:0:999:ccr12926r20000c:QsAs||'),
              MatchState.parse('MATCHSTATE:1:999:ccr12926r20000c:|3s8h|'),
              MatchState.parse('MATCHSTATE:2:999:ccr12926r20000c:||Qd3c')
            ],
            {
              seat: 1, 
              state: MatchState.parse('MATCHSTATE:1:999:ccr12926r20000c:|3s8h|'),
              action: PokerAction.new('c')
            }
          ),
          HandData::Turn.new(
            [
              MatchState.parse('MATCHSTATE:0:999:ccr12926r20000cc///:QsAs|3s8h|Qd3c/4d6d2d/5d/2c'),
              MatchState.parse('MATCHSTATE:1:999:ccr12926r20000cc///:QsAs|3s8h|Qd3c/4d6d2d/5d/2c'),
              MatchState.parse('MATCHSTATE:2:999:ccr12926r20000cc///:QsAs|3s8h|Qd3c/4d6d2d/5d/2c')
            ],
            nil
          )
        ]
      }
    }
  end
end
