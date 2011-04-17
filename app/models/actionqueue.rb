class ActionQueue
  attr_accessor :action_queue
  
  def initialize(gamestate_id)
    @pawns = Pawn.find_all_by_gamestate_id(gamestate_id) 
    @action_queue = Array.new
  end

  def buildExecuteAndClearActions     
    # Starting with tick #1, build it's action queue, sort it, execute it,
    # and then clear it. Repeat for the remaining ticks.    
    for tick in 1..5
      # Build the action queue based on the supplied tick
      buildActionQueue(tick)
      
      # Sorts the action queue based on priority derived from the action type
      # See action.rb for priority listings
      sortActionQueue
      
      # Now execute the action queue
      executeActionQueue
      
      # Clear the action queue before we do another tick
      clearActionQueue
    end

    # When done, clear the database of actions
    clearActions 
  end
  
  def getPawnsActionQueue(pawn_id)
    singleActionQueue = Array.new
    
    Action.find_all_by_pawn_id(pawn_id).each do |action|
      singleActionQueue.push(actionToSpecificActionType(action))
    end

  end
  
  private
  
  def clearActions
    # By now, we've executed all the pawns actions, so we remove them from the
    #   actions table.
    
    @pawns.each do |p|
      Action.destroy_all(:pawn_id => p.id)
    end
  end
   
  def clearActionQueue
    # Clear up the action_queue 
    @action_queue.clear
  end
  
  def buildActionQueue(action_tick)
    # Builds the action queue array by looking at the type attribute of each
    # action tied to a pawn and tick. Based on that type it is, we push a different
    # type of Action sub class into the array.
    
    # We should probably parse the params string here and assign the correct values
    # as attributes to the sub classes. That way we can keep the execution code
    # (further down) as centered on execution logic as possible.
     
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

    end
    
    returnAction
  end
    
  def sortActionQueue 
    @action_queue.sort! { |a,b| a.priority <=> b.priority }
  end
    
  def executeActionQueue    
    for i in 0..@action_queue.size-1
      executeAction(@action_queue[i])
    end
  end
  
  def executeAction(action)
    if      (action.kind_of? A_Nil)     then  executeA_Nil(action)
    elsif   (action.kind_of? A_Use)     then  executeA_Use(action)
    elsif   (action.kind_of? A_Repair)  then  executeA_Repair(action)
    elsif   (action.kind_of? A_Kill)    then  executeA_Kill(action)
    end
  end
   
  def executeA_Nil(action)   
  end
  
  def executeA_Use(action)
  end
  
  def executeA_Repair(action)
  end
  
  def executeA_Kill(action)
  end  
end
