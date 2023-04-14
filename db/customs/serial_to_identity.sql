BEGIN;
COPY vcoin_xlogs TO '/mnt/serve/chivi/_pg/.bak/vcoin_xlogs.csv' WITH DELIMITER ',' CSV HEADER;
ALTER TABLE vcoin_xlogs
  ALTER id DROP DEFAULT;
-- drop default
DROP SEQUENCE vcoin_xlogs_id_seq;
-- drop owned sequence
ALTER TABLE vcoin_xlogs
  ALTER id
  ADD GENERATED ALWAYS AS IDENTITY (RESTART 1);
COMMIT;
