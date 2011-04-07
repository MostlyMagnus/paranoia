class GamestatesController < ApplicationController
  def show
    @gamestate = Gamestate.find_by_id(params[:id])
  end
  
  def join   
  end
end
