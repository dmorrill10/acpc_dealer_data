
# Spec helper (must include first to track code coverage with SimpleCov)
require File.expand_path('../support/spec_helper', __FILE__)

require File.expand_path('../../lib/acpc_dealer_data/hand_results', __FILE__)

describe HandResults do
  before do
    @name = nil
    @game_def = nil
    @number_of_hands = nil
    @random_seed = nil
    @player_names = nil
    @patient = nil
  end

  describe 'properly parses a ACPC log "STATE. . ." line' do
    [
      'STATE:0:rc/rrrrc/rc/crrrc:5d5c|9hQd/8dAs8s/4h/6d:28|-28:p1|p2' =>
        {hand_number: 0, players: {'p1' => 28, 'p2' => -28}}, 
      'STATE:9:cc/cc/r165c/cc:4cKh|Kd7d/Ah9h9c/6s/Ks:0|0:p1|p2' =>
        {hand_number: 9, players: {'p1' => 0, 'p2' => 0}},
      'STATE:18:rfrrc/cc/rrc/rrrrc:5d5c|9hQd|8dAs/8s4h6d/5s/Js:-5|-160|165:p1|p2|p3' =>
        {hand_number: 18, players: {'p1' => -5, 'p2' => -160, 'p3' => 165}},
      'STATE:1:cr13057cr20000cc///:Ks6h|Qs5d|Tc4d/Ah3dTd/8c/Qd:-20000|40000|-20000:p2|p3|p1' =>
        {hand_number: 27, players: {'p1' => -20000, 'p2' => -20000, 'p3' => 40000}}
    ].each do |state_string, expected_values|
      HandResults.parse_state_string(state_string).must_equal expected_values
    end
  end


    # next unless line.match(/^STATE:\d+:[cfr\d\/]+:[^:]+:([\d\-|]+):([\w|]+)$/)
         
    #      stack_changes = $1.split '|'
    #      players = $2.split '|'
            
    #      players.each_index do |j|
    #         result_hash[players[j]] = stack_changes[j] 
    #      end
         
    #      @data.push num_players, type, log_type, result_hash
  # end

end
