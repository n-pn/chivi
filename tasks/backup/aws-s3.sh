rclone sync var/dicts/v1raw oracle:chivi/dicts/v1raw
rclone sync var/dicts/v1log oracle:chivi/dicts/v1log

rclone sync var/.keep/web_log oracle:chivi/users/web_log
rclone sync var/cvmtl/users oracle:chivi/users/mtl_err

rclone sync var/ysapp oracle:chivi/ysapp --include "*.{db,zip}"
# rclone sync var/ysraw oracle:chivi/ysraw

rclone sync ~/var/wal_log oracle:chivi/wal_log
rclone sync ~/var/pg_data oracle:chivi/pg_data
