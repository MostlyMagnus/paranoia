class LogEntry < ActiveRecord::Base
  belongs_to :gamestate
  attr_accessor :entry
  #@gamestate.turn, action.action_type, gamestatePawn.pawn_id, action.target
  
  def initialize(turn, action_type, subject_id, object_id)
    @turn = turn
    
    @subject_id = subject_id
    @object_id = object_id
    
    @entry = "Apa"
  end
end


