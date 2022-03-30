SSH=nipin@ssh.chivi.app:srv/chivi

if [[ $1 == "all" || $1 == "srv" ]]
then
  echo push server!
  rsync -aiz --no-p config $SSH/srv
  rsync -aiz --no-p db/migrations $SSH/srv/db
  rsync -aiz --no-p db/seed_tasks $SSH/srv/db
  rsync -aiz --no-p db/seeds.cr $SSH/srv/db

  shards build --release chivi && rsync -aiz --no-p bin/chivi $SSH/srv
fi

if [[ $1 == "all" || $1 == "web" ]]
then
  echo push webapp!
  cd web && yarn build && rsync -aiz --no-p build/ $SSH/web/
fi
