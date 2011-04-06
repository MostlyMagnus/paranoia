class Updater
  def update
    # We do one get from the gamestate table to avoid too many queries
    
    # We need to get the current user in here some how
    gamestate = Gamestate.find_by_id(current_user.session_id)
 
    if gamestate.update_when < Time.now
      crunch
    end

  end
  
  private  
    def crunch
      
      #figure out how many turns we need to do

      # this is very ugly - figure out a better way
      @count = 0
      
      @gamestateTemp = gamestate
      @timeTemp = Time.now
      
      while gamestateTemp.update_when < timeTemp.now do
        @count = count + 1
        
        @gamestateTemp.update_when.advance(:hours => 2*(gamestate.timescale*1))  
      end
      # end of ugly
      
      
      # for each turn that needs to be done          
      gamestate.update_when.advance(:hours => 2*(gamestate.timescale*1))  
    end
end
