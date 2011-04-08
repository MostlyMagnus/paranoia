class PawnsController < ApplicationController
  def new        
   @pawn = Pawn.new
   
   @pawn.user_id = current_user.id
   @pawn.role = 1
   
   @gamestate_ids = Array.new
   
   Gamestate.all.each do |gamestate|
      if !current_user.pawns.find_by_gamestate_id(gamestate.id)
        @gamestate_ids.push(gamestate.id)
      end
    end
  end
  
  def create
    @pawn = Pawn.new(params[:pawn])
    
    if(!Pawn.find_by_user_id_and_gamestate_id(@pawn.user_id, @pawn.gamestate_id))
      if(@pawn.save)
        flash[:success] = "You succesfully joined this gamestate"
        redirect_to mygames_path
      else
        flash[:error] = pawn.errors.full_messages
        redirect_to joingame_path  
      end
    else
      flash[:error] = "Pawn already exists in this gamestate"
      redirect_to joingame_path
    end
      
    
  end
end
