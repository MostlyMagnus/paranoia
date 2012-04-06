class HeardLines < ActiveRecord::Base
	attr_accessible :line_id

  belongs_to :pawn_id, :class_name => "Pawn"
  belongs_to :line_id, :class_name => "Line"
end
