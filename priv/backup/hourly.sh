rclone sync var/dicts/v1raw oracle:chivi/dicts/v1raw
rclone sync var/dicts/v1log oracle:chivi/dicts/v1log

rclone sync var/cvmtl/users oracle:chivi/users/mtl_err

# rclone sync var/ysapp oracle:chivi/ysapp --include "*.{db,zip}"
# rclone sync var/ysraw oracle:chivi/ysraw

rclone sync var/.keep/web_log oracle:chivi/web_log
rclone sync var/.keep/wal_log oracle:chivi/wal_log
