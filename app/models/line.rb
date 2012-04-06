class Line < ActiveRecord::Base
	belongs_to :pawn

	def scramble(level)
		return "This text has gone through the scrambler function."
	end
end
