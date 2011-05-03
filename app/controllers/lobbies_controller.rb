class LobbiesController < ApplicationController

  def index
    @user_lobbies = Lobby.find_available_lobbies(current_user)
    if @user_lobbies.empty?
      @user_lobbies.push( Lobby.create_new )   
    end   
  end
  
  def show
    @lobby = Lobby.find(params[:id])
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

end
