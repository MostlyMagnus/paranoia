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


require 'ActionQueue'
require 'ActionTypeDef'
require 'GamestatePawn'
require 'Gameship'
require 'StructDef'
require 'Lobby'

include Math

class Gamestate < ActiveRecord::Base
  attr_accessor :gamestatePawns, :game_ship, :checked_grid
    
  
  def self.create_new(lobby_id)
	# creates a new game
	
	logger.debug "-----\n"
	logger.debug lobby_id
	logger.debug "-----\n"
	#TODO:
	# create list of users and assign them stuff
	# get this from unwritten method in Lobby
	# should add const file with timescale meaning for instance.
	upd_when = DateTime.now.advance(:minutes => 10)
		
	gs = self.create(:ship_id => 1, :timescale => 1.0, :created_at => DateTime.now, :updated_at => DateTime.now, :update_when => upd_when)
	
	# probably check that everything was created ok before lobby is deleted
	Lobby.delete(lobby_id)
	
  end
  
  def pawnSetup(current_user)
    # Always call this function in code that needs to use the pawn of the user viewing
    # the gamestate
    
    if @pawn.nil? then
      @pawn = Pawn.find_by_user_id_and_gamestate_id(current_user.id, self.id)
    end
  end
  
  def setup_game_ship
    @game_ship = GameShip.new(self)
  end
  
  def crunch
    # Since users won't be able to queue up more than one turn worth of actions, and several
    # turns will only happen when NO ONE has activated the gamestate for a given time, we can
    # do this outside of the turn loop, and then clear the user queues.
    
    # Set up the handler to deal with all the nodes on the ship
    setup_game_ship
    
    @actionQueue = ActionQueue.new(self)
    @actionQueue.buildExecuteAndClearActions!

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

  def getVisibleGamestatePawns(user_pawn)
    actionQueue = ActionQueue.new(self)
    
    visiblePawns  = Array.new   
    pawn_position = getPosition(user_pawn)
  
    @checked_grid = Hash.new(false)
    
    scanDirection(user_pawn, actionQueue, pawn_position, visiblePawns,  1,   1)
    scanDirection(user_pawn, actionQueue, pawn_position, visiblePawns,  1,  -1)
    scanDirection(user_pawn, actionQueue, pawn_position, visiblePawns, -1,  -1)
    scanDirection(user_pawn, actionQueue, pawn_position, visiblePawns, -1,   1)
    
    return visiblePawns
  end
  
  def scanDirection(user_pawn, actionQueue, pawn_position, visiblePawns, multiplier_x, multiplier_y)
    @view_distance = 5;
    
    for angle in 0..90 do
      ray_angle     = (angle*3.14)/180
      ray_delta     = S_Position.new(cos(ray_angle), sin(ray_angle))
      ray_traversed = S_Position.new(0,0)
              
      while ray_traversed.x < ray_delta.x*@view_distance  && ray_traversed.y < ray_delta.y*@view_distance  do
        ray_grid = S_Position.new(pawn_position.x + multiplier_x*ray_traversed.x.round,
                                  pawn_position.y + multiplier_y*ray_traversed.y.round)
               
        unless @checked_grid[[ray_grid.x, ray_grid.y]] then
          if @game_ship.isThisARoom?(ray_grid)
            actionQueue.getGamestatePawns(ray_grid).each do |gamestatePawn|
                visiblePawns.push(gamestatePawn)
            end
          else
            break 
          end
 
          @checked_grid[[ray_grid.x, ray_grid.y]] = true
        end
 
        ray_traversed.x = ray_traversed.x + ray_delta.x
        ray_traversed.y = ray_traversed.y + ray_delta.y
      end
    end    
  end
    
  def getGamestatePawns
    actionQueue = ActionQueue.new(self)
    
    actionQueue.gamestatePawns
  end
  
  def getVirtualPawn(pawn)
    # The virtual pawn is the current user pawn + any moves that are queued up.
    actionQueue = ActionQueue.new(self)
     
    virtualPawn = actionQueue.executeActionQueueOnPawn(pawn, ActionTypeDef::A_MOVE)
    
  end
    
  def getVirtualPosition(pawn)
    self.logger.debug "getVirtualPosition"
    
    virtualPawn = getVirtualPawn(pawn)
    
    S_Position.new(Integer(virtualPawn.x), Integer(virtualPawn.y))
  end
  
  def getPosition(pawn)
    actionQueue = ActionQueue.new(self)    
    virtualPawn = actionQueue.gamestatePawns[pawn.id]
    
    S_Position.new(virtualPawn.x, virtualPawn.y)
  end
  
  def AJAX_ship
    setup_game_ship
    
    return @game_ship.AJAX_formatForResponse
  end
  
  def AJAX_possibilities(current_user)
    shipSetup
    pawnSetup(current_user)
    
    virtualPawn = getVirtualPawn(@pawn)
    
    possibilities = Hash.new
    
    possibilities[:access] = @ship.whereCanIMoveFromHere?(virtualPawn)
    possibilities[:possibleActions] = possibleActions(virtualPawn)
       
    return possibilities 
  end
  
  def possibleActions(virtualPawn)
    possibleActionIndex = Hash.new
    
    possibleActionIndex[:a_use]     = @game_ship.somethingInteractiveHere?(virtualPawn)        
    possibleActionIndex[:a_kill]    = true  # You can always queue up a kill action.
    possibleActionIndex[:a_repair]  = @game_ship.somethingInteractiveHere?(virtualPawn)
    possibleActionIndex[:a_sabotage]     = @game_ship.somethingInteractiveHere?(virtualPawn)
     
    return possibleActionIndex
  end
  
  def possibleActions2(virtualPawn)
    self.logger.debug "possibleActions2"
    possibleActionIndex = Array.new
    
    possibleActionIndex.push(Hash.new(:action_type => 0, :params => "0,0"))
    
    #possibleActionIndex[:a_use]     = @game_ship.somethingInteractiveHere?(virtualPawn)        
    #possibleActionIndex[:a_kill]    = true  # You can always queue up a kill action.
    #possibleActionIndex[:a_repair]  = @game_ship.somethingInteractiveHere?(virtualPawn)
    #possibleActionIndex[:a_sabotage]     = @game_ship.somethingInteractiveHere?(virtualPawn)
     
    return possibleActionIndex    
  end
  
  def somethingInteractiveHere?(virtualPawn)
    #@game_ship
    return false
  end
  
end
