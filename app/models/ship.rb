# == Schema Information
# Schema version: 20110410191013
#
# Table name: ships
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :string(255)
#  image       :string(255)
#  layout      :string
#  created_at  :datetime
#  updated_at  :datetime
#

require 'StructDef'

class Ship < ActiveRecord::Base
  attr_accessor :rooms, :nodes
    
  def buildRooms
    # Instead of having this in initialize, moved to a different function
    # Constructor does not get called on commands like Ship.find_by_id
    @rooms  = Hash.new{ |h,k| h[k]=Hash.new(&h.default_proc) }
    @nodes  = Array.new
    
    tmp     = ""
        
    # 0,0;x00x;g1;n1$1,0;x0x0;c1;$2,0;x0x0;c1;$3,0;xx00;c1$0,1;0x0x;c1;$3,1;0x0x;c1;$0,2;0xrx;e;n0,n2$3,2;1xrx;b;n3$0,3;r0xx;e;n0,n2$1,3;x0x0;c1;$2,3;x0x0;c1;$3,3;rxx0;b;n3$
    splitShip = layout.split("$")
    
    splitShip.each do |room|
      splitRoom = room.split(";")
      
      # First we get the position
      pos = S_Position.new(Integer(splitRoom[0].split(",")[0]), Integer(splitRoom[0].split(",")[1]))
      
      # Then we get the access codes
      access = S_Access.new(String(splitRoom[1][0]), String(splitRoom[1][1]), String(splitRoom[1][2]), String(splitRoom[1][3]))
      
      # Parse the nodes into an array.    
      if !splitRoom[3].nil? then
        @nodes.push(Ship_Node.new(pos, splitRoom[3]))    
      end
            
      # Lets put it in our hash (-That's what SHE said!)        
      @rooms[pos.x][pos.y] = Room.new(pos, access, splitRoom[2])      
    end
  end
  
  def whereCanIMoveFromHere?(pawn)
    # Future code here should take into account access levels
    # @rooms[pawn.x][pawn.y].access[:north]

    #allowedMoves = S_Access.new(0, 0, 0, 0)
    allowedMoves = Hash[:north => 0, :south => 0, :east => 0, :west => 0]   
    if @rooms[pawn.x][pawn.y-1].kind_of? Room then
      #There's a room north
      unless @rooms[pawn.x][pawn.y].access[:north] == "x"
        allowedMoves[:north] = 1   
      end
    end
 
    if @rooms[pawn.x][pawn.y+1].kind_of? Room then
      #There's a room south
      unless @rooms[pawn.x][pawn.y].access[:south] == "x"
        allowedMoves[:south] = 1   
      end
    end
      
    if @rooms[pawn.x-1][pawn.y].kind_of? Room then
      #There's a room west
      unless @rooms[pawn.x][pawn.y].access[:west] == "x"
        allowedMoves[:west] = 1   
      end
    end
 
    if @rooms[pawn.x+1][pawn.y].kind_of? Room then
      #There's a room east
      unless @rooms[pawn.x][pawn.y].access[:east] == "x"
        allowedMoves[:east] = 1   
      end
    end
    
    # Return
    return allowedMoves
  end
  
  def AJAX_formatForResponse
    buildRooms
    
    toAjaxResponse = Hash.new
    
    toAjaxResponse[:success] = true
    toAjaxResponse[:name] = name
    toAjaxResponse[:width] = 16
    toAjaxResponse[:height] = 8
    
    toAjaxResponse[:map] = @rooms
    toAjaxResponse[:nodes]  = @nodes
    return toAjaxResponse
  end
end

class AccessStructDef
  NO_ACCESS 	= "x"
  SAME_ROOM 	= "r"
end

class Room
  def initialize(pos, access, room_type)
    @position   = pos
    @access     = access
    @room_type  = room_type
  end

  attr_accessor :position, :access, :room_type
  
end

class Ship_Node
  def initialize(pos, node_type)
    @position   = pos
    @node_type  = node_type
  end
  
  attr_accessor :position, :node_type
end
