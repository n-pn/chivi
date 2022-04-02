SSH=nipin@ssh.chivi.app:srv/chivi

if [[ $1 == "all" || $1 == "srv" ]]
then
  echo push server!
  shards build --release chivi && rsync -aiz --no-p bin/chivi $SSH/bin
  shards build --release zhwenpg_seed && rsync -aiz --no-p bin/zhwenpg_seed $SSH/bin
  shards build --release yscrit_seed && rsync -aiz --no-p bin/yscrit_seed $SSH/bin
  shards build --release ysbook_seed && rsync -aiz --no-p bin/ysbook_seed $SSH/bin
  shards build --release zxcsme_seed && rsync -aiz --no-p bin/zxcsme_seed $SSH/bin
  shards build --release remote_seed && rsync -aiz --no-p bin/remote_seed $SSH/bin
fi

if [[ $1 == "all" || $1 == "web" ]]
then
  echo push webapp!
  cd web
  yarn build
  rsync -aiz --no-p build $SSH/web
fi
