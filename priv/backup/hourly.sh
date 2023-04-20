echo backup dict data
rclone sync /app/chivi.app/var/mtdic/users oracle:chivi/v1dic

echo backup user logs
rclone sync /app/chivi.app/var/ulogs/daily oracle:chivi/ulogs/daily
rclone sync /app/chivi.app/var/ulogs/qtlog oracle:chivi/ulogs/qtlog
rclone sync /app/chivi.app/var/cvmtl/users oracle:chivi/ulogs/mterr

echo backup yousuu data
rclone sync /app/chivi.app/var/ysraw oracle:chivi/ysraw
