class LogEntry < ActiveRecord::Base
  belongs_to :gamestate
  default_scope :order => 'turn ASC'
end


