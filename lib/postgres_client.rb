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

  def initialize
    @conn = PG::Connection.open(conn_string)
    @prepared = false
  end

  def prepare
    unless prepared
      conn.prepare('update_winner', 'UPDATE syndicate_leader_board ' +
                                    'set elo=$1, wins=wins+1 where discord_id=$2')
      conn.prepare('update_loser', 'UPDATE syndicate_leader_board ' +
                                   'set elo=$1, losses=losses+1 where discord_id=$2')
      conn.prepare('new_winner', 'INSERT INTO syndicate_leader_board ' +
                                 '(discord_id, minecraft_uuid, elo, wins) '+
                                 'values ($1, $2, $3, 1)')
      conn.prepare('new_loser', 'INSERT INTO syndicate_leader_board ' +
                                '(discord_id, minecraft_uuid, elo, losses) '+
                                'values ($1, $2, $3, 1)')
      @prepared = true
    end
  end
end

$pg_conn = PostgresClient.instance.conn
