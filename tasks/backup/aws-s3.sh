aws s3 sync --delete var/dicts/v1 s3://chivi-bak/dicts/v1dic
aws s3 sync --delete var/dicts/ulogs s3://chivi-bak/dicts/ulogs
aws s3 sync --delete var/dicts s3://chivi-bak/dicts --exclude "*" --include "*.dic"

aws s3 sync --delete var/.keep/web_log s3://chivi-bak/web_log
aws s3 sync --delete var/mt_v2/users s3://chivi-bak/mtl_err

aws s3 sync var/ysapp s3://chivi-bak/ysapp --exclude "*" --include "*.zip" --include "*.db"

aws s3 sync --delete ~/var/wal_log s3://chivi-bak/wal_log
aws s3 sync --delete ~/var/pg_data s3://chivi-bak/pg_data
