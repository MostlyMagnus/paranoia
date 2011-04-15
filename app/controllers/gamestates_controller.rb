class GamestatesController < ApplicationController
  # Remember to update this. :updateGamestate should be run whenever the user views
  # a page that relates to a specific gamestate.
  before_filter :updateGamestate, :only => :show

  def show    
    @gamestate = Gamestate.find_by_id(params[:id])
    @gamestate.buildGamestatePawns
    
    @pawns = Pawn.find_all_by_gamestate_id(@gamestate.id)
    @user_pawn = Pawn.find_by_gamestate_id_and_user_id(params[:id], current_user.id)
       
    @ship = Ship.find_by_id(@gamestate.ship_id)
    
    @ship.buildRooms
    
    @vPos = S_Position.new(@gamestate.gamestatePawns[@user_pawn.id].x, @gamestate.gamestatePawns[@user_pawn.id].y) 
    @vRoom = @ship.rooms[@vPos.x][@vPos.y]
  
    @allowedMoves = @ship.whereCanIMoveFromHere?(@user_pawn, @vPos)    
  end
  
  def index
  end
  
  def mygames
    @user = User.find_by_id(current_user)  
  end
  
  def gamestate
    @gamestate = Gamestate.find_by_id(params[:id])
    @gamestate.buildGamestatePawns    
  end
  
  def ship
    @gamestate = Gamestate.find_by_id(params[:id])
    @ship = Ship.find_by_id(@gamestate.ship_id)
  end
  
  def possiblemoves
  end
  
end
