# == Schema Information
# Schema version: 20110406190449
#
# Table name: gamestates
#
#  id              :integer         not null, primary key
#  ship_id         :integer
#  nodestatus      :string(255)
#  playerstatus    :string(255)
#  playerlocations :string(255)
#  timescale       :float
#  created_at      :datetime
#  updated_at      :datetime
#  update_when     :datetime
#

class Gamestate < ActiveRecord::Base

  
  def crunch
    # Since users won't be able to queue up more than one turn worth of actions, and several
    # turns will only happen when NO ONE has activated the gamestate for a given time, we can
    # do this outside of the turn loop, and then clear the user queues.
    self.buildExecuteAndClearActions

    # Now let's do some idle logic for the correct amount of turns
    @updatesRequired = ((Time.now - self.update_when)/(3600 * self.timescale)).floor

    for i in 1..@updatesRequired
      # Idle logic goes here (detoriation, random events, etc)  
    end

    # When we're done, we update the update_when of our gamestate.
    self.update_when = self.update_when.advance(:hours => self.timescale * (@updatesRequired+1))
    
    # We attempt to save the gamestate.
    if self.save
      #flash[:success] = "Gamestate updated"
    else
      #flash[:error] = gamestate.errors.full_messages
    end
    
  end
  
    
  def buildExecuteAndClearActions 
    # This 
    @pawns = Pawn.find_all_by_gamestate_id(self.id) 
    @action_queue = Array.new
    
    for tick in 1..5
      buildActionQueue(tick)
      sortActionQueue
      
      executeActionQueue
      
      clearActionQueue
    end
    
  end
   
  def clearActionQueue
    @action_queue.clear
  end
  
  def buildActionQueue(action_tick)
   
    @pawns.each do |p|
      if !p.actions[action_tick].nil?
        case p.actions[action_tick].action_type
          when ActionTypeDef::A_NIL
            
            @action_queue.push(A_Nil.new(p.actions[action_tick]))
            
          when ActionTypeDef::A_USE
            
           @action_queue.push(A_Use.new(p.actions[action_tick]))
            
          when ActionTypeDef::A_REPAIR
            
            @action_queue.push(A_Repair.new(p.actions[action_tick]))
            
          when ActionTypeDef::A_KILL
            
            @action_queue.push(A_Kill.new(p.actions[action_tick]))
            
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
   
  # Question is, do we parse the params here, or when we push things into 
  # @action_queue?
  def executeA_Nil(action)
  end
  
  def executeA_Use(action)
  end
  
  def executeA_Repair(action)
  end
  
  def executeA_Kill(action)
  end
  
end
