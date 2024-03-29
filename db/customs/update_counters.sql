---
UPDATE
  yscrits
SET
  repl_count =(
    SELECT
      coalesce(count(*), 0)::int
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
      coalesce(count(*), 0)::int
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
      coalesce(count(*), 0)::int
    FROM
      yscrits
    WHERE
      ysbook_id = ysbooks.id)
WHERE
  crit_total > 0;

---
UPDATE
  gdrepls AS r
SET
  like_count =(
    SELECT
      coalesce(count(*), 0)::int
    FROM
      memoirs AS m
    WHERE
      m.target_id = r.id
      AND m.viuser_id <> r.viuser_id
      AND m.target_type = 11
      AND m.liked_at > 0);

UPDATE
  dtopics AS c
SET
  like_count =(
    SELECT
      coalesce(count(*), 0)::int
    FROM
      memoirs AS m
    WHERE
      m.target_id = c.id
      AND m.viuser_id <> c.viuser_id
      AND m.target_type = 12
      AND m.liked_at > 0);

---
UPDATE
  gdroots AS h
SET
  repl_count =(
    SELECT
      coalesce(count(*), 0)::int
    FROM
      gdrepls AS r
    WHERE
      r.gdroot_id = h.id);

---
UPDATE
  dtopics AS c
SET
  repl_count =(
    SELECT
      repl_count
    FROM
      gdroots AS h
    WHERE
      h.kind = 1
      AND h.ukey = c.id::text);

---
UPDATE
  vicrits AS c
SET
  repl_count = coalesce((
    SELECT
      repl_count
    FROM gdroots AS h
    WHERE
      h.kind = 22
      AND h.ukey = c.id::text), 0);
