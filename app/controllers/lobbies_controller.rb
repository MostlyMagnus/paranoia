class LobbiesController < ApplicationController

  def index
    @lobbies = Lobby.all
  end

  def create
  end

end
