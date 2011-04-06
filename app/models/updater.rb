class Updater
  
  def update
    gamestate = Gamestate.find_by_id(current_user.session_id)
    
    now = Time.now
    gamestate.update_when
    
    # This is VERY elegant. And not done.
    if gamestate.update_when.hour > now.hour 
      if gamestate.update_when.min > now.min 
        gamestate.update_when.sec > now.sec 
          
        end
      end
    end

  end
  
  private  
    def crunch
      
      gamestate = Gamestate.find_by_id(current_user.session_id)
      
      =begin
      gamestates.each do |gamestate|
        pawns = Pawn.find_by_gamestate_id(gamestate.id)
      end
      =end
      
    end
end
