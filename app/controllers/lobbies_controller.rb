class LobbiesController < ApplicationController

  def index
    @user_lobbies = Lobby.find_user_lobbies
    @user_lobbies = Lobby.find_available_lobbies
    #return render :text => "The object is #{@lobbies}"

  end
  
  def show
    @lobby = Lobby.find(params[:id])
  end
  
  def join
    return render :text => 'LobbiesController:join'
  end
  
  def create
    return render :text => 'LobbiesController:create'
  end

end
