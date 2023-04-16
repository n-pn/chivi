sudo pg_ctlcluster 14 main stop
sudo rsync -avAXEWSlHh --no-compress --info=progress2 /mnt/serve/chivi/_pg/prod/ /mnt/vault/asset/pg_main/
sudo chmod 700 -R /mnt/vault/asset/pg_main
sudo pg_ctlcluster 14 main start
