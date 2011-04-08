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
