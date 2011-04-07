class PawnsController < ApplicationController
  def new        
   @pawn = Pawn.new
   
   @pawn.user_id = current_user
   @pawn.role = 1
   
  end
  
  def create
    @pawn = Pawn.new(params[:pawn])
    
    
    if @pawn.save      
      redirect_to root_path
    else      
      
    end
  end
end
