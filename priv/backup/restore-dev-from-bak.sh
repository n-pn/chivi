sudo pg_ctlcluster 14 main stop
sudo rsync -avAXEWSlHh --no-compress --delete /2tb/app.chivi/_pg/.bak/2023-05-07/ /2tb/dev.chivi/_pg/data/
sudo chown postgres:postgres -R /2tb/dev.chivi/_pg/data/
sudo chmod 700 -R /2tb/dev.chivi/_pg/data/
sudo pg_ctlcluster 14 main start
