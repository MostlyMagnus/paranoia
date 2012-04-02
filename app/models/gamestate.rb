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
require 'actiontypedef'
require 'LoggerTypeDef'
require 'GamestatePawn'
require 'Gameship'
require 'StructDef'
require 'Lobby'

include Math

class Gamestate < ActiveRecord::Base
  attr_accessor :game_ship, :checked_grid, :gamestatePawns, :turn
  
  has_many :pawns, :dependent => :destroy
  has_many :user_events, :dependent => :destroy
  has_many :log_entries, :dependent => :destroy
  has_many :snapshots, :dependent => :destroy
  
  def self.create_new(lobby_id)
	# creates a new game
	# for a polished game, this is where we create (or call the creation) of an intricate scenario
	
	lobby = Lobby.find(lobby_id)
	
	# get this from unwritten method in Lobby
	# should add const file with timescale meaning for instance.
	
	ship = GameShip.new(1)
	node_status = ship.create_node_status_from_ship
	upd_when = DateTime.now.advance(:minutes => 1) # read from lobby to get this value, also timescale below
	gs = self.create(:ship_id => 1, :nodestatus => node_status, :timescale => 1.0, \
		:created_at => DateTime.now, :updated_at => DateTime.now, :update_when => upd_when)
	
	# pawns
	pawn_status = ''
	persona_id_ary = [1,2,3]*10 # temp debug
	lobby_usr_ary = lobby.lobby_users
	for lob_usr in lobby_usr_ary
		p = gs.pawns.create(:user_id => lob_usr.user_id, :gamestate_id => gs.id, :persona_id => persona_id_ary.pop(), :role => 1)
		pawn_status <<  p.id.to_s() << ';11,7;1.0$'
	end
	
	gs.playerstatus = pawn_status
	gs.save
	# probably check that everything was created ok before lobby is deleted
	Lobby.destroy(lobby_id)
	
  end
  
# == Setup
# This function needs to be called to build all the needed runtime data. This is in it's own function
# instead of the constructor since the constructor doesn't seem to get called when .find_by_id is used.
  
  def init(current_user)
    @current_user = current_user
    
    setup
    pawnSetup(current_user)
  end
  
  def setup
    @game_ship = GameShip.new(self.ship_id)
    
    @gamestatePawns = getGamestatePawns(self.playerstatus)
    
    @turn = ((self.updated_at - self.created_at)/(60 * self.timescale)).floor
  end

  def pawnSetup(current_user)    
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
    
    # Notifications shouldn't linger. Let's clean it up.
    crunch_notifications
    
    @actionQueue = ActionQueue.new(self)
    @actionQueue.buildExecuteAndClearActions!
    
    # Actions have been crunched, let's loop through events.
    crunch_events
    
    # Now let's do some idle logic for the correct amount of turns
    @updatesRequired = ((Time.now - self.update_when)/(60 * self.timescale)).floor

    # (3 litres/full tank of water)*amount of pawns = water consumption per turn
    # Should not use self.pawns.size but instead count the number of alive pawns.
    delta_water_per_turn = (3.0/AppConfig::WATER_FULL_TANK.to_f)*self.pawns.size;
	
    for i in 0..@updatesRequired
      # Idle logic goes here (detoriation, random events, etc)
 
      # Bump the turn for this update cycle
      @turn = ((self.updated_at.advance(:minutes => self.timescale * i)  - self.created_at)/(60 * self.timescale)).floor
      	  
      # distance from home: fixed number
      # expected turns: distance_from_home(1/difficulty_rating)
      # starting water: #expected_turns x #players x (1/difficulty_rating)
      # 
      # prob("node breaks") = 0.
      # scenario: difficulty_rating,
        
      # Drain water from the water nodes.
      @game_ship.drainWater(delta_water_per_turn)
      
      # Add a log entry regarding the water consumption this turn. :delta_water is how much water has been used.
      add_log_entry(LoggerTypeDef::LOG_CONSUMPTION, {:delta_water => delta_water_per_turn})

    end

    # When we're done, we update the update_when of our gamestate.
    self.update_when = self.update_when.advance(:minutes => self.timescale * (@updatesRequired.to_i+1))
    
    # Update self.nodestatus to reflect updates done
    self.nodestatus = @game_ship.build_nodestatus_string
    
    # Update self.playerstatus to reflect any updates done
    self.playerstatus = self.getPlayerStatus
    
    # We attempt to save the gamestate.
    if self.save
      "Gamestate updated"
    else
      self.errors.full_messages
    end
    
  end

  def crunch_notifications
    self.pawns.each do |pawn|
      pawn.notifications.clear
    end
  end
  
  def crunch_events
    # This code sorely needs to be rewritten.
    self.user_events.each do |event|
      event.lifespan-=1
      
      if event.lifespan < 0
        tally = 0
          
        event.event_inputs.each do |input|
          tally += input.params.to_i
        end
          
        if event.action_type == ActionTypeDef::A_VOTE
          if tally > 0
            @gamestatePawns.find{|pawn|pawn[1].pawn_id==event.params.split(",").last.to_i}[1].status = 0
          end
          
          self.add_log_entry(LoggerTypeDef::LOG_VOTE_COMPLETE, {:target_id => event.params.split(",").last.to_i, :tally => tally})
        end
      
        event.destroy
      else
        event.save
      end
    end    
  end

# == Playerstatus Functions

  def buildPlayerstatus
    playerstatusString = ""
    
    Pawn.find_all_by_gamestate_id(self.id).each do |pawn|      
      #id; x,y; status$
      playerstatusString << String(pawn.id)+";0,0;1$"
    end
    
    return playerstatusString
  end

  def getPlayerStatus    
    # Make sure the string is clean.
    tempPlayerStatus = ""
    
    # Add the right characters to tempPlayerStatus for each_value in the hash.
    # Each value is of the class GamestatePawn. We also convert all the values
    # to string values so we can combine it.
    @gamestatePawns.each_value do |gamestatePawn|
      tempPlayerStatus << gamestatePawn.pawn_id.to_s << ";" << gamestatePawn.x.to_s << "," << gamestatePawn.y.to_s << ";" << gamestatePawn.status.to_s << "$"
    end

    # Update the models playerstatus.
    return tempPlayerStatus
  end

      
  # == GamestatePawns Functions
  # All the code regarding gamestate pawns

  def getGamestatePawns(passed_playerstatus)

    tempGamestatePawns = Hash.new
    
    splitGamestatePawns = passed_playerstatus.split("$")
    
    splitGamestatePawns.each do |gamestate_pawn|    
      #id; x,y; status$
      splitPawn = gamestate_pawn.split(";")
      
      # Get the id
      pawn_id = splitPawn[0].to_i
  
      # Get the position
      pos = S_Position.new(splitPawn[1].split(",").first.to_i, splitPawn[1].split(",").last.to_i)
      
      # Get the status (alive, dead, etc)
      status = splitPawn[2].to_f
            
      tempGamestatePawns[pawn_id] = GamestatePawn.new(pawn_id, pos.x, pos.y, status, Persona.find_by_id(Pawn.find_by_id(pawn_id).persona_id))      
    end
    
    return tempGamestatePawns
  end

  def getGamestatePawnsAtGrid(grid, passed_gamestatepawns)
    list_of_pawns = Array.new
    
    passed_gamestatepawns.each do |gamestatePawn|
      if gamestatePawn[1].x == grid.x && gamestatePawn[1].y == grid.y then
        list_of_pawns.push(gamestatePawn[1])
      end
      
    end
    return list_of_pawns
  end
    
  def getGamestatePawnsNoPositions(passed_gamestatepawns)
    passed_gamestatepawns.each do |gamestatePawn|
      gamestatePawn[1].sanitize_position
    end
	
	return passed_gamestatepawns
  end

  def getVisibleGamestatePawns(user_pawn, passed_gamestatepawns = @gamestatePawns)
    #visiblePawns  = Array.new
          
    scanDirection(user_pawn,  1,   1, passed_gamestatepawns)
    scanDirection(user_pawn,  1,  -1, passed_gamestatepawns)
    scanDirection(user_pawn, -1,  -1, passed_gamestatepawns)
    scanDirection(user_pawn, -1,   1, passed_gamestatepawns)

    passed_gamestatepawns.each do |gamestatePawn|
      if(!gamestatePawn[1].positionAllowed) then
          gamestatePawn[1].sanitize_position
      end
      
    end
   
    return passed_gamestatepawns
  end
  
  def getEvents
    events = Hash.new
    
    events[:votes] = Array.new
    
    self.user_events.each do |event|
      if event.action_type == ActionTypeDef::A_VOTE then
        events[:votes].push(event)
      end
    end

    if events[:votes].empty? then events[:votes].push(nil) end
    
    events
  end
  
  # Scan direction is used to figure out what we can see. Related to the gamestatepawns since it spits out
  # a list of visible gamestatepawns.
  
  def scanDirection(user_pawn, multiplier_x, multiplier_y, passed_gamestatepawns = @gamestatePawns)
    # You see a long way down hallways.
    @view_distance = 35;
    
    pawn_position = getPosition(user_pawn, passed_gamestatepawns)

    for angle in 0..90 do
      ray_angle     = (angle*3.14)/180
      ray_delta     = S_Position.new(cos(ray_angle), sin(ray_angle))
      ray_traversed = S_Position.new(0,0)
	  hitWall = false
         		
		while (ray_traversed.x < ray_delta.x*@view_distance  && ray_traversed.y < ray_delta.y*@view_distance && !hitWall) do
			ray_grid = S_Position.new(pawn_position.x + multiplier_x*ray_traversed.x.round,
								  pawn_position.y + multiplier_y*ray_traversed.y.round)
								  
			if @game_ship.isThisARoom?(ray_grid) then	
			
				if !@game_ship.rooms[ray_grid.x][ray_grid.y].seen then
	
					getGamestatePawnsAtGrid(ray_grid, passed_gamestatepawns).each do |gamestatePawn|
						#visiblePawns.push(gamestatePawn)
						gamestatePawn.positionAllowed = true
						
					end
					@game_ship.rooms[ray_grid.x][ray_grid.y].seen = true
				end
			else
				hitWall = true
			end
							
			ray_traversed.x += ray_delta.x
			ray_traversed.y += ray_delta.y
		end

	end
  end
      
  # == JSON calls
  # The front end uses these to get the relevant information

  # 
  def JSON_Gamestate(current_user)
  	setup
  	pawnSetup(current_user)
  	  
    returned_data = Hash.new

    # set up the virtual pawn
    virtualPawn = getVirtualPawn(@pawn)

    # Add the possible actions for the vpawn grid to the hash
    @game_ship.rooms[virtualPawn.x][virtualPawn.y].possibleactions = possibleActions(virtualPawn)

  	# The actual gamestate. This should be cleaned up so that the node health isnt passed along.
  	returned_data[:gamestate] = self
  	
    # Get visible gamestatepawns sanitizes the gamestatepawns hash based on what the current vpawn sees.
  	returned_data[:gamestatePawns] = getVisibleGamestatePawns(@pawn)

  	returned_data[:ship] = @game_ship.JSON_formatForResponse
  	 	
  	returned_data[:virtualPawn] = virtualPawn
    returned_data[:possibleMoves] = @game_ship.whereCanIMoveFromHere?(virtualPawn)

    returned_data[:actionQueue] = getActionqueue

    returned_data[:events] = getEvents
  	returned_data[:log] = self.log_entries

    return returned_data
  end  
         
  # == 
  #
  def getActionqueue
    actionQueue = ActionQueue.new(self)
    
    return actionQueue.buildActionQueue(nil, @pawn)
  end
  
  # == Possible Actions
  # Returns a list of what can be done at the currently vpos
  
  def possibleActions(virtualPawn)
    # This should probably be changed so that actions are sorted based on where in the UI they
    # will appear. One way could be like this:
    
    # possibleActions = Hash.new
    
    # possibleActions[:PDA] = Array.new
    # PossibleActions[:PDA].push
    
    # possibleActions[:pawn#7] = Array.new
    # etc...
    
    # Push the actions into this array. Front end will deal with the rest.
    possibleActionIndex = Array.new

    # Things left to do here:
    #  Need code to do kill actions for specific targets, as well as the first person to enter. Unluckyyyy.
    #   Maybe this should be tied to a list of players in the game rather than th eplayers IN the room?
    #   The GUI would then display what players are actually in your room at the moment. Yes.
    #
    #  Convert node_type to something better.

    possibleActionIndex.push({:verbose => "Kill", :action_type => ActionTypeDef::A_KILL, :params => "-1"})
    #possibleActionIndex.push({:verbose => "Initiate vote", :action_type => ActionTypeDef::A_VOTE, :params => "-1"})
    possibleActionIndex.push({:verbose => "Check Shipstatus", :action_type => ActionTypeDef::A_STATUS, :params => "-1"})
	
	if(@game_ship.rooms[virtualPawn.x][virtualPawn.y].seen) then
		getGamestatePawnsAtGrid(S_Position.new(virtualPawn.x, virtualPawn.y), @gamestatePawns).each do |gspawn|
			unless @pawn.id == gspawn.pawn_id then
				possibleActionIndex.push({:verbose => "Kill "+gspawn.persona.name, :action_type => ActionTypeDef::A_KILL, :params =>  gspawn.pawn_id.to_s})
			end
		end
	end
    
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
  
  def getPosition(pawn, passed_gamestatepawns = @gamestatePawns)
    virtualPawn = GamestatePawn.new
        
    passed_gamestatepawns.each do |gamestatePawn|
      if gamestatePawn[1].pawn_id == pawn.id
        virtualPawn = gamestatePawn[1]
      end
    end
    
    S_Position.new(virtualPawn.x, virtualPawn.y)
  end

  # == Logger related code
  
  # Early implementation of the logger. This will look up the actual names etc needed and build
  # the correct string and input it into the logger table.
  
  def add_log_entry(log_type = nil, params = Hash.new)
    self.log_entries.create(:turn => @turn, :entry => get_log_entry(log_type, params))  
  end
  
  def get_log_entry(log_type = nil, params = Hash.new)
    case log_type
    when LoggerTypeDef::LOG_NIL
      "Oops! You passed a nil attribute to the logger."
    when LoggerTypeDef::LOG_CONSUMPTION	  
      (params[:delta_water].to_f*AppConfig::WATER_FULL_TANK.to_f).to_s << " " << AppConfig::WATER_UNIT << "(s) of water consumed this turn."
    when LoggerTypeDef::LOG_VOTE_INIT_SUCCESS        
      "" << Persona.find_by_id(self.pawns.find_by_id(params[:subject_a_id]).persona_id).name << " and " << Persona.find_by_id(self.pawns.find_by_id(params[:subject_b_id]).persona_id).name << " succesfully initiated a vote to airlock " << Persona.find_by_id(self.pawns.find_by_id(params[:target_id]).persona_id).name << "."
    when LoggerTypeDef::LOG_VOTE_INIT_FAIL
      "" << Persona.find_by_id(self.pawns.find_by_id(params[:subject_id]).persona_id).name << " failed to initiate a vote to airlock " << Persona.find_by_id(self.pawns.find_by_id(params[:target_id]).persona_id).name << "."
    when LoggerTypeDef::LOG_VOTE_COMPLETE
      "The vote to airlock " << Persona.find_by_id(self.pawns.find_by_id(params[:target_id]).persona_id).name << " tallied at " << params[:tally].to_s << "."
    when LoggerTypeDef::LOG_GENERIC
      params[:message]
    else 
      "Unhandled log type " << log_type.to_s << " with parameters: " << params
    end  
  end
  
  # == Snapshot related code ==
  
  def getSnapshots(turn = nil)
    snapshot_data = Array.new
    
    if @pawn.nil? then self.logger.debug "getSnapshots - @pawn is nil. Did you initialize this gamestate properly?" end
    
    self.snapshots.each do |snapshot|
      if snapshot.turn == turn.to_i || turn.nil? then
        visiblePawns = getVisibleGamestatePawns(@pawn, getGamestatePawns(snapshot.actions.split("#").first))
        
        snapshot_data.push({:turn => snapshot.turn, :tick => snapshot.tick, :visiblePawns => visiblePawns})
      end
    end
    
    return snapshot_data
  end
end
