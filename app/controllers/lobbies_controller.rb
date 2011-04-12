class LobbiesController < ApplicationController

  def index
    @lobbies = Lobby.all
    
    if !@lobbies
      l = Lobby.new(:name => "Lobby X", :description => "A Game in Space. Traitors are involved", :min_slots => 4, :max_slots => 12 )
      @lobbies.push(l)
      @lobbies.save
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lobbies }
    end
  end
    
    
  def create
  end

end
