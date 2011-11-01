class GamestatesController < ApplicationController
  # Remember to update this. :updateGamestate should be run whenever the user views
  # a page that relates to a specific gamestate.
  before_filter :updateGamestate, :only => :show

  def show    
    @gamestate = Gamestate.find_by_id(params[:id])
    @gamestate.setup
    
    @user_pawn        = Pawn.find_by_gamestate_id_and_user_id(params[:id], current_user.id)

    @visiblePawns     = @gamestate.getVisibleGamestatePawns(@user_pawn)

    @virtualPawn      = @gamestate.getVirtualPawn(@user_pawn)    
    @possibleActions  = @gamestate.possibleActions(@virtualPawn)
    
    @vPos             = @gamestate.getVirtualPosition(@user_pawn)
    @pos              = @gamestate.getPosition(@user_pawn)
         
    @access           = @gamestate.game_ship.whereCanIMoveFromHere?(@virtualPawn)
    @gamestatePawns   = @gamestate.gamestatePawns
    
  end
  
  def add_action
    @gamestate = Gamestate.find_by_id(params[:id])
    @pawns = Pawn.find_all_by_gamestate_id(@gamestate.id)
    
    @user_pawn = Pawn.find_by_gamestate_id_and_user_id(params[:id], current_user.id) 
    @user_pawn_actions = @user_pawn.actions
    
    if !@user_pawn_actions.last.nil? then
      @queue_number = Integer(@user_pawn_actions.last.queue_number)+1
    else
      @queue_number = 0
    end

    unless @queue_number > 4 then @user_pawn.actions.create(:queue_number => @queue_number, :action_type => params[:type], :params => params[:details]) end
    
    redirect_to gamestate_path
  end
  
  def remove_action
    @gamestate = Gamestate.find_by_id(params[:id])
    @pawns = Pawn.find_all_by_gamestate_id(@gamestate.id)
    
    @user_pawn = Pawn.find_by_gamestate_id_and_user_id(params[:id], current_user.id) 
    @user_pawn_actions = @user_pawn.actions
    
    @user_pawn_actions.last.delete
    
    redirect_to gamestate_path
  end
  
  def index
    return render :text => 'GamestateController:index'
  end
  
  def create        
   	game_id = Gamestate.create_new(params[:lobby_id])
	redirect_to mygames_path
  end
  
  def mygames
    @user = User.find_by_id(current_user)  
  end
  
  def ajax_gamestate
    @gamestate = Gamestate.find_by_id(params[:id])    
    render :text => @gamestate.to_json
  end
  
  def ajax_ship    
    @gamestate = Gamestate.find_by_id(params[:id])    
    render :text => @gamestate.AJAX_ship.to_json
  end
  
  def ajax_possibleactions
    @gamestate = Gamestate.find_by_id(params[:id])
    @gamestate.setup_game_ship
    render :text => @gamestate.AJAX_possibilities(current_user).to_json
  end

  def ajax_gamestatepawns
    @gamestate = Gamestate.find_by_id(params[:id])
    render :text => @gamestate.AJAX_GamestatePawns
  end
end
