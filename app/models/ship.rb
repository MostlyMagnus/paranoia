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
    @rooms  = Array.new
    tmp     = ""
        
    layout.each_char do |ch|  
      if      ch.eql?     "\["
        next
      elsif   ch.eql?     "\]"
        # Lets split the unparsed room by its tokenizers, the semicolon
        splitRoom = tmp.split(";")
        
        # First we get the position
        pos = S_Position.new(Integer(splitRoom[0].split(",")[0]), Integer(splitRoom[0].split(",")[1]))
 
        # Then we get the access codes
        access = S_Access.new(splitRoom[1][0], splitRoom[1][1], splitRoom[1][2], splitRoom[1][3])
        
        # Lets put it in our array
        @rooms.push(Room.new(pos, access, splitRoom[2], splitRoom[3]))
        
        # Now clean up
        tmp = ""
      else
        tmp << ch
      end
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