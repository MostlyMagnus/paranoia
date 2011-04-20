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
require 'ActionQueue'
require 'ActionTypeDef'
require 'GamestatePawn'
require 'StructDef'

class Gamestate < ActiveRecord::Base
  attr_accessor :gamestatePawns
  def initialize
    @actionQueue = ActionQueue.new(self)
    super
  end
  
  def crunch
    # Get the gamestatePawns from this gamestates status string

    #buildGamestatePawns
        
    # Since users won't be able to queue up more than one turn worth of actions, and several
    # turns will only happen when NO ONE has activated the gamestate for a given time, we can
    # do this outside of the turn loop, and then clear the user queues.
    #buildExecuteAndClearActions
    
    @actionQueue = ActionQueue.new(self)
    @actionQueue.buildExecuteAndClearActions

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
    @actionQueue.gamestatePawns.each_value do |gamestatePawn|
      tempPlayerStatus += String(gamestatePawn.pawn_id) + ";" + String(gamestatePawn.x) + "," + String(gamestatePawn.y) + ";" + String(gamestatePawn.status) + "$"
    end

    # Update the models playerstatus.
    self.playerstatus = tempPlayerStatus
  end

  def makeGamestateSubjective!(current_user_id)
    # This code needs to be written so that it returns a gamestate where only the visible pawns are
    # in the playerstatus. For now, return the entire thing.
    actionQueue = ActionQueue.new(self)
        
    self.playerstatus = actionQueue.gamestatePawns
    
    self
  end
  
  def possibleActions(current_user_id)
    
  end
  
  def getVirtualPosition(pawn)
    actionQueue = ActionQueue.new(self)
     
    virtualPawn = actionQueue.executeActionQueueOnPawn(pawn, ActionTypeDef::A_MOVE)

    #return the pos of virutalPawn to test
    S_Position.new(Integer(virtualPawn.x), Integer(virtualPawn.y))
  end
  
  def getPosition(pawn)
    actionQueue = ActionQueue.new(self)
    
    virtualPawn = actionQueue.gamestatePawns[pawn.id]
    
    S_Position.new(virtualPawn.x, virtualPawn.y)
  end
end

