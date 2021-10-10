require 'pry'
require 'bundler'

Bundler.require
libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)
dotpath = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(dotpath) unless $LOAD_PATH.include?(dotpath)

require 'dynamodb_game_manager'
require 'dynamodb_user_manager'
require 'dynamodb_kick_code_manager'
require 'helpers'
require 'aws_credentials'
require 'postgres_client'

task default: %w/create_tables/

task :create_tables do
  %w/game user kick_code/.each do |table|
    Rake::Task["create_#{table}_table"].execute
  end
end

task :create_lb_table do
  CMD = <<HERE
CREATE TABLE syndicate_leader_board (discord_id bigint primary key not null, minecraft_uuid varchar(36) not null, elo integer not null, wins integer not null default 0, losses integer not null default 0, ties integer not null default 0);
CREATE UNIQUE INDEX discord_id_unique_idx on syndicate_leader_board(discord_id);
CREATE UNIQUE INDEX minecraft_uuid_unique_idx on syndicate_leader_board(minecraft_uuid);
CREATE INDEX wins_idx on syndicate_leader_board(wins);
CREATE INDEX losses_idx on syndicate_leader_board(losses);
CREATE INDEX ties_idx on syndicate_leader_board(ties);
HERE
  puts $pg_conn.exec(CMD)
end

task :create_game_table do
  manager = DynamodbGameManager.new()
  manager.create_table
end

task :create_user_table do
  manager = DynamodbUserManager.new()
  manager.create_table
end

task :create_kick_code_table do
  manager = DynamodbKickCodeManager.new()
  manager.create_table
end

task :test_get_ip do
  # aws ecs describe-tasks --tasks arn:aws:ecs:us-west-2:595508394202:task/default/0e0a0ac6d3274d999589c70836da031e | jq '.tasks[]' | grep -i eni
  # aws ec2 describe-network-interfaces --network-interface-ids  eni-094b22b7e425e613f | jq '.NetworkInterfaces[0].PrivateIpAddresses[0].Association.PublicIp'

  task_arn ='arn:aws:ecs:us-west-2:595508394202:task/default/0e0a0ac6d3274d999589c70836da031e'
  client = Aws::ECS::Client.new(
                                region: AwsCredentials.instance.region,
                                credentials: AwsCredentials.instance.credentials,
                                )
  resp = client.describe_tasks({ tasks: [task_arn] })
  eni = resp.to_h[:tasks][0][:attachments][0][:details].select{|e| e[:name] == 'networkInterfaceId'}[0][:value]

  client = Aws::EC2::Client.new(
                                region: AwsCredentials.instance.region,
                                credentials: AwsCredentials.instance.credentials,
                                )
  resp = client.describe_network_interfaces({ network_interface_ids: [ eni ] })
  puts resp.to_h[:network_interfaces][0][:association][:public_ip]
end

task :test_post do
  # see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Sigv4/Signer.html
  # see https://docs.aws.amazon.com/apigateway/api-reference/signing-requests/
  body = File.read('./spec/mocks/game/valid-post.json')
  BASE_URL = 'https://knopfnsxoh.execute-api.us-west-2.amazonaws.com/Prod/auth/game'
  signer = Aws::Sigv4::Signer.new(
                                  service: 'execute-api',
                                  region: 'us-west-2',
                                  access_key_id: 'AKIAYVJYQ7DNBK4E3CVM',
                                  secret_access_key: '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'
                                  )

  signature = signer.sign_request(
                                  http_method: 'POST',
                                  url: BASE_URL,
                                  body: body
                                  )
  uri = URI.parse(BASE_URL)
  https = Net::HTTP.new(uri.host,uri.port)
  https.use_ssl = true
  req = Net::HTTP::Post.new(uri.path)
  header_list = %w/host x-amz-date x-amz-security-token x-amz-content-sha256 authorization/
  header_list.each do |header|
    req[header] = signature.headers[header]
  end
  req.body = File.read('./spec/mocks/game/valid-post.json')
  res = https.request(req)
  puts "Response #{res.code} #{res.message}: #{res.body}"
end
