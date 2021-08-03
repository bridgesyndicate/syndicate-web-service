libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)
dotpath = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(dotpath) unless $LOAD_PATH.include?(dotpath)

require 'pry'

require 'lambda/auth/game/post'
require 'sinatra'
require 'sinatra_shim/auth/game/post'

helpers AuthGamePost

post '/auth/game' do
  event = {
    'body' =>  request.body.read
  }
  auth_game_post(event)
end
