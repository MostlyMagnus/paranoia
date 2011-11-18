class LogEntry < ActiveRecord::Base
    belongs_to :gamestate
    
    def initialize(turn, string)
      @turn = turn
      @string = string
    end
end

