class LogEntry < ActiveRecord::Base
  belongs_to :gamestate
  #@gamestate.turn, action.action_type, gamestatePawn.pawn_id, action.target
  
  def initialize(turn, action_type, subject_id, object_id)
    case action_type
      when ActionTypeDef::A_NIL
        "A_Nil"
      when ActionTypeDef::A_USE
        "A_Use"
      when ActionTypeDef::A_KILL
        "A_Kill"
      when ActionTypeDef::A_REPAIR
        "A_Repair"
      when ActionTypeDef::A_MOVE
        "A_Move"
      when ActionTypeDef::A_VOTE
        "A_Vote"
      when ActionTypeDef::A_INITVOTE
        "A_InitVote"
    end  
  end
  
end


