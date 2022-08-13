require 'pg'
require 'singleton'

class PostgresClient
  include Singleton
  attr_accessor :conn, :prepared

  def hostname
    ENV['POSTGRES_HOST'].nil? ? 'localhost' : ENV['POSTGRES_HOST']
  end

  def conn_string
    "postgres://AmazonPgUsername:AmazonPgPassword@#{hostname}/postgres"
  end

  def test_double
    Double.new
  end

  def get_conn
    SYNDICATE_ENV == 'test' ? test_double : @conn = PG::Connection.open(conn_string)
  end

  def initialize
    @conn = get_conn
    @prepared = false
  end

  def prepare
    unless prepared
      conn.prepare('update_winner', 'UPDATE syndicate_leader_board ' +
                                    'set elo=$1, wins=wins+1 where discord_id=$2 AND season=$3')
      conn.prepare('update_loser', 'UPDATE syndicate_leader_board ' +
                                   'set elo=$1, losses=losses+1 where discord_id=$2 AND season=$3')
      conn.prepare('update_tie', 'UPDATE syndicate_leader_board ' +
                                   'set elo=$1, ties=ties+1 where discord_id=$2 AND season=$3')
      conn.prepare('new_winner', 'INSERT INTO syndicate_leader_board ' +
                                 '(discord_id, minecraft_uuid, elo, wins, season) '+
                                 'values ($1, $2, $3, 1, $4)')
      conn.prepare('new_loser', 'INSERT INTO syndicate_leader_board ' +
                                '(discord_id, minecraft_uuid, elo, losses, season) '+
                                'values ($1, $2, $3, 1, $4)')
      conn.prepare('new_tie', 'INSERT INTO syndicate_leader_board ' +
                                '(discord_id, minecraft_uuid, elo, ties, season) '+
                                'values ($1, $2, $3, 1, $4)')
      @prepared = true
    end
  end

  def update_terminated_row(pk)
    sql_cmd = <<HERE
UPDATE syndicate_scale_in_candidates
  SET terminated = true
  WHERE id = $1
HERE
    conn.exec(sql_cmd, [pk])
  end

  def lock_scale_in_candidates
    sql_cmd = <<HERE
UPDATE syndicate_scale_in_candidates
  SET processed = true
  WHERE processed = false
  AND created_at > now() - interval '1 hour'
  RETURNING *;
HERE
    conn.exec(sql_cmd)
  end

  def get_scale_in_candidates
    sql_cmd = <<HERE
SELECT *
  FROM syndicate_scale_in_candidates
  WHERE processed = false
  AND created_at > now() - interval '1 hour';
HERE
    conn.exec(sql_cmd)
  end

  def insert_candidate(task_arn)
    sql_cmd = <<HERE
INSERT into syndicate_scale_in_candidates
  VALUES (
    nextval('syndicate_scale_in_candidates_id_seq'),
    now(),
    $1
  );
HERE
    conn.exec(sql_cmd, [task_arn])
  end

  class Double
    def exec_prepared(*args)
      Tuples.new(1)
    end
    def prepare(*args)
    end
  end

  class Tuples
    def initialize rows
      @rows = rows
    end
    def cmd_tuples
      @rows
    end
  end
end

$pg_conn = PostgresClient.instance.conn
