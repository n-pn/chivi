sudo pg_ctlcluster 14 main stop
sudo rsync -avAXEWSlHh --no-compress --delete /www/chivi/app/_pg/.bak/2023-04-28/ /www/chivi/dev/_pg/data/
sudo chown postgres:postgres -R /www/chivi/dev/_pg/data/
sudo chmod 700 -R /www/chivi/dev/_pg/data/
sudo pg_ctlcluster 14 main start
