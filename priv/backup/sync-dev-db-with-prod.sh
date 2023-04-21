sudo pg_ctlcluster 14 main stop
sudo rsync -avAXEWSlHh --no-compress /www/chivi/app/_pg/data/ /www/chivi/dev/_pg/data/
sudo chmod 700 -R /www/chivi/dev/_pg/data/
sudo pg_ctlcluster 14 main start
