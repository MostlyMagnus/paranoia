class Updater
  
  def needUpdate?
  end
  
  def crunch
    
    gamestates = Gamestate.all
    
    gamestates.each do |gamestate|
      pawns = Pawn.find_by_gamestate_id(gamestate.id)
      
      
    end
    
  end
end
