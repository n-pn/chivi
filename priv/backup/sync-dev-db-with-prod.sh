sudo pg_ctlcluster 14 main stop
sudo rsync -avAXEWSlHh --no-compress /mnt/serve/chivi.app/_pg/data/ /mnt/serve/chivi.dev/_pg/data/
sudo chmod 700 -R /mnt/serve/chivi.dev/_pg/data/
sudo pg_ctlcluster 14 main start
