require 'ActionTypeDef'
require 'GamestatePawn'

class ActionQueue
  attr_accessor :action_queue, :gamestatePawns
  
  def initialize(gamestate)
    @gamestate = gamestate
    
    @pawns = Pawn.find_all_by_gamestate_id(@gamestate.id) 
    @action_queue = Array.new
    @init_votes   = Array.new
  end

  def buildExecuteAndClearActions!  
    # Starting with tick #1, build it's action queue, sort it, execute it,
    # and then clear it. Repeat for the remaining ticks.
    
    # Lets make sure the list of votes to be initiated is clean.
    @init_votes.clear
    
    for tick in 0..4
      # Build the action queue based on the supplied tick
      buildActionQueue(tick)
      
      # Sorts the action queue based on priority derived from the action type
      # See action.rb for priority listings
      sortActionQueue!
      
      # Lets store a snapshot of each tick for this turn.
      @gamestate.snapshots.create!(:turn => @gamestate.turn, :tick => tick, :actions => @gamestate.getPlayerStatus << "#" << @gamestate.game_ship.build_nodestatus_string)

      # Now execute the action queue
      executeActionQueue!
      
      # Clear the action queue before we do another tick
      clearActionQueue!
    end
    
    # Everything has been executed. If there is anything in the @init_votes array
    # this means that a vote has been suggested, but failed to receive a second.
    # Let's log this.
    @init_votes.each do |init_vote|
      @gamestate.add_log_entry(LoggerTypeDef::LOG_VOTE_INIT_FAIL, {:subject_id => init_vote[:subject_id], :target_id => init_vote[:target_id]})
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

      when ActionTypeDef::A_INITVOTE
        returnAction = A_InitVote.new(action.attributes)

      when ActionTypeDef::A_VOTE
        returnAction = A_Vote.new(action.attributes)

      when ActionTypeDef::A_STATUS
        returnAction = A_Status.new(action.attributes)

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
    if      (action.kind_of? A_Nil)         then  executeA_Nil!(action, gamestatePawn)
    elsif   (action.kind_of? A_Use)         then  executeA_Use!(action, gamestatePawn)
    elsif   (action.kind_of? A_Repair)      then  executeA_Repair!(action, gamestatePawn)
    elsif   (action.kind_of? A_Kill)        then  executeA_Kill!(action, gamestatePawn)
    elsif   (action.kind_of? A_Move)        then  executeA_Move!(action, gamestatePawn)
    elsif   (action.kind_of? A_Vote)        then  executeA_Vote!(action, gamestatePawn)
    elsif   (action.kind_of? A_InitVote)    then  executeA_InitVote!(action, gamestatePawn)      
    elsif   (action.kind_of? A_Status)      then  executeA_Status!(action, gamestatePawn)      

    end
  end
   
  def executeA_Nil!(action, gamestatePawn)   
  end
  
  def executeA_Use!(action, gamestatePawn)
    pawn = Pawn.find_by_id(gamestatePawn.pawn_id)    
    @gamestate.game_ship.get_node_by_id(action.target_node).node_type.to_s
    
    pawn.notifications.create!(:action_type => action.action_type, :params => "-")
  end
  
  def executeA_Repair!(action, gamestatePawn)
    pawn = Pawn.find_by_id(gamestatePawn.pawn_id)

    @gamestate.game_ship.get_node_by_id(action.target_node).status = @gamestate.game_ship.get_node_by_id(action.target_node).status.to_f + (0.2*action.multiplier.to_i)
        
    notif_text = @gamestate.game_ship.get_node_by_id(action.target_node).node_type + " is now at " + (@gamestate.game_ship.get_node_by_id(action.target_node).status.to_f*100).to_s + "%"
    
    pawn.notifications.create!(:action_type => action.action_type, :params => notif_text)
  end
  
  def executeA_Kill!(action, gamestatePawn)
    pawn = Pawn.find_by_id(gamestatePawn.pawn_id)
  
    if Integer(action.target_pawn_id) >= 0 then 
      # target_pawn_id is >= 0 thus the kill action is targeted
      @gamestate.gamestatePawns.each do |target_gamestatePawn|    
        if Integer(target_gamestatePawn[1].pawn_id) == Integer(action.target_pawn_id)
          if Integer(target_gamestatePawn[1].x) == Integer(gamestatePawn.x) &&
             Integer(target_gamestatePawn[1].y) == Integer(gamestatePawn.y) then
            
            target_gamestatePawn[1].status = 0 
            
            pawn.notifications.create!(:action_type => action.action_type, :params => "Kill action successful.")
          end
        end
      end
    else
      # target_pawn_id < 0 thus not specified. Kill the first unlucky bastard.
    end
  end
  
  def executeA_Move!(action, gamestatePawn)
    gamestatePawn.x = action.toX.to_i
    gamestatePawn.y = action.toY.to_i
  end
  
  def executeA_Vote!(action, gamestatePawn)
    @gamestate.user_events.find_by_id(action.event_id).event_inputs.create!(:pawn_id => gamestatePawn.pawn_id, :params => action.input)
  end

  def executeA_InitVote!(action, gamestatePawn)
    deletable = Array.new
    
    @init_votes.each do |init_vote|
      if gamestatePawn.pawn_id != init_vote[:subject_id] && init_vote[:target_id] == action.target then
        # There was a vote with the same target already in the array. This means that the user that ends
        # up here is the second to this vote. Lets log that.     
        @gamestate.add_log_entry(LoggerTypeDef::LOG_VOTE_INIT_SUCCESS, {:subject_a_id => init_vote[:subject_id], :subject_b_id => gamestatePawn.pawn_id, :target_id => init_vote[:target_id]})
        
        # Now lets add the user_event for the other users to respond to.
        @gamestate.user_events.create!(:action_type => ActionTypeDef::A_VOTE, :lifespan => 1, :params => action.target.to_s)
        
        # Lets remove the entry from the array.
        deletable.push(init_vote)
      end
    end
    
    if deletable.size > 0 then
      deletable.each do |d|
        @init_votes.delete(d)
      end
    else
      # If we reach this point it means that there was no pre-existing init_vote in the array. Lets add it.
      @init_votes.push({:subject_id => gamestatePawn.pawn_id, :target_id => action.target})
    end
  end
  
  def executeA_Status!(action, gamestatePawn)
    pawn = Pawn.find_by_id(gamestatePawn.pawn_id)
    
    pawn.notifications.create!(:action_type => action.action_type, :params => "Replace this with updates about the ship status.")
  end
end
