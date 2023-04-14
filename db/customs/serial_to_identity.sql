BEGIN;
COPY murepls TO '/mnt/serve/chivi/_pg/.bak/murepls.csv' WITH DELIMITER ',' CSV HEADER;
ALTER TABLE murepls
  ALTER id DROP DEFAULT;
-- drop default
DROP SEQUENCE murepls_id_seq;
-- drop owned sequence
ALTER TABLE murepls
  ALTER id
  ADD GENERATED ALWAYS AS IDENTITY;
SELECT
  setval(pg_get_serial_sequence('murepls', 'id'), coalesce(MAX(id), 1))
FROM
  murepls;
COMMIT;
