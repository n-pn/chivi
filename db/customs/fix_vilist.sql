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
      nvinfos
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
        nvinfos.weight DESC
      LIMIT 3)
WHERE
  book_count > 0;
