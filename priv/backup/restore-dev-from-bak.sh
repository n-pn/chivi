sudo pg_ctlcluster 14 main stop
sudo rsync -avAXEWSlHh --no-compress --delete /app/chivi.app/_pg/.bak/2023-05-07/ /app/chivi.dev/_pg/data/
sudo chown postgres:postgres -R /app/chivi.dev/_pg/data/
sudo chmod 700 -R /app/chivi.dev/_pg/data/
sudo pg_ctlcluster 14 main start
