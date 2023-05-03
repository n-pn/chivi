INSERT INTO wninfo_init(id, yb_id, zintro, zcover, yvoters, yrating)
SELECT
  id,
  ysbook_id AS yb_id,
  zintro,
  scover AS zconver,
  zvoters AS yvoters,
  zrating AS yrating
FROM
  wninfos
ORDER BY
  id ASC
ON CONFLICT (id)
  DO UPDATE SET
    yb_id = excluded.yb_id,
    zintro = excluded.zintro,
    zcover = excluded.zcover,
    yvoters = excluded.yvoters,
    yrating = excluded.yrating;

UPDATE
  wninfo_init
SET
  orig_links = ARRAY ( SELECT DISTINCT
      link
    FROM
      wnlinks
    WHERE
      wnlinks.book_id = wninfo_init.id
      AND type = 1);

UPDATE
  wninfo_init
SET
  seed_links = ARRAY ( SELECT DISTINCT
      rlink
    FROM
      wnseeds
    WHERE
      wnseeds.wn_id = wninfo_init.id
      AND rlink <> '');
