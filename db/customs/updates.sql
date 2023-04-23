UPDATE
  rpnodes
SET
  like_count =(
    SELECT
      count(*)::int
    FROM
      memoirs
    WHERE
      target_id = rpnodes.id
      AND target_type = 11
      AND liked_at > 0);

UPDATE
  cvposts
SET
  like_count =(
    SELECT
      count(*)::int
    FROM
      memoirs
    WHERE
      target_id = cvposts.id
      AND target_type = 12
      AND liked_at > 0);
