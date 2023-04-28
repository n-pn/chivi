sudo systemctl start --now crawl-ysbooks.timer
sudo systemctl start --now crawl-ysrepls.timer
sudo systemctl start --now crawl-ysusers-info.timer

sudo systemctl start --now crawl-yscrits-by-user.timer
sudo systemctl start --now crawl-yscrits-by-list.timer
sudo systemctl start --now crawl-yscrits-by-book.timer

# sudo systemctl start --now crawl-yslists-by-book.timer
