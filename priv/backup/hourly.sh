echo backup dict data
rclone sync var/dicts/v1raw oracle:chivi/dicts/v1raw
rclone sync var/dicts/v1log oracle:chivi/dicts/v1log

echo backup user logs
rclone sync var/cvmtl/users oracle:chivi/users/mtl_err
rclone sync var/users/qtlogs oracle:chivi/users/qtlogs

rclone sync var/.keep/web_log oracle:chivi/web_log

echo backup yousuu data
rclone sync var/ysraw oracle:chivi/ysraw
