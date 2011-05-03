class LobbiesController < ApplicationController

  def index
    #@user_lobbies = Lobby.find_user_lobbies
    @user_lobbies = Lobby.find_available_lobbies(current_user)
    # if params[:leave_lobby]
      # return render :text => "i has params"
    # else
      # return render :text => "not params"
    # end
    if params.key? :leave
      #return render :text => "TODO: (user #{current_user.name}) leave lobby #{params[:leave]}"
      Lobby.leave(params[:leave], current_user.id)
    end
   
    if @user_lobbies.empty?
      #return render :text => 'its empty'
      @user_lobbies.push( Lobby.create_new )
      
      #@user_lobbies[0] = Lobby.find_available_lobbies
      #return render :text => @user_lobbies.class
    end
    
    #return render :text => "The object is #{@lobbies}"

  end
  
  def show
    @lobby = Lobby.find(params[:id])
    
    @lobby_text = ''
    # Lets see if the current user is already in the lobby, if not we add her to lobby_users
    # Needs an extra check to really make sure the lobby is not full a this time
    # ...and lets move this code to the model asap...
    if not @lobby.lobby_users.exists?(:user_id => current_user.id)
      @mylobbyuser = LobbyUser.create(:user_id => current_user.id, :lobby_id => params[:id])
      @lobby_text = 'Welcome to this lobby'
    else
      @mylobbyuser = @lobby.lobby_users.first
    end
  end
  
  def leave
    return render :text => "lobby"
    @lobby = Lobby.find(params[:id])
    b = @lobby.lobby_users.exists?(:user_id => current_user.id)
    return render :text => b
    #@lobby.lobby_users.delete(:user_id => current_user.id)
  end
  
  def join
    return render :text => 'LobbiesController:join'
  end
  
  def create
    return render :text => 'LobbiesController:create'
  end

end
