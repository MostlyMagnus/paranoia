module GamestatesHelper
  def updateGamestate
    gamestate = Gamestate.find_by_id(params[:id])
    
    if gamestate.update_when < Time.now
      flash[:success] = gamestate.crunch
    else
      flash[:success] = "We are up to date."
    end
  end
    
  def nextUpdate 
    Gamestate.find_by_id(params[:id]).update_when.localtime
  end 
    
  def currentTurn
    gamestate = Gamestate.find_by_id(params[:id])
    
    ((gamestate.updated_at - gamestate.created_at)/(3600 * gamestate.timescale)).floor
  end
    
end
