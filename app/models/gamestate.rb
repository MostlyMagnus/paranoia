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
  attr_accessor :game_ship, :checked_grid, :gamestatePawns
  
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
  
# == Setup
# This function needs to be called to build all the needed runtime data. This is in it's own function
# instead of the constructor since the constructor doesn't seem to get called when .find_by_id is used.
  
  def setup
    @game_ship = GameShip.new(self)
    
    @gamestatePawns = Hash.new
    buildGamestatePawns
  end

  def pawnSetup(current_user)
    # Always call this function in code that needs to use the pawn of the user viewing
    # the gamestate
    
    if @pawn.nil? then
      @pawn = Pawn.find_by_user_id_and_gamestate_id(current_user.id, self.id)
    end
  end
  

# == Crunch   
# Crunch runs all the necessary updates when that time comes.

  def crunch
    # Since users won't be able to queue up more than one turn worth of actions, and several
    # turns will only happen when NO ONE has activated the gamestate for a given time, we can
    # do this outside of the turn loop, and then clear the user queues.
    
    # Set up the handler to deal with all the nodes on the ship
    setup
    setup_game_ship
    buildGamestatePawns
    
    @actionQueue = ActionQueue.new(self)
    @actionQueue.buildExecuteAndClearActions!(@gamestatePawns)

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


# == Playerstatus Functions

  def buildPlayerstatus
    playerstatusString = ""
    
    Pawn.find_all_by_gamestate_id(self.id).each do |pawn|      
      #id; x,y; status$
      playerstatusString += String(pawn.id)+";0,0;1$"
    end
    
    return playerstatusString
  end

  def updatePlayerStatus
    buildGamestatePawns
    
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

      
  # == GamestatePawns Functions
  # All the code regarding gamestate pawns

  def buildGamestatePawns
    # Make sure we don't, for some reason, have no playerstatus string. If we
    # don't, buildPlayerstatus will build a default one for us, with all the pawns
    # at 0,0.
    #if self.playerstatus.nil? then self.playerstatus = buildPlayerstatus end

    @gamestatePawns.clear
            
    splitGamestatePawns = playerstatus.split("$")
    
    splitGamestatePawns.each do |gamestate_pawn|    
      #id; x,y; status$
      splitPawn = gamestate_pawn.split(";")
      
      # Get the id
      pawn_id = Integer(splitPawn[0])
  
      # Get the position
      pos = S_Position.new(Integer(splitPawn[1].split(",")[0]), Integer(splitPawn[1].split(",")[1]))
      
      # Get the status (alive, dead, etc)
      status = Integer(splitPawn[2])
            
      @gamestatePawns[pawn_id] = GamestatePawn.new(pawn_id, pos.x, pos.y, status )      
    end
  end

  def getGamestatePawns(grid)
    list_of_pawns = Array.new
    
    @gamestatePawns.each do |gamestatePawn|
      if gamestatePawn[1].x == grid.x && gamestatePawn[1].y == grid.y then
        list_of_pawns.push(gamestatePawn[1])
      end
      
    end
    return list_of_pawns
  end
    
  def getGamestatePawnsNoPositions
  end

  def getVisibleGamestatePawns(user_pawn)
    visiblePawns  = Array.new
    
    pawn_position = getPosition(user_pawn)
  
    @checked_grid = Hash.new(false)
    
    scanDirection(user_pawn, pawn_position, visiblePawns,  1,   1)
    scanDirection(user_pawn, pawn_position, visiblePawns,  1,  -1)
    scanDirection(user_pawn, pawn_position, visiblePawns, -1,  -1)
    scanDirection(user_pawn, pawn_position, visiblePawns, -1,   1)
    
    return visiblePawns
  end
  
  # Scan direction is used to figure out what we can see. Related to the gamestatepawns since it spits out
  # a list of visible gamestatepawns.
  
  def scanDirection(user_pawn, pawn_position, visiblePawns, multiplier_x, multiplier_y )
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
            getGamestatePawns(ray_grid).each do |gamestatePawn|
                visiblePawns.push(gamestatePawn)
            end
          else
            break 
          end
 
          @checked_grid[[ray_grid.x, ray_grid.y]] = true
        end
 
        ray_traversed.x += ray_delta.x
        ray_traversed.y += ray_delta.y
      end
    end
  end
      
  # == AJAX calls
  # The front end uses these to get the relevant information

  def AJAX_ship
    setup
    
    return @game_ship.AJAX_formatForResponse
  end
  
  def AJAX_possibilities(current_user)
    setup
    pawnSetup(current_user)
    
    virtualPawn = getVirtualPawn(@pawn)
    
    possibilities = Hash.new
    
    possibilities[:access] = @game_ship.whereCanIMoveFromHere?(virtualPawn)
    possibilities[:possibleActions] = possibleActions(virtualPawn)
       
    return possibilities 
  end
  
  def AJAX_GamestatePawns
    gamestatePawns = getGamestatePawns
    pawnsList = Array.new
    
    gamestatePawns.each do |gamestatePawn|
      #@gamestatePawn[1].x, @gamestatePawn[1].y = -1,-1
      
      #pawnsList.push(@gamestatePawn[1])
    end
    
    return gamestatePawns
  end

  # == Possible Actions
  # Returns a list of what can be done at the currently vpos
  
  def possibleActions(virtualPawn)
    # Push the actions into this array. Front end will deal with the rest.
    possibleActionIndex = Array.new

    # Things left to do here:
    #  Need code to do kill actions for specific targets, as well as the first person to enter. Unluckyyyy.
    #   Maybe this should be tied to a list of players in the game rather than th eplayers IN the room?
    #   The GUI would then display what players are actually in your room at the moment. Yes.
    #
    #  Convert node_type to something better.

    possibleActionIndex.push({:verbose => "Ambush (kill)", :action_type => ActionTypeDef::A_KILL, :params => "-1"})
    
    if !@game_ship.somethingInteractiveHere?(virtualPawn).nil? then
      possibleActionIndex.push({:verbose => "Use "      +@game_ship.somethingInteractiveHere?(virtualPawn).node_type, :action_type => ActionTypeDef::A_USE, :params => @game_ship.somethingInteractiveHere?(virtualPawn).id})
      possibleActionIndex.push({:verbose => "Repair "   +@game_ship.somethingInteractiveHere?(virtualPawn).node_type, :action_type => ActionTypeDef::A_REPAIR, :params => @game_ship.somethingInteractiveHere?(virtualPawn).id+", 1"})
      possibleActionIndex.push({:verbose => "Sabotage " +@game_ship.somethingInteractiveHere?(virtualPawn).node_type, :action_type => ActionTypeDef::A_REPAIR, :params => @game_ship.somethingInteractiveHere?(virtualPawn).id + ", -1"})
    end
    
    return possibleActionIndex    
  end


  # == Position related code

  def getVirtualPawn(pawn)
    # The virtual pawn is the current user pawn + any moves that are queued up.
    actionQueue = ActionQueue.new(self)
     
    virtualPawn = actionQueue.executeActionQueueOnPawn(pawn, ActionTypeDef::A_MOVE)    
  end

  def getVirtualPosition(pawn)
    virtualPawn = getVirtualPawn(pawn)
    
    S_Position.new(Integer(virtualPawn.x), Integer(virtualPawn.y))
  end
  
  def getPosition(pawn)
    virtualPawn = GamestatePawn.new
        
    @gamestatePawns.each do |gamestatePawn|
      if gamestatePawn[1].pawn_id == pawn.id
        virtualPawn = gamestatePawn[1]
      end
    end
    
    S_Position.new(virtualPawn.x, virtualPawn.y)
  end

end
