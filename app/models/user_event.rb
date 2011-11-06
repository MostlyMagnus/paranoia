class UserEvent < ActiveRecord::Base
  belongs_to :gamestate
  has_many :event_inputs, :dependent => :destroy
end
