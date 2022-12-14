#! /bin/bash

function rsync-fast {
  rsync -aHAXxvi --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x ' $@
}

DIR=var/ysraw
SSH=nipin@ssh.chivi.app:/app/chivi

rsync-fast "$SSH/$DIR/infos" "$DIR"
rsync-fast "$SSH/$DIR/users" "$DIR"

rsync-fast "$SSH/$DIR/lists" "$DIR"
rsync-fast "$SSH/$DIR/lists-by-page" "$DIR"

rsync-fast "$SSH/$DIR/lists-by-book" "$DIR"
rsync-fast "$SSH/$DIR/lists-by-user" "$DIR"

rsync-fast "$SSH/$DIR/crits" "$DIR"
rsync-fast "$SSH/$DIR/crits-by-list" "$DIR"
# rsync-fast "$SSH/$DIR/crits-by-user" "$DIR"

rsync-fast "$SSH/$DIR/repls" "$DIR"
