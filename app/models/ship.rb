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

S_Position  = Struct.new(:x, :y)
S_Access    = Struct.new(:north, :south, :east, :west)

class Ship < ActiveRecord::Base
  attr_accessor :rooms

  def buildRooms
    # Instead of having this in initialize, moved to a different function
    # Constructor does not get called on commands like Ship.find_by_id
    @rooms  = Hash.new
    tmp     = ""
        
    # 0,0;x00x;g1;n1$1,0;x0x0;c1;$2,0;x0x0;c1;$3,0;xx00;c1$0,1;0x0x;c1;$3,1;0x0x;c1;$0,2;0xrx;e;n0,n2$3,2;1xrx;b;n3$0,3;r0xx;e;n0,n2$1,3;x0x0;c1;$2,3;x0x0;c1;$3,3;rxx0;b;n3$
    splitShip = layout.split("$")
    
    splitShip.each do |room|
      splitRoom = room.split(";")
      
      # First we get the position
      pos = S_Position.new(Integer(splitRoom[0].split(",")[0]), Integer(splitRoom[0].split(",")[1]))

      # Then we get the access codes
      
      access = S_Access.new(splitRoom[1][0], splitRoom[1][1], splitRoom[1][2], splitRoom[1][3])

      # Lets put it in our array        
      @rooms[pos.hash] = Room.new(pos, access, splitRoom[2], splitRoom[3])
    end
        
  end   
end

class AccessStructDef
  NO_ACCESS 	= "x"
  SAME_ROOM 	= "r"
end

class Room
  def initialize(pos, access, room_type, node_type)
    @position   = pos
    @access     = access
    @room_type  = room_type
    @node_type  = node_type #maybe the nodes should be in a different place?
  end

  attr_accessor :position, :access 
end