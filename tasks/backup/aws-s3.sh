aws s3 sync --delete var/dicts/v1 s3://chivi-bak/dicts

aws s3 sync var/ysapp s3://chivi-bak/ysapp --exclude "*" --include "*.zip"

aws s3 sync --delete var/pg_data/weblogs s3://chivi-bak/weblogs
aws s3 sync --delete var/pg_data/cvusers s3://chivi-bak/cvusers
aws s3 sync --delete var/tlspecs/users s3://chivi-bak/tlspecs

aws s3 sync --delete ~/var/wal_log s3://chivi-bak/wal_log
aws s3 sync --delete ~/var/pg_data s3://chivi-bak/pg_data
