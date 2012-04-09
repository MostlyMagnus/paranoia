require 'actiontypedef'
require 'gamestatepawn'

class ActionQueue
  attr_accessor :action_queue, :gamestatePawns
  
  def initialize(gamestate)
    @gamestate = gamestate
    
    @pawns = Pawn.find_all_by_gamestate_id(@gamestate.id) 
    @action_queue = Array.new
    @init_votes   = Array.new
  end

  def buildExecuteAndClearActions!(passed_gamestatepawns = @gamestate.gamestatePawns)      
    # Lets make sure the list of votes to be initiated is clean.
    @init_votes.clear
    
    # Call this outside of the tick loop to build the queue    
    @action_queue = getAdvancedActionQueue
  
    for tick in 0..AppConfig::ACTION_TOTAL_AP-1
 
		# If no actions were performed on this specific tick, there's a risk that it's nil.
		if !@action_queue[tick].nil? then		  
			
			# Call sortActionQueue on the current tick. It returns a sorted actionQueue variable
			# that then gets executed by executeActionQueue!
			executeActionQueue!(sortActionQueue(@action_queue[tick]), passed_gamestatepawns)
		end 
	  	  
		# Lets store a snapshot of each tick for this turn.
		@gamestate.snapshots.create!(:turn => @gamestate.turn, :tick => tick, :actions => @gamestate.getPlayerStatus << "#" << @gamestate.game_ship.build_nodestatus_string)	  
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
      singleActionQueue.push(action.actionToSpecificActionType)
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
          executeAction!(action.actionToSpecificActionType, gamestatePawn) 
        end 
      end
    end
    
    return gamestatePawn
  end
  
  def buildActionQueue(action_tick = nil, pawn = nil)
    action_queue = Array.new
    
    if !pawn.nil? then
      pawn.actions.each do |action|
        pushAction = action.actionToSpecificActionType
        pushAction[:tick_cost] = action.getTickCost

        action_queue.push(pushAction)
      end
    else
      @pawns.each do |p|
        if !p.actions[action_tick].nil?
          action_queue.push(p.actions[action_tick].actionToSpecificActionType)
        end
      end
    end
    
    if action_queue.empty? then action_queue.push(nil) end

    return action_queue
  end 
 
  def getAdvancedActionQueue
	# 2D Array
    aq = Array.new(AppConfig::ACTION_TOTAL_AP) { Array.new }

    @pawns.each do |pawn|
      tick = 0
      
      pawn.actions.each do |action|
        if !aq[tick].kind_of? Array then aq[tick].push(Array.new) end
        
        aq[tick].push(action.actionToSpecificActionType)
        
        tick += action.actionToSpecificActionType.tick_cost.to_i
      end
	  
    end
    
	return aq
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
  
    
  def sortActionQueue(tick_queue)
    return tick_queue.sort! { |a,b| a.priority <=> b.priority }
  end
    
  def executeActionQueue!(tick_queue, passed_gamestatepawns)    
    for i in 0..tick_queue.size-1	  
      executeAction!(tick_queue[i],     passed_gamestatepawns[tick_queue[i].pawn_id])
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

    nodes = Hash.new()

    @gamestate.game_ship.logic_nodes.each do |logic_node| 
      if !(nodes[logic_node.node_type])then
        nodes[logic_node.node_type] = { :count => 0, :status => 0, :health => 0}      
      end

      nodes[logic_node.node_type][:count] += 1
      nodes[logic_node.node_type][:status] += logic_node.status.to_f
      nodes[logic_node.node_type][:health] += logic_node.health.to_f      
    end

    pawn.notifications.create!(:action_type => action.action_type, :params => nodes.to_json)
  end
end
