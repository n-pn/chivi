shards build --release server && sudo service chivi-server restart
cd web && yarn build && sudo service chivi-client restart
