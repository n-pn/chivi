echo backup dict data
rclone sync /www/chivi/xyz/mtdic/users oracle:chivi/v1dic

echo backup db write ahead logs
rclone sync /www/chivi/app/_pg/wals oracle:chivi/wal_log

echo backup user logs
rclone sync /www/chivi/xyz/ulogs/daily oracle:chivi/ulogs/daily
rclone sync /www/chivi/xyz/ulogs/qtlog oracle:chivi/ulogs/qtlog
rclone sync /www/chivi/xyz/cvmtl/users oracle:chivi/ulogs/mterr

echo backup yousuu data
rclone sync /www/chivi/xyz/ysraw oracle:chivi/ysraw
