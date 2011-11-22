class Snapshot < ActiveRecord::Base
  belongs_to :gamestate
  default_scope :order => 'turn, tick ASC'
end
