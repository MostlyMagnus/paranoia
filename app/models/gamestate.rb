# == Schema Information
# Schema version: 20110406102234
#
# Table name: gamestates
#
#  id              :integer         not null, primary key
#  ship_id         :integer
#  nodestatus      :string(255)
#  playerstatus    :string(255)
#  playerlocations :string(255)
#  timescale       :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class Gamestate < ActiveRecord::Base
end