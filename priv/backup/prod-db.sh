sudo rm -rf /2tb/chivi/_pg/prod/*
sudo -u postgres pg_basebackup -D /2tb/chivi/_pg/prod -p 5433

sudo chmod a=r,u+w,a+X -R /2tb/chivi/_pg/prod
rclone sync /2tb/chivi/_pg/prod oracle:chivi/pg_data

sudo rm -rf /2tb/chivi/_pg/wals/*
rclone sync /2tb/chivi/_pg/wals oracle:chivi/wal_log
