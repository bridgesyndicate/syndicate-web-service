class Ranked
  MAX_QUEUE_TIME = 60
  MAX_ELO_DELTA = 100

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
    attr_accessor :playerA, :playerB

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
    def find_match_by_oldest_players
      sorted_queue = queue.sort_by(&:queue_time)
      return [sorted_queue[0], sorted_queue[1]]
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
      if has_max_queue_time_players?
        players = find_match_by_oldest_players
        return new_match(queue.find_index(players[0]),
                         queue.find_index(players[1]))
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
      match = Match.new(queue[indexA], queue[indexB])
      queue.delete(match.playerA)
      queue.delete(match.playerB)
      return match
    end
    def has_max_queue_time_players?
      sorted_queue = queue.sort_by(&:queue_time)
      sorted_queue[0].queue_time + MAX_QUEUE_TIME <= Time.now.to_i
    end
  end
end
