BEGIN;
COPY authors TO '/mnt/serve/chivi/_pg/.bak/authors.csv' WITH DELIMITER ',' CSV HEADER;
ALTER TABLE authors
  ALTER id DROP DEFAULT;
-- drop default
DROP SEQUENCE authors_id_seq;
-- drop owned sequence
ALTER TABLE authors
  ALTER id
  ADD GENERATED ALWAYS AS IDENTITY (RESTART 1);
COMMIT;
