sudo rm -rf /2tb/bak.chivi/_db/prod/*
sudo -u postgres pg_basebackup -D /2tb/bak.chivi/_db/prod/ -p 5433

sudo chmod a=r,u+w,a+X -R /2tb/bak.chivi/_db/prod/
rclone sync /2tb/bak.chivi/_db/prod/ oracle:chivi/pg_data

sudo rm -rf /2tb/app.chivi/_db/wals/*
rclone sync /2tb/app.chivi/_db/wals oracle:chivi/wal_log
