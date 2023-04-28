---
UPDATE
  yscrits
SET
  repl_count =(
    SELECT
      count(*)::int
    FROM
      ysrepls
    WHERE
      yscrit_id = yscrits.id)
WHERE
  repl_total > repl_count;

--
UPDATE
  yslists
SET
  book_count =(
    SELECT
      count(*)::int
    FROM
      yscrits
    WHERE
      yscrits.yslist_id = yslists.id)
WHERE
  book_total > 0;

---
UPDATE
  ysbooks
SET
  crit_count =(
    SELECT
      count(*)::int
    FROM
      yscrits
    WHERE
      ysbook_id = ysbooks.id)
WHERE
  crit_total > 0;

---
UPDATE
  rpnodes AS r
SET
  like_count =(
    SELECT
      count(*)::int
    FROM
      memoirs AS m
    WHERE
      m.target_id = r.id
      AND m.viuser_id <> r.viuser_id
      AND m.target_type = 11
      AND m.liked_at > 0);

UPDATE
  cvposts AS c
SET
  like_count =(
    SELECT
      count(*)::int
    FROM
      memoirs AS m
    WHERE
      m.target_id = c.id
      AND m.viuser_id <> c.viuser_id
      AND m.target_type = 12
      AND m.liked_at > 0);

---
UPDATE
  rproots AS h
SET
  repl_count =(
    SELECT
      count(*)
    FROM
      rpnodes AS r
    WHERE
      r.rproot_id = h.id);

---
UPDATE
  cvposts AS c
SET
  repl_count =(
    SELECT
      repl_count
    FROM
      rproots AS h
    WHERE
      h.kind = 1
      AND h.ukey = c.id::text);

---
UPDATE
  vicrits AS c
SET
  repl_count =(
    SELECT
      repl_count
    FROM
      rproots AS h
    WHERE
      h.kind = 22
      AND h.ukey = c.id::text);
