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
  end
  
  def index
  end
  
  def mygames
    @user = User.find_by_id(current_user)  
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
