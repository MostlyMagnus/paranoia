require 'ActionTypeDef'
require 'GamestatePawn'

class ActionQueue
  attr_accessor :action_queue, :gamestatePawns
  
  def initialize(gamestate)
    @gamestate = gamestate
    
    @pawns = Pawn.find_all_by_gamestate_id(@gamestate.id) 
    @action_queue = Array.new
  end

  def buildExecuteAndClearActions!  
    # Starting with tick #1, build it's action queue, sort it, execute it,
    # and then clear it. Repeat for the remaining ticks.    
    for tick in 0..4
      # Build the action queue based on the supplied tick
      buildActionQueue(tick)
      
      # Sorts the action queue based on priority derived from the action type
      # See action.rb for priority listings
      sortActionQueue!
      
      # Now execute the action queue
      executeActionQueue!
      
      # Clear the action queue before we do another tick
      clearActionQueue!
    end
    
    clearActions
  end
  
  def getPawnsActionQueue(pawn_id)
    singleActionQueue = Array.new
    
    Action.find_all_by_pawn_id(pawn_id).each do |action|
      singleActionQueue.push(actionToSpecificActionType(action))
    end
  end
  
  def executeActionQueueOnPawn(pawn, actionFilter = ActionTypeDef::A_NIL)    
    gamestatePawn =     GamestatePawn.new(@gamestate.gamestatePawns[pawn.id].pawn_id,
                                          @gamestate.gamestatePawns[pawn.id].x,
                                          @gamestate.gamestatePawns[pawn.id].y,
                                          @gamestate.gamestatePawns[pawn.id].status)
    
    if(actionFilter == ActionTypeDef::A_NIL)
      #executeAction(action, gamestatePawn)
      @gamestate.logger.debug "No filter"
    else      
      
      Action.find_all_by_pawn_id(pawn.id).each do |action|
        if(action.action_type == actionFilter)
          executeAction!(actionToSpecificActionType(action), gamestatePawn) 
        end 
      end
    end
    
    return gamestatePawn
  end
    
  private
  
  def clearActions
    # By now, we've executed all the pawns actions, so we remove them from the
    #   actions table.
    
    @pawns.each do |p|
      Action.destroy_all(:pawn_id => p.id)
    end
  end
   
  def clearActionQueue!
    # Clear up the action_queue 
    @action_queue.clear
  end
  
  def buildActionQueue(action_tick)    
    @pawns.each do |p|
      if !p.actions[action_tick].nil?
        @action_queue.push(actionToSpecificActionType(p.actions[action_tick]))   
      end
    end  
  end

  def actionToSpecificActionType(action)
    #This will parse the params of the action as well
    case action.action_type
      when ActionTypeDef::A_NIL        
        returnAction = A_Nil.new(action.attributes)
        
      when ActionTypeDef::A_USE
        returnAction = A_Use.new(action.attributes)
        
      when ActionTypeDef::A_REPAIR
        returnAction = A_Repair.new(action.attributes)
        
      when ActionTypeDef::A_KILL
        returnAction = A_Kill.new(action.attributes)        

      when ActionTypeDef::A_MOVE
        returnAction = A_Move.new(action.attributes)

    end
    
    returnAction
  end
    
  def sortActionQueue!
    @action_queue.sort! { |a,b| a.priority <=> b.priority }
  end
    
  def executeActionQueue!    
    for i in 0..@action_queue.size-1
      executeAction!(@action_queue[i],     @gamestate.gamestatePawns[@action_queue[i].pawn_id])
    end
  end
  
  def executeAction!(action, gamestatePawn)
    if      (action.kind_of? A_Nil)     then  executeA_Nil!(action, gamestatePawn)
    elsif   (action.kind_of? A_Use)     then  executeA_Use!(action, gamestatePawn)
    elsif   (action.kind_of? A_Repair)  then  executeA_Repair!(action, gamestatePawn)
    elsif   (action.kind_of? A_Kill)    then  executeA_Kill!(action, gamestatePawn)
    elsif   (action.kind_of? A_Move)    then  executeA_Move!(action, gamestatePawn)
    end
  end
   
  def executeA_Nil!(action, gamestatePawn)   
  end
  
  def executeA_Use!(action, gamestatePawn)
  end
  
  def executeA_Repair!(action, gamestatePawn)
  end
  
  def executeA_Kill!(action, gamestatePawn)
  end
  
  def executeA_Move!(action, gamestatePawn)
    gamestatePawn.x = gamestatePawn.x + Integer(action.toX)
    gamestatePawn.y = gamestatePawn.y + Integer(action.toY)
  end  
end
