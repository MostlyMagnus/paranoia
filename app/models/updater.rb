class Updater
  
  def update
    Gamestate.find_by_id(current_user.session_id).update_when
 
    
    if Gamestate.find_by_id(current_user.session_id).update_when < Time.now
      crunch
    end

  end
  
  private  
    def crunch
      
      
    end
end
