UPDATE
  uquotas
SET
  privi_bonus = 50000
WHERE
  idate = 20240321
  AND vu_id < - 1;

UPDATE
  uquotas
SET
  privi_bonus = 100000
WHERE
  idate = 20240321
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
  privi_bonus = 250000
WHERE
  idate = 20240321
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
  privi_bonus = 500000
WHERE
  idate = 20240321
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
  privi_bonus = 1000000
WHERE
  idate = 20240321
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
  privi_bonus = 2500000
WHERE
  idate = 20240321
  AND vu_id IN (
    SELECT
      id
    FROM
      viusers
    WHERE
      privi = 4);

UPDATE
  uquotas
SET
  privi_bonus = 5000000
WHERE
  idate = 20240321
  AND vu_id IN (
    SELECT
      id
    FROM
      viusers
    WHERE
      privi = 5);
