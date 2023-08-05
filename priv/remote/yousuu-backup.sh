#! /bin/bash

function rsync-fast {
  rsync -aHAXxviz --compress-choice=zstd --numeric-ids -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x ' $@
}

DIR=var/ysraw
SSH=nipin@ssh.chivi.app:/app/chivi

rsync-fast "$SSH/$DIR/books" "$DIR"
# rsync-fast "$SSH/$DIR/users" "$DIR"
rsync-fast "$SSH/$DIR/crits-by-user" "$DIR"
# rsync-fast "$SSH/$DIR/crits-by-list" "$DIR"
# rsync-fast "$SSH/$DIR/crits-by-book" "$DIR"
# rsync-fast "$SSH/$DIR/repls" "$DIR"
# rsync-fast "$SSH/$DIR/lists-by-book" "$DIR"
# rsync-fast "$SSH/$DIR/lists-by-user" "$DIR"

# rsync-fast "$SSH/var/ysapp/books.db" var/ysapp
# rsync-fast "$SSH/var/ysapp/users.db" var/ysapp

# rsync-fast "$SSH/var/ysapp/crits.tmp" var/ysapp
# rsync-fast "$SSH/var/ysapp/repls.tmp" var/ysapp

# rsync-fast "$SSH/var/_conf/proxy/.works" var/_conf/proxy

# rsync-fast "$SSH/$DIR/users" "$DIR"

# rsync-fast "$SSH/$DIR/lists" "$DIR"
# rsync-fast "$SSH/$DIR/lists-by-page" "$DIR"

# rsync-fast "$SSH/$DIR/lists-by-book" "$DIR"
# rsync-fast "$SSH/$DIR/lists-by-user" "$DIR"

# rsync-fast "$SSH/$DIR/crits" "$DIR"
# rsync-fast "$SSH/$DIR/crits-by-list" "$DIR"
# # rsync-fast "$SSH/$DIR/crits-by-user" "$DIR"

# rsync-fast "$SSH/$DIR/repls" "$DIR"
