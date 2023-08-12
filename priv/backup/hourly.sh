echo backup dict data
rclone sync /2tb/app.chivi/mtapp/v1dic oracle:chivi/v1dic

echo backup db write ahead logs
rclone sync /2tb/app.chivi/_db/wals oracle:chivi/wal_log

echo backup user logs
rclone sync /2tb/app.chivi/ulogs/daily oracle:chivi/daily_log
rclone sync /2tb/app.chivi/ulogs/qtlog oracle:chivi/cvmtl_log
rclone sync /2tb/app.chivi/cvmtl/users oracle:chivi/cvmtl_err

echo backup crawl data
# rclone sync /2tb/app.chivi/.keep/yousuu oracle:chivi/yousuu
# rclone sync /2tb/app.chivi/.keep/tuishu oracle:chivi/tuishu
