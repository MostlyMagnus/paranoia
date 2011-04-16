# == Schema Information
# Schema version: 20110413180052
#
# Table name: gamestates
#
#  id           :integer         not null, primary key
#  ship_id      :integer
#  nodestatus   :string(255)
#  playerstatus :string(255)
#  timescale    :float
#  created_at   :datetime
#  updated_at   :datetime
#  update_when  :datetime
#
S_Position  = Struct.new(:x, :y)
S_Access    = Struct.new(:north, :south, :east, :west)

class Gamestate < ActiveRecord::Base
  attr_accessor :gamestatePawns
  
  def crunch
    # Get the gamestatePawns from this gamestates status string
    buildGamestatePawns
    
    # Since users won't be able to queue up more than one turn worth of actions, and several
    # turns will only happen when NO ONE has activated the gamestate for a given time, we can
    # do this outside of the turn loop, and then clear the user queues.
    buildExecuteAndClearActions

    # Now let's do some idle logic for the correct amount of turns
    @updatesRequired = ((Time.now - self.update_when)/(3600 * self.timescale)).floor

    for i in 1..@updatesRequired
      # Idle logic goes here (detoriation, random events, etc)  
    end

    # When we're done, we update the update_when of our gamestate.
    self.update_when = self.update_when.advance(:hours => self.timescale * (@updatesRequired+1))
    
    # Update self.playerstatus to reflect any updates done
    updatePlayerStatus
    
    # We attempt to save the gamestate.
    if self.save
      "Gamestate updated"
    else
      self.errors.full_messages
    end
    
  end

  def updatePlayerStatus
    # Make sure the string is clean.
    tempPlayerStatus = ""
    
    # Add the right characters to tempPlayerStatus for each_value in the hash.
    # Each value is of the class GamestatePawn. We also convert all the values
    # to string values so we can combine it.
    @gamestatePawns.each_value do |gamestatePawn|
      tempPlayerStatus += String(gamestatePawn.pawn_id) + ";" + String(gamestatePawn.x) + "," + String(gamestatePawn.y) + ";" + String(gamestatePawn.status) + "$"
    end
    
    # Update the models playerstatus.
    self.playerstatus = tempPlayerStatus
  end
  
  def buildGamestatePawns
    @gamestatePawns = Hash.new
    
    splitGamestatePawns = self.playerstatus.split("$")
    
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

  def makeGamestateSubjective!(current_user_id)
    buildGamestatePawns
       
    self.playerstatus = ""
    
    currentUserPawn = Pawn.find_by_user_id_and_gamestate_id(current_user_id, self.id)
    self.playerstatus = currentUserPawn
    
    self
  end
    
  private
  
  def buildExecuteAndClearActions 
    # This 
    @pawns = Pawn.find_all_by_gamestate_id(self.id) 
    @action_queue = Array.new
    
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
        # Here we pass the attributes hash of an Action class along to the
        # constructor for our subclasses. This will copy all the attributes
        # that match between the two, and hopefully leave the extra attributes
        # added to the subclass alone.
        
        # This does however generate a warning at the moment, since it tries
        # to copy .id as well, which is a protected attribute. 
        case p.actions[action_tick].action_type
          when ActionTypeDef::A_NIL
            
            @action_queue.push(A_Nil.new(p.actions[action_tick].attributes))
            
          when ActionTypeDef::A_USE
            
            @action_queue.push(A_Use.new(p.actions[action_tick].attributes))
            
          when ActionTypeDef::A_REPAIR
            
            @action_queue.push(A_Repair.new(p.actions[action_tick].attributes))
            
          when ActionTypeDef::A_KILL
            
            @action_queue.push(A_Kill.new(p.actions[action_tick].attributes))
            
        end
      end
    end  
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

class GamestatePawn
  def initialize(pawn_id, x, y, status)
    @pawn_id = pawn_id
    @x = x
    @y = y
    @status = status
  end
  
  attr_accessor :pawn_id, :x, :y, :status
end