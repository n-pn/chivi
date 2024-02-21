ALTER TABLE tsrepos
  ADD COLUMN IF NOT EXISTS id int GENERATED ALWAYS AS IDENTITY;

-- CREATE UNIQUE INDEX tsrepos_id_idx ON tsrepos(id);
ALTER TABLE rdmemos
  ADD COLUMN IF NOT EXISTS rd_id int NOT NULL DEFAULT 0;

DELETE FROM rdmemos r1
WHERE sname LIKE 'up@%'
  AND sn_id IN (
    SELECT
      sn_id
    FROM
      rdmemos r2
    WHERE
      r2.sname = replace(r1.sname, 'up@', '@'));

UPDATE
  rdmemos
SET
  sname = replace(sname, 'up@', '@')
WHERE
  sname LIKE 'up@%';

--
DELETE FROM rdmemos r1
WHERE sname LIKE 'rm!%'
  AND sn_id IN (
    SELECT
      sn_id
    FROM
      rdmemos r2
    WHERE
      r2.sname = replace(r1.sname, 'rm!', '!'));

UPDATE
  rdmemos
SET
  sname = replace(sname, 'rm!', '!')
WHERE
  sname LIKE 'rm!%';

--
DELETE FROM rdmemos r1
WHERE sname LIKE 'wn~%'
  AND sn_id IN (
    SELECT
      sn_id
    FROM
      rdmemos r2
    WHERE
      r2.sname = replace(r1.sname, 'wn~', '~'));

UPDATE
  rdmemos
SET
  sname = replace(sname, 'wn~', '~')
WHERE
  sname LIKE 'wn~%';

--
UPDATE
  rdmemos r
SET
  rd_id = coalesce((
    SELECT
      id
    FROM tsrepos t
    WHERE
      t.sname = r.sname
      AND t.sn_id = r.sn_id LIMIT 1), 0)
WHERE
  rd_id = 0;
