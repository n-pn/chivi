DROP TABLE IF EXISTS new_uprivis;

CREATE TABLE new_uprivis(
  vu_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  privi smallint NOT NULL,
  p_til bigint NOT NULL DEFAULT 0,
  mtime bigint NOT NULL DEFAULT 0,
  --
  auto_renew boolean NOT NULL DEFAULT FALSE,
  renew_span smallint NOT NULL DEFAULT 2,
  --
  PRIMARY KEY (vu_id, privi)
);

INSERT INTO new_uprivis
SELECT
  vu_id,
  1 AS privi,
  exp_a[1] AS p_til,
  mtime
FROM
  uprivis
WHERE
  exp_a[1] > 0;

INSERT INTO new_uprivis
SELECT
  vu_id,
  2 AS privi,
  exp_a[2] AS p_til,
  mtime
FROM
  uprivis
WHERE
  exp_a[2] > 0;

INSERT INTO new_uprivis
SELECT
  vu_id,
  3 AS privi,
  exp_a[3] AS p_til,
  mtime
FROM
  uprivis
WHERE
  exp_a[3] > 0;

INSERT INTO new_uprivis
SELECT
  vu_id,
  4 AS privi,
  exp_a[4] AS p_til,
  mtime
FROM
  uprivis
WHERE
  exp_a[4] > 0;

UPDATE
  new_uprivis
SET
  p_til = 1722504355
WHERE
  privi = 1
  AND p_til > 1722504355;
