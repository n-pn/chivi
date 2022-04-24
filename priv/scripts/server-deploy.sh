SSH=nipin@ssh.chivi.app:srv/chivi

if [[ $1 == "all" || $1 == "chivi-srv" ]]
then
  echo push server!

  shards build -s --release chivi && rsync -aiz --no-p bin/chivi $SSH/bin
  ssh nipin@ssh.chivi.app "sudo service chivi-srv restart"
fi

if [[ $1 == "all" || $1 == "web" ]]
then
  echo push webapp!
  cd web
  yarn build
  rsync -aiz --no-p build $SSH/web
fi


if [[ $1 == "all" || $1 == "ysbook" ]]
then
  echo push ysbook seed!

  shards build -s --release ysbook_seed
  rsync -aiz --no-p bin/ysbook_seed $SSH/bin
  rsync -azi --no-p "var/ysinfos/ysbooks" "$SSH/var/ysinfos"
fi

if [[ $1 == "all" || $1 == "ysrepl" ]]
then
  echo push ysrepl seed!

  crystal build -s --release tasks/pgdata/ysrepl_seed.cr -o bin/ysrepl_seed

  rsync -aiz --no-p bin/ysrepl_seed $SSH/bin
  rsync -azi --no-p "var/ysinfos/ysrepls" "$SSH/var/ysinfo"
fi

if [[ $1 == "all" || $1 == "zhinfo" ]]
then
  echo push zhinfo seed!

  shards build -s --release zhinfo_seed
  rsync -aiz --no-p bin/zhinfo_seed $SSH/bin
  rsync -azi --no-p "var/zhinfos" "$SSH/var"
fi

if [[ $1 == "all" || $1 == "fixes" ]]
then
  echo push fixes binaries!
  shards build -s --release fix_genres && rsync -aiz --no-p bin/fix_genres $SSH/bin
  shards build -s --release fix_intros && rsync -aiz --no-p bin/fix_intros $SSH/bin
fi

if [[ $1 == "all" || $1 == "binary" ]]
then
  echo push binaries!
  shards build -s --release ysbook_seed && rsync -aiz --no-p bin/ysbook_seed $SSH/bin
  shards build -s --release zhinfo_seed && rsync -aiz --no-p bin/zhinfo_seed $SSH/bin
fi
