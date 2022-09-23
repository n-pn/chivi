SSH=nipin@ssh.chivi.app:srv/chivi
GC_INITIAL_HEAP_SIZE=3G

for var in "$@"
do
  echo push $var!

  if [[ $var == "svkit" ]]
  then
    cd web && pnpm i && pnpm run build
    rsync -azi --no-p build nipin@ssh.chivi.app:srv/chivi/web
    ssh nipin@ssh.chivi.app "sudo service chivi-web restart"

    cd ..
    continue
  fi

  shards build -s --release --production $var && rsync -aiz --no-p bin/$var $SSH/bin

  if [[ $var == "chivi" ]]
  then
    ssh nipin@ssh.chivi.app "sudo service chivi-srv restart"
  elif [[ $var == "ysweb-srv" ]]
  then
    ssh nipin@ssh.chivi.app "sudo service ysweb-srv restart"
  fi

done
