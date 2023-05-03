UPDATE
  vilists
SET
  book_count =(
    SELECT
      count(*)
    FROM
      vicrits
    WHERE
      vicrits.vilist_id = vilists.id);

UPDATE
  vilists
SET
  covers = ARRAY (
    SELECT
      bcover
    FROM
      wninfos
    WHERE
      bcover <> ''
      AND id IN (
        SELECT
          nvinfo_id
        FROM
          vicrits
        WHERE
          vilist_id = vilists.id)
      ORDER BY
        wninfos.weight DESC
      LIMIT 3)
WHERE
  book_count > 0;
