# == Schema Information
# Schema version: 20110408041711
#
# Table name: ships
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :string(255)
#  image       :string(255)
#  layout      :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Ship < ActiveRecord::Base
end

#for n in rooms
#      puts n
#end

class Level
	attr_accessor :lvl_str, :rooms

	def initialize(str)
		@lvl_str = str
		@rooms = Array.new
		tmp = ""
		str.each_char do |ch|
			if ch.eql? "\["
				next
			elsif ch.eql? "\]"
				@rooms.push(tmp)
				tmp = ""
			else
				tmp << ch
			end
		end
	end

	def to_s
		@lvl_str
	end
end