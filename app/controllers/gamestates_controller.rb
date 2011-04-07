class GamestatesController < ApplicationController
  def show
    @gamestate = Gamestate.find_by_id(params[:id])
  end
  
  def join
    @gamestate = Gamestate.find_by_id(params[:id])
    
    @pawn = Pawn.new(:user_id => current_user.id, :gamestate_id => params[:id], :role => 1)
  end
end
