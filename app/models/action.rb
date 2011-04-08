# == Schema Information
# Schema version: 20110408110929
#
# Table name: actions
#
#  id           :integer         not null, primary key
#  pawn_id      :integer
#  queue_number :integer
#  type         :integer
#  params       :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Action < ActiveRecord::Base
  belongs_to :pawn
  
  default_scope :order => 'queue_number ASC'
end
