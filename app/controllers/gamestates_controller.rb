class GamestatesController < ApplicationController
  # Remember to update this. :updateGamestate should be run whenever the user views
  # a page that relates to a specific gamestate.
  before_filter :updateGamestate, :only => :show

  def show    
    @gamestate = Gamestate.find_by_id(params[:id])    
    
    @pawns = Pawn.find_all_by_gamestate_id(@gamestate.id)
    @user_pawn = Pawn.find_by_gamestate_id_and_user_id(params[:id], current_user.id)
       
    @ship = Ship.find_by_id(@gamestate.ship_id)
    
    @ship.buildRooms

    @vPos = @gamestate.getVirtualPosition(@user_pawn)
    @vRoom = @ship.rooms[@vPos.x][@vPos.y]
  
   # @allowedMoves = @ship.whereCanIMoveFromHere?(@user_pawn, @vPos)    
  end
  
  def index
  end
  
  def mygames
    @user = User.find_by_id(current_user)  
  end
  
  def ajax_gamestate
    @gamestate = Gamestate.find_by_id(params[:id])
    render :text => @gamestate.makeGamestateSubjective!(current_user.id).to_json
  end
  
  def ajax_ship    
    @gamestate = Gamestate.find_by_id(params[:id])
    @ship = Ship.find_by_id(@gamestate.ship_id)
    
    @ship.buildRooms
    
    @ship_JonasFormat = Hash.new
    
    @ship_JonasFormat[:success] = true
    @ship_JonasFormat[:name] = @ship.name
    @ship_JonasFormat[:width] = 16
    @ship_JonasFormat[:height] = 8
    
    @ship_JonasFormat[:map] = @ship.rooms
    
    render :text => @ship_JonasFormat.to_json
  end
  
  def ajax_possibleactions
    @gamestate = Gamestate.find_by_id(params[:id])
    @gamestate.buildGamestatePawns

    @ship = Ship.find_by_id(@gamestate.ship_id)
    @ship.buildRooms
    
    @user_pawn = Pawn.find_by_gamestate_id_and_user_id(params[:id], current_user.id)
    vPos = @gamestate.getVirtualPosition(@user_pawn)
    
    render :text => vPos.to_json
    
    possibleActions = Hash.new

    possibleActions[:moves]   = @ship.whereCanIMoveFromHere?(@user_pawn, vPos)
    possibleActions[:actions] = 0
    
    
    #render :text => possibleActions.to_json
  end

  def bogusdata
    @gamestate = Gamestate.find_by_id(params[:id])
    @pawns = Pawn.find_all_by_gamestate_id(@gamestate.id)

    @pawns.each do |p|
      for i in 1..5
        p.actions.create!(:queue_number => i, :action_type => ActionTypeDef::A_KILL)
      end
      
    end
   
    redirect_to root_path
  end  
end
