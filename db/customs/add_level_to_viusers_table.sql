ALTER TABLE viusers
  ADD COLUMN IF NOT EXISTS "level" smallint NOT NULL DEFAULT 0;

UPDATE
  viusers
SET
  "level" = 1
WHERE
  privi > 0
  AND created_at < '2023-09-01';

UPDATE
  viusers
SET
  "level" = 2
WHERE
  privi > 1
  AND created_at < '2023-08-01';

UPDATE
  viusers
SET
  "level" = 3
WHERE
  privi > 2
  AND created_at < '2023-07-01';

UPDATE
  viusers
SET
  "level" = 4
WHERE
  privi > 2
  AND created_at < '2023-06-01'
  AND vcoin > 500;
