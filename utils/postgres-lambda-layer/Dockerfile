FROM public.ecr.aws/lambda/ruby:2.7

# Copy function code
RUN yum install -y unzip postgresql-libs
ENV GEM_HOME=${LAMBDA_TASK_ROOT}
CMD [ "lambda/via-stream/games.handler" ]
