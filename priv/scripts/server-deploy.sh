SSH=nipin@ssh.chivi.app:srv/chivi

if [[ $1 == "all" || $* == "chivi" ]]
then
  echo push server!
  # shards build -s --release bcover_cli && rsync -aiz --no-p bin/bcover_cli $SSH/bin
  # shards build -s --release text_split && rsync -aiz --no-p bin/text_split $SSH/bin

  # shards build -s --release mtlv2-srv && rsync -aiz --no-p bin/mtlv2-srv $SSH/bin
  # ssh nipin@ssh.chivi.app "sudo service mtlv2-srv restart"

  shards build -s --release chivi && rsync -aiz --no-p bin/chivi $SSH/bin
  ssh nipin@ssh.chivi.app "sudo service chivi-srv restart"
fi

if [[ $1 == "all" || $* == "ysweb" ]]
then
  echo push ysweb!

  shards build -s --release ysweb-srv && rsync -aiz --no-p bin/ysweb-srv $SSH/bin
  ssh nipin@ssh.chivi.app "sudo service ysweb-srv restart"
fi

if [[ $1 == "all" || $* == "svkit" ]]
then
  echo push webapp!
  cd web
  yarn build
  rsync -aiz --no-p build $SSH/web
fi


if [[ $1 == "all" || $* == "ysbook" ]]
then
  echo push ysbook seed!

  shards build -s --release ysbook_seed
  rsync -aiz --no-p bin/ysbook_seed $SSH/bin
  rsync -azi --no-p "var/ysinfos/ysbooks" "$SSH/var/ysinfos"
fi

if [[ $1 == "all" || $* == "ysrepl" ]]
then
  echo push ysrepl seed!

  crystal build -s --release tasks/pgdata/ysrepl_seed.cr -o bin/ysrepl_seed

  rsync -aiz --no-p bin/ysrepl_seed $SSH/bin
  rsync -azi --no-p "var/ysinfos/ysrepls" "$SSH/var/ysinfo"
fi

if [[ $1 == "all" || $* == "zhinfo" ]]
then
  echo push zhinfo seed!

  shards build -s --release zhinfo_seed
  rsync -aiz --no-p bin/zhinfo_seed $SSH/bin
  rsync -azi --no-p "var/zhinfos" "$SSH/var"
fi

if [[ $1 == "all" || $* == "fixes" ]]
then
  echo push fixes!
  shards build -s --release fix_genres && rsync -aiz --no-p bin/fix_genres $SSH/bin
  shards build -s --release fix_intros && rsync -aiz --no-p bin/fix_intros $SSH/bin
fi

if [[ $1 == "all" || $* == "extra" ]]
then
  echo push extra!
  shards build -s --release ysbook_seed && rsync -aiz --no-p bin/ysbook_seed $SSH/bin
  shards build -s --release zhinfo_seed && rsync -aiz --no-p bin/zhinfo_seed $SSH/bin
fi
