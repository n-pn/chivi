-- ALTER TABLE murepls
--   ADD COLUMN muhead_id int NOT NULL DEFAULT 0;
-- CREATE INDEX murepls_head_idx ON murepls(muhead_id);
-- ALTER TABLE murepls
--   DROP COLUMN otext;
ALTER TABLE murepls
  DROP COLUMN thread_id,
  DROP COLUMN thread_mu;
