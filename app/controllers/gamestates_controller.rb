class GamestatesController < ApplicationController
  before_filter :updateGamestate

  def show    
    @gamestate = Gamestate.find_by_id(params[:id])
        
  end
end
