require 'ActionTypeDef'
require 'GamestatePawn'

class ActionQueue
  attr_accessor :action_queue
  
  def initialize(gamestate)
    @gamestate = gamestate
    
    @pawns = Pawn.find_all_by_gamestate_id(@gamestate.id) 
    @action_queue = Array.new
  end

  def buildExecuteAndClearActions
    @gamestatePawns = Hash.new
   
    buildGamestatePawns
    
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
    #clearActions
    
    @gamestatePawns
  end
  
  def getPawnsActionQueue(pawn_id)
    singleActionQueue = Array.new
    
    Action.find_all_by_pawn_id(pawn_id).each do |action|
      singleActionQueue.push(actionToSpecificActionType(action))
    end
  end
  
  def executeActionQueueOnGamestatePawn(gamestatePawn, actionFilter = ActionTypeDef::A_NIL)    
    if(actionFilter == ActionTypeDef::A_NIL)
      #executeAction(action, gamestatePawn)
      print "No filter"
    else
      Action.find_all_by_pawn_id(gamestatePawn.pawn_id).each do |action|
        if(action.action_type == actionFilter)
          executeAction(actionToSpecificActionType(action), gamestatePawn) 
        end 
      end
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
    # Wait... Do I actually ever... Something is wrong here.
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
    
  def sortActionQueue 
    @action_queue.sort! { |a,b| a.priority <=> b.priority }
  end
    
  def executeActionQueue    
    for i in 0..@action_queue.size-1
      # How do I pass the variable along as a reference? 
      executeAction(@action_queue[i], @gamestatePawns[@action_queue[i].pawn_id])    
    end
  end
  
  def executeAction(action, gamestatePawn)
    if      (action.kind_of? A_Nil)     then  executeA_Nil(action, gamestatePawn)
    elsif   (action.kind_of? A_Use)     then  executeA_Use(action, gamestatePawn)
    elsif   (action.kind_of? A_Repair)  then  gamestatePawn = executeA_Repair(action, gamestatePawn)
    elsif   (action.kind_of? A_Kill)    then  executeA_Kill(action, gamestatePawn)
    elsif   (action.kind_of? A_Move)    then  executeA_Move(action, gamestatePawn)
    end    
  end
   
  def executeA_Nil(action, gamestatePawn)   
  end
  
  def executeA_Use(action, gamestatePawn)
  end
  
  def executeA_Repair(action, gamestatePawn)
  end
  
  def executeA_Kill(action, gamestatePawn)
  end
  
  def executeA_Move(action, gamestatePawn)    
    gamestatePawn.x = action.toX
    gamestatePawn.y = action.toY
  end
  
  def buildGamestatePawns        
    splitGamestatePawns = @gamestate.playerstatus.split("$")
    
    splitGamestatePawns.each do |gamestate_pawn|    
      #id; x,y; status$
      splitPawn = gamestate_pawn.split(";")
      
      # Get the id
      pawn_id = Integer(splitPawn[0])
  
      # Get the position
      pos = S_Position.new(Integer(splitPawn[1].split(",")[0]), Integer(splitPawn[1].split(",")[1]))
      
      # Get the status (alive, dead, etc)
      status = Integer(splitPawn[2])
      
      # Lets put it in our array        
      @gamestatePawns[pawn_id] = GamestatePawn.new(pawn_id, pos.x, pos.y, status )      
    end
  end
  
end
