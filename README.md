Uses rvm.

See the unified local DDB thingy at https://github.com/kenberland/indybooks/blob/master/ddb-local/README.md

You need a local DDB server in docker:

```
docker run -d -p 8000:8000 amazon/dynamodb-local
POSTGRES_HOST=localhost SYNDICATE_ENV=development AWS_REGION=us-east-1 AWS_ACCESS_KEY_ID=foo AWS_SECRET_ACCESS_KEY=bar rake
```

You need a local rabbit mq in docker:
```
docker run -d --hostname my-rabbit --name some-rabbit -p 5672:5672 rabbitmq:3
```

You need a local postgres server in docker:

```
docker run -d -p5432:5432 -e POSTGRES_USER=AmazonPgUsername -e POSTGRES_PASSWORD=AmazonPgPassword -e POSTGRES_HOST_AUTH_METHOD=trust postgres:12.8
```

GUI: `npm install -g dynamodb-admin` then
```
SYNDICATE_ENV=development AWS_REGION=us-east-1 AWS_ACCESS_KEY_ID=foo AWS_SECRET_ACCESS_KEY=bar dynamodb-admin
```

### To develop:
```
SYNDICATE_ENV=development AWS_REGION=us-east-1 AWS_ACCESS_KEY_ID=foo AWS_SECRET_ACCESS_KEY=bar ruby server.rb
```

## to see all the tables
`SYNDICATE_ENV=development AWS_DEFAULT_REGION=us-east-1 AWS_ACCESS_KEY_ID=foo AWS_SECRET_ACCESS_KEY=bar aws dynamodb list-tables --endpoint http://0.0.0.0:8000`

## supports pry
```ruby
require 'pry'
...
binding.pry;1
```

### To run tests:

```
rspec -fd spec/
```
### To run one
```
rspec ./spec/controllers/foo_spec.rb:10

```

Local codebuild testing is a godsend:
```
docker build -t aws/codebuild/standard:5.0 .
docker pull amazon/aws-codebuild-local:latest --disable-content-trust=false
wget https://raw.githubusercontent.com/aws/aws-codebuild-docker-images/master/local_builds/codebuild_build.sh
chmod +x codebuild_build.sh
./codebuild_build.sh -i aws/codebuild/standard:5.0 -a ./artifacts -s ~/syndicate-web-service/
```


### To start the local server:
```
ruby server.rb
```

Then `curl http://localhost:4567/things`

### To declare bankruptcy:
```
rvm gemset delete $(cat .ruby-gemset )
pushdir ..
popdir
bundle
rspec -fd spec/
```


### TODO:

- Maybe there's a way to move the `Access-Control-Allow-Origin` header from the business logic to the config? See [this post](https://alexharv074.github.io/2019/03/31/introduction-to-sam-part-iii-adding-a-proxy-endpoint-and-cors-configuration.html), which contains this snip:

```yaml
  Api:
    Cors:
      AllowMethods: "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
      AllowHeaders: "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
      AllowOrigin: "'*'"
```


  # Our template builds with SAM which does not currently support Lambda
  # integration only lambda proxy. Cors is not supported in API Gateway for this
  # integ.
  # See https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-output-format
  # https://medium.com/carsales-dev/api-gateway-with-aws-sam-template-c05afdd9cafe

  # For errors see: https://aws.amazon.com/premiumsupport/knowledge-center/malformed-502-api-gateway/
  # https://indybooks-developer-pastes.s3.us-east-2.amazonaws.com/2020-08-01-10-46-20.png


```
SYNDICATE_ENV=development AWS_DEFAULT_REGION=us-east-1 AWS_ACCESS_KEY_ID=foo AWS_SECRET_ACCESS_KEY=bar aws dynamodb query --endpoint http://localhost:8000 --table-name syndicate_development_users --index-name discord-id-index --key-condition-expression "discord_id = :discord_id" --expression-attribute-values '{":discord_id":{"N":"528866998471211970"} }'
```

cats

aws cloudwatch put-metric-data --namespace syndicate_production --metric-data "MetricName=ContainerMetadataDelay,Timestamp=$(date -Iseconds),Value=20,Unit=Count"

aws cloudwatch get-metric-statistics --namespace syndicate_production --metric-name ContainerMetadataDelay  --start-time 2022-02-14T03:40:00Z --end-time 2022-02-14T04:40:00Z --period 300 --statistic Maximum

aws cloudwatch get-metric-statistics --namespace syndicate_production --metric-name ContainerMetadataDelay  --start-time 2022-02-14T03:55:00Z --end-time 2022-02-14T04:00:00Z --period 300 --statistic Average
