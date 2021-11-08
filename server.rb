libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)
dotpath = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(dotpath) unless $LOAD_PATH.include?(dotpath)

require 'aws_credentials'
require 'lambda/auth/game/accept/post'
require 'lambda/auth/game/container_metadata/put'
require 'lambda/auth/game/post'
require 'lambda/auth/game/put'
require 'lambda/auth/register/by-kick-code/post'
require 'lambda/auth/user/by-discord-id/get'
require 'lambda/auth/user/by-minecraft-uuid/get'
require 'lambda/auth/warp/post'
require 'pry'
require 'sinatra'
require 'sinatra_shim/auth/game/accept/post'
require 'sinatra_shim/auth/game/container_metadata/put'
require 'sinatra_shim/auth/game/post'
require 'sinatra_shim/auth/game/put'
require 'sinatra_shim/auth/register/by-kick-code/post'
require 'sinatra_shim/auth/user/by-discord-id/get'
require 'sinatra_shim/auth/user/by-minecraft-uuid/get'
require 'sinatra_shim/auth/warp/post'

helpers AuthGameAcceptPost
helpers AuthGameContainerMetadataPut
helpers AuthGamePost
helpers AuthGamePut
helpers AuthRegisterByKickCodePost
helpers AuthUserByDiscordIdGet
helpers AuthUserByMinecraftUuidGet
helpers AuthWarp

set :bind, '0.0.0.0'

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

put '/auth/game' do
  event = {
    'body' =>  request.body.read
  }
  auth_game_put(event)
end

get '/auth/user/by-minecraft-uuid/*' do
  event = {
    'pathParameters' => {
      'proxy' =>  params[:splat][0]
    }
  }
  auth_user_by_minecraft_uuid_get(event)
end

get '/auth/user/by-discord-id/*' do
  event = {
    'pathParameters' => {
      'proxy' =>  params[:splat][0]
    }
  }
  auth_user_by_discord_id_get(event)
end

post '/auth/register/by-kick-code/*' do
  event = {
    'pathParameters' => {
      'proxy' =>  "#{params[:splat][0]}/discord-id/#{params[:splat][1]}"
    }
  }
  auth_register_by_kick_code_post(event)
end

post '/auth/game/accept/*' do
  event = {
    'pathParameters' => {
      'proxy' =>  "#{params[:splat][0]}/discord-id/#{params[:splat][1]}"
    }
  }
  auth_game_accept_post(event)
end

post '/auth/warp/by-discord-id/*' do
  event = {
    'pathParameters' => {
      'proxy' =>  "#{params[:splat][0]}"
    }
  }
  auth_warp_post(event)
end
