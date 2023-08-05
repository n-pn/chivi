echo backup dict data
rclone sync /app/chivi.app/mtapp/v1dic oracle:chivi/v1dic

echo backup db write ahead logs
rclone sync /app/chivi.app/_pg/wals oracle:chivi/wal_log

echo backup user logs
rclone sync /app/chivi.app/ulogs/daily oracle:chivi/daily_log
rclone sync /app/chivi.app/ulogs/qtlog oracle:chivi/cvmtl_log
rclone sync /app/chivi.app/cvmtl/users oracle:chivi/cvmtl_err

echo backup crawl data
# rclone sync /app/chivi.app/.keep/yousuu oracle:chivi/yousuu
# rclone sync /app/chivi.app/.keep/tuishu oracle:chivi/tuishu
