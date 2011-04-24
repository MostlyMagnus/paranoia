class LobbiesController < ApplicationController

  def index
    @lobbies = [Lobby.first]
    @nanja = "empty"
    #logger.debug "The object is #{@nanja}"
    #return render :text => "The object is #{@lobbies}"
    
    @user_lobbies = Lobby.find_user_lobbies
    
    #@lobbyjoin = Lobby.j
    @l_test = Lobby.find(1)
    #Logic should move into model
    if !@lobbies
      @nanja = "no lobbies creating"
      l = Lobby.new(:name => "Lobby X", :description => "A Game in Space. Traitors are involved", :min_slots => 4, :max_slots => 12 )
      l.save
      @lobbies = [Lobby.first]
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lobbies }
    end
  end
  
  def show
    @lobby = Lobby.find(params[:id])
    #return render :text => 'hello'
    
  end
  
  def join
    return render :text => 'this is join!'
  end
  
  def create
    return render :text => 'LobbiesController:create'
  end

end
