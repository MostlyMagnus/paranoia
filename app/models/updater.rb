class Updater
  
  def update    

    if Gamestate.find_by_id(current_user.session_id).update_when < Time.now
      crunch
    end

  end
  
  private  
    def crunch
      
      
    end
end
