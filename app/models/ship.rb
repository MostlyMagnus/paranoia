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

require 'structdef'

class Ship < ActiveRecord::Base
  attr_accessor :rooms, :nodes
       
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


