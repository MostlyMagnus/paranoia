module GamestatesHelper
  def updateGamestate
    gamestate = Gamestate.find_by_id(params[:id])
      
    if gamestate.update_when < Time.now
      crunch(gamestate)
    else
      flash[:success] = "We are up to date."
    end
  end
    
  def nextUpdate 
    Gamestate.find_by_id(params[:id]).update_when.localtime
  end
  
  def aq
    @gamestate = Gamestate.find_by_id(params[:id])
    @pawns = Pawn.find_all_by_gamestate_id(@gamestate.id)    

    action_queue = Array.new
    
    for i in 0..4 
      @pawns.each do |p|
        if !p.actions[i].nil?
          
          case p.actions[i].action_type
            when ActionTypeDef::A_NIL
              
              action_queue.push(A_Nil.new(p.actions[i]))
              
            when ActionTypeDef::A_USE
              
              action_queue.push(A_Use.new(p.actions[i]))
              
            when ActionTypeDef::A_REPAIR
              
              action_queue.push(A_Repair.new(p.actions[i]))
              
            when ActionTypeDef::A_KILL
              
              action_queue.push(A_Kill.new(p.actions[i]))
              
          end
 
        end
      end
      
      # Lets sort
      action_queue.sort! { |a,b| a.priority <=> b.priority }
      
      # The array is now sorted on priority, with the LOWEST priority value first.
      concat " Action Turn "
      concat i
      concat " [[[ "
      for j in 0..action_queue.size-1
        concat " "
        concat action_queue[j]
        concat " at prio "
        concat action_queue[j].priority
        concat " "
      end
      concat " ]]] "
 
      # Here we have our action_queue complete
      # We should empty it.
      action_queue.clear
    end
    
    #for i in 0..action_queue.size-1
    #  concat action_queue[i].kind_of? A_Nil
    #  concat action_queue[i].priority
    #end
    
  end
    
  def currentTurn
    gamestate = Gamestate.find_by_id(params[:id])
    
    ((gamestate.updated_at - gamestate.created_at)/(3600 * gamestate.timescale)).floor
  end
    
  def crunch(gamestate)
    # Since users won't be able to queue up more than one turn worth of actions, and several
    # turns will only happen when NO ONE has activated the gamestate for a given time, we can
    # do this outside of the turn loop, and then clear the user queues.
    
    Pawn.find_all_by_gamestate_id(gamestate.id).each do |p|      
    end

    # Now let's do some idle logic for the correct amount of turns
    @updatesRequired = ((Time.now - gamestate.update_when)/(3600 * gamestate.timescale)).floor

    for i in 1..@updatesRequired
      # Idle logic goes here (detoriation, random events, etc)  
    end

    # When we're done, we update the update_when of our gamestate.
    gamestate.update_when = gamestate.update_when.advance(:hours => gamestate.timescale * (@updatesRequired+1))
    
    # We attempt to save the gamestate.
    if gamestate.save
      flash[:success] = "Gamestate updated"
    else
      flash[:error] = gamestate.errors.full_messages
    end
    
  end    
end
