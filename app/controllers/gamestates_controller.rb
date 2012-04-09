class GamestatesController < ApplicationController
  # Remember to update this. :updateGamestate should be run whenever the user views
  # a page that relates to a specific gamestate.
  
  # Must solve this somehow for client -- update on get gamestate?
  #before_filter :updateGamestate, :only => :show
  before_filter :updateGamestate

  def show    
    @gamestate = Gamestate.find_by_id(params[:id])
    @gamestate.init(current_user)
    
    @events = @gamestate.getEvents
    
    @user_pawn        = Pawn.find_by_gamestate_id_and_user_id(params[:id], current_user.id)

    @visiblePawns     = @gamestate.getVisibleGamestatePawns(@user_pawn)

    @virtualPawn      = @gamestate.getVirtualPawn(@user_pawn)    
    @possibleActions  = @gamestate.possibleActions(@virtualPawn)
    
    @vPos             = @gamestate.getVirtualPosition(@user_pawn)
    @pos              = @gamestate.getPosition(@user_pawn)
         
    @access           = @gamestate.game_ship.whereCanIMoveFromHere?(@virtualPawn)
    @gamestatePawns   = @gamestate.gamestatePawns    
  end

  def create        
   	game_id = Gamestate.create_new(params[:lobby_id])
	redirect_to mygames_path
  end
    
  # POST CODE
  
  def add_action
    # Lets sanity check the action we're trying to add.
    @gamestate = Gamestate.find_by_id(params[:id])
    @pawns = Pawn.find_all_by_gamestate_id(@gamestate.id)
    
    @user_pawn = Pawn.find_by_gamestate_id_and_user_id(params[:id], current_user.id) 
    @user_pawn_actions = @user_pawn.actions
    
    if !@user_pawn_actions.last.nil? then
      @queue_number = Integer(@user_pawn_actions.last.queue_number)+1
    else
      @queue_number = 0
    end
    
    # if params[:type] is move then
    # => is valid move? virtualPawn + details 
    # end


    if @user_pawn.addAction(@queue_number, params[:type], params[:details]) then
      render :text => "1"
    else
      render :text => "0"
    end
    
    #redirect_to gamestate_path
  end
  
  def remove_action
    @gamestate = Gamestate.find_by_id(params[:id])
    @pawns = Pawn.find_all_by_gamestate_id(@gamestate.id)
    
    @user_pawn = Pawn.find_by_gamestate_id_and_user_id(params[:id], current_user.id) 
    @user_pawn_actions = @user_pawn.actions
    
    @user_pawn_actions.last.delete
    
    #redirect_to gamestate_path
  end
  
  def add_text
    @gamestate = Gamestate.find_by_id(params[:id])
    render :text => @gamestate.addText(current_user, params[:text])


  end

  def get_logs 
    @gamestate = Gamestate.find_by_id(params[:id])
    @user_pawn = Pawn.find_by_gamestate_id_and_user_id(params[:id], current_user.id) 

    lines = Array.new

    @gamestate.log_entries.each do |log_entry|
      lines.push({:line_id => log_entry.id, :pawn => "System", :text => log_entry.entry, :created_at => log_entry.created_at, :type => "log"})
    end    

    @user_pawn.notifications.each do |notification| 
      lines.push({:line_id => notification.id, :pawn => "Notification", :text => notification.params, :created_at => notification.created_at, :type => "notification"})
    end

    lines.sort_by { |line| line[:created_at] }

    render :text => lines.to_json
  end

  def get_text
    @gamestate = Gamestate.find_by_id(params[:id])
    @pawns = Pawn.find_all_by_gamestate_id(@gamestate.id)

    @user_pawn = Pawn.find_by_gamestate_id_and_user_id(params[:id], current_user.id) 

    lines = Array.new

    @user_pawn.heards.where('line_id > ?', params[:id_greater_than]).each do |heard|
      lines.push({:line_id => heard.line_id, :pawn => Line.find_by_id(heard.line_id).name(heard.scramble), :text => Line.find_by_id(heard.line_id).scramble(heard.scramble, heard.salt)})
    end

    render :text => lines.to_json
  end

  # GET code  
  
  def index
    @user = User.find_by_id(current_user)  
	
	gs_ids = Array.new
	@user.pawns.each do |pawn| 
		gs_ids.push(pawn.gamestate_id)
	end
	
	render :text => gs_ids.to_json
  end  
  
  def json_gamestate
    @gamestate = Gamestate.find_by_id(params[:id])    
    render :text => @gamestate.JSON_Gamestate(current_user).to_json
  end
  
  def json_ship    
    @gamestate = Gamestate.find_by_id(params[:id])    
    render :text => @gamestate.JSON_ship.to_json
  end
  
  def json_possibleactions
    @gamestate = Gamestate.find_by_id(params[:id])
    render :text => @gamestate.JSON_possibilities(current_user).to_json
  end

  def json_clean_gamestatepawns
    @gamestate = Gamestate.find_by_id(params[:id])
    render :text => @gamestate.JSON_CLEAN_GamestatePawns(current_user).to_json
  end
  
  def json_snapshots
    @gamestate = Gamestate.find_by_id(params[:id])
    @gamestate.init(current_user)
      
    render :text => @gamestate.getSnapshots(params[:turn]).to_json
  end
  
  def json_pawndata
	@gamestate = Gamestate.find_by_id(params[:id])
    @gamestate.init(current_user)
    
	render :text => @gamestate.JSON_pawnData(current_user).to_json
  end
  
  def json_actionqueue
	@gamestate = Gamestate.find_by_id(params[:id])
    @gamestate.init(current_user)
	
	render :text => @gamestate.JSON_actionQueue.to_json
  end
end
