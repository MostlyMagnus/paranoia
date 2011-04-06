class Updater
  def update
    # We do one get from the gamestate table to avoid too many queries
    gamestate = Gamestate.find_by_id(current_user.session_id)
 
    if gamestate.update_when < Time.now
      crunch
    end

  end
  
  private  
    def crunch
      
      # for each turn that needs to be done      
      gamestate.update_when.advance(:hours => 2*(gamestate.timescale*1))  
    end
end
