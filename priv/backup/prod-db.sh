echo delete old data
sudo rm -rf /2tb/bak.chivi/_db/prod/*

echo do basebackup
sudo -u postgres pg_basebackup -D /2tb/bak.chivi/_db/prod/ -p 5433

echo delete wal files
sudo rm -rf /2tb/app.chivi/_db/wals/*

echo upload database to oracle
sudo chmod a=r,u+w,a+X -R /2tb/bak.chivi/_db/prod
rclone sync /2tb/bak.chivi/_db/prod b2:cvbaks/pg_db
