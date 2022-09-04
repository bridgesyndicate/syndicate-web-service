#!/usr/bin/env ruby

libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)
dotpath = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(dotpath) unless $LOAD_PATH.include?(dotpath)

require 'aws_credentials'
require 'lambda/auth/game/container_metadata/put'
require 'lambda/auth/game/post'
require 'lambda/auth/game/put'
require 'lambda/auth/register/by-kick-code/post'
require 'lambda/auth/user/by-minecraft-uuid/get'
require 'pry'

require 'lib/aws_credentials'
require 'lib/dynamo_client'
require 'lib/helpers'
require 'securerandom'
require 'lib/cloudwatch_client'

# $ddb_user_manager.add_elo
binding.pry;1
$ddb_user_manager.add_ban_and_unban_arrays
exit
