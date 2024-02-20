UPDATE
  uquotas
SET
  privi_bonus = 50000
WHERE
  idate = 20240220
  AND vu_id < - 1;

UPDATE
  uquotas
SET
  privi_bonus = 100000
WHERE
  idate = 20240220
  AND vu_id IN (
    SELECT
      id
    FROM
      viusers
    WHERE
      privi = 0);

UPDATE
  uquotas
SET
  privi_bonus = 200000
WHERE
  idate = 20240220
  AND vu_id IN (
    SELECT
      id
    FROM
      viusers
    WHERE
      privi = 1);

UPDATE
  uquotas
SET
  privi_bonus = 400000
WHERE
  idate = 20240220
  AND vu_id IN (
    SELECT
      id
    FROM
      viusers
    WHERE
      privi = 2);

UPDATE
  uquotas
SET
  privi_bonus = 800000
WHERE
  idate = 20240220
  AND vu_id IN (
    SELECT
      id
    FROM
      viusers
    WHERE
      privi = 3);

UPDATE
  uquotas
SET
  privi_bonus = 1600000
WHERE
  idate = 20240220
  AND vu_id IN (
    SELECT
      id
    FROM
      viusers
    WHERE
      privi = 4);
