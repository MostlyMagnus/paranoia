class Snapshot < ActiveRecord::Base
  belongs_to :gamestate
  serialize :actions, Array
end
