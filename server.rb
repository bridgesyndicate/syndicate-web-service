libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)
dotpath = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(dotpath) unless $LOAD_PATH.include?(dotpath)

require 'aws_credentials'
require 'lambda/auth/game/post'
require 'lambda/auth/game/container_metadata/put'
require 'sinatra'
require 'sinatra_shim/auth/game/post'
require 'sinatra_shim/auth/game/container_metadata/put'

helpers AuthGamePost
helpers AuthGameContainerMetadataPut

post '/auth/game' do
  event = {
    'body' =>  request.body.read
  }
  auth_game_post(event)
end

put '/auth/game/container_metadata' do
  event = {
    'body' =>  request.body.read
  }
  auth_game_container_metadata_put(event)
end
