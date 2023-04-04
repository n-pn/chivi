shards build ysbook_crawl && sudo systemctl start --now crawl-ysbooks.timer
shards build yscrit_crawl_by_user && sudo systemctl start --now crawl-yscrits-by-user.timer
shards build yscrit_crawl_by_list && sudo systemctl start --now crawl-yscrits-by-list.timer
shards build yscrit_crawl_by_book && sudo systemctl start --now crawl-yscrits-by-book.timer
