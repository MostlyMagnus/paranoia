# == Schema Information
# Schema version: 20110402133936
#
# Table name: pawns
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  gamestate_id :integer
#  role         :integer
#  action_queue :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Pawn < ActiveRecord::Base
end
