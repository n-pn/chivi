FROM amberframework/amber:0.35.0

WORKDIR /app

COPY shard.* /app/
RUN shards install

COPY . /app

RUN rm -rf /app/node_modules

CMD amber watch
