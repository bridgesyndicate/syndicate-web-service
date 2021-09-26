MAX_QUEUE_TIME = 60
MAX_ELO_DELTA = 100

class Ranked
  class Player
    attr_accessor :discord_id, :discord_username, :queue_time, :elo
    def initialize params = {}
      params.each { |key, value| send "#{key}=", value }
      @elo = 1000 if elo.nil?
    end
    def ==(other)
      !(instance_variables.map {|v|
          other.instance_variable_get(v) == instance_variable_get(v)
        }.include?(false))
    end
  end

  class Match
    def self.within_elo(playerA, playerB)
      (playerA.elo-playerB.elo).abs <= MAX_ELO_DELTA
    end
    def initialize(playerA, playerB)
      @playerA = playerA
      @playerB = playerB
    end
  end

  class Queue
    attr_accessor :queue, :process_counter
    def initialize
      @queue = []
      @process_counter = 0
    end
    def queue_player queued_player
      queue.push queued_player
    end
    def find_best_match_by_elo
      sorted_queue = queue.sort_by(&:elo)
      best_delta = nil
      best_match = nil
      (sorted_queue.size-1).times do |idx|
        elo_delta = sorted_queue[idx+1].elo - sorted_queue[idx].elo
        if best_delta.nil? or elo_delta < best_delta
          best_match = idx
          best_delta = elo_delta
        end
      end
      return [sorted_queue[best_match], sorted_queue[best_match+1]]
    end
    def process_queue
      @process_counter += 1
      if queue.size < 2
        return nil
      end
      if queue.size == 2
        if within_elo(0, 1)
          return new_match(0,1)
        else
          return nil
        end
      end
      players = find_best_match_by_elo
      return new_match(queue.find_index(players[0]),
                       queue.find_index(players[1]))
    end
    def within_elo(indexA, indexB)
      Match.within_elo(queue[indexA], queue[indexB])
    end
    def new_match(indexA, indexB)
      ret_val = Match.new(queue[indexA], queue[indexB])
      queue.delete(queue[indexA])
      queue.delete(queue[indexB])
      return ret_val
    end
  end
end
