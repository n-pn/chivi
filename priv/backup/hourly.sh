echo backup dict data
rclone sync /app/chivi.app/var/dicts/v1raw oracle:chivi/dicts/v1raw
rclone sync /app/chivi.app/var/dicts/v1log oracle:chivi/dicts/v1log

echo backup user logs
rclone sync /app/chivi.app/var/cvmtl/users oracle:chivi/users/mtl_err
rclone sync /app/chivi.app/var/users/qtlogs oracle:chivi/users/qtlogs

rclone sync /app/chivi.app/var/.keep/web_log oracle:chivi/web_log

echo backup yousuu data
rclone sync /app/chivi.app/var/ysraw oracle:chivi/ysraw
