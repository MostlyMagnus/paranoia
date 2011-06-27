class LobbiesController < ApplicationController

  def index
    @user_lobbies = Lobby.find_available_lobbies(current_user)
    if @user_lobbies.empty?
      @user_lobbies.push( Lobby.create_new )   
    end   
  end
  
  def show
    @lobby = Lobby.find(params[:id])
    
    # currently always tries to join lobby and lets the Lobby check if we are already in it or not.
    l = Lobby.join(@lobby, current_user.id)
  end
  
  def edit # leave the lobby
    Lobby.leave(params[:id], current_user.id)
    flash[:success] = "You left the lobby"
    redirect_to lobbies_path
  end
  
  def join
    return render :text => 'LobbiesController:join'
  end
  
  def create
    return render :text => 'LobbiesController:create'
  end

  def destroy
    @lobby = Lobby.find(params[:id])
    @lobby.destroy
    
    
    respond_to do |format|
      format.html { redirect_to (lobbies_url) }
      #format.xml  { head :ok }
    end
    
  end
  
end
