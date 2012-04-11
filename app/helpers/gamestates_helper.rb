module GamestatesHelper
  def updateGamestate
    ActiveRecord::Base.connection.execute('UPDATE gamestates SET locked_by = "'+request.session_options[:id].to_s+'" WHERE id = '+params[:id].to_s+' AND locked_by = "nil"')
    gamestate = Gamestate.find_by_id(params[:id])

    if(gamestate.locked_by == request.session_options[:id]) then

      if gamestate.update_when < Time.now
        flash[:success] = gamestate.crunch
      else
        flash[:success] = "We are up to date."
      end
      
      gamestate.locked_by = "nil"

      if gamestate.changed? then gamestate.save end
    else
      print "Gamestate already locked by another session."
    end

  end
    
  def nextUpdate 
    Gamestate.find_by_id(params[:id]).update_when.localtime
  end 
    
  def currentTurn
    gamestate = Gamestate.find_by_id(params[:id])
    
    ((gamestate.updated_at - gamestate.created_at)/(60 * gamestate.timescale)).floor
  end

#  def actionQueue
#    Pawn.find_by_user_id_and_gamestate_id(current_user.id, params[:id]).actionQueue
#  end
    
end
