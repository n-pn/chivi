BEGIN;
COPY gdrepls TO '/mnt/serve/chivi/_pg/.bak/gdrepls.csv' WITH DELIMITER ',' CSV HEADER;
ALTER TABLE gdrepls
  ALTER id DROP DEFAULT;
-- drop default
DROP SEQUENCE gdrepls_id_seq;
-- drop owned sequence
ALTER TABLE gdrepls
  ALTER id
  ADD GENERATED ALWAYS AS IDENTITY;
SELECT
  setval(pg_get_serial_sequence('gdrepls', 'id'), coalesce(MAX(id), 1))
FROM
  gdrepls;
COMMIT;
