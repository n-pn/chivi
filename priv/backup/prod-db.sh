echo delete old data

DIR=/2tb/app.chivi/_db/last
sudo rm -rf $DIR/*

echo do basebackup
sudo -u postgres pg_basebackup -D $DIR -p 5433

echo delete wal files
sudo rm -rf /2tb/app.chivi/_db/wals/*

echo upload database to cloud
sudo chmod a=r,u+w,a+X -R $DIR

rclone sync $DIR b2:cvbaks/pg_db
