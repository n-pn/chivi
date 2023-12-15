-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE OR UPDATE VIEW vicrits_view AS
SELECT
  t.id AS vc_id,
  t.viuser_id AS vu_id,
  t.nvinfo_id::int AS wn_id,
  t.vilist_id AS vl_id,
  t.stars AS stars,
  t.ohtml AS ohtml,
  t.btags AS btags,
  t._sort AS _sort,
  extract(epoch FROM t.created_at)::bigint AS ctime,
  extract(epoch FROM coalesce(t.changed_at, t.created_at))::bigint AS utime,
  t.like_count,
  t.repl_count,
  u.uname AS u_uname,
  u.privi AS u_privi,
  b.btitle_vi AS b_title,
  l.title AS l_title,
(l.id || '-' || l.tslug) AS l_uslug,
  l.book_count AS l_count
FROM
  vicrits AS t
  INNER JOIN viusers AS u ON u.id = t.viuser_id
  INNER JOIN wninfos AS b ON b.id = t.nvinfo_id
  INNER JOIN vilists AS l ON l.id = t.vilist_id
WHERE
  t.id > 0;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP VIEW vicrits_view;
