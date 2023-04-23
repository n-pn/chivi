BEGIN;
ALTER TABLE muheads RENAME TO rproots;
ALTER INDEX muheads_viuser_idx RENAME TO rproots_viuser_idx;
ALTER TABLE rproots
  ADD COLUMN view_count int NOT NULL DEFAULT 0;
ALTER TABLE rproots
  ADD COLUMN like_count int NOT NULL DEFAULT 0;
ALTER TABLE rproots
  ADD COLUMN star_count int NOT NULL DEFAULT 0;
ALTER TABLE rproots
  ADD COLUMN kind smallint NOT NULL DEFAULT 0;
ALTER TABLE rproots
  ADD COLUMN ukey citext NOT NULL DEFAULT '';
CREATE INDEX rproots_unique_idx ON rproots(kind, ukey);
-- create unique index rproots_unique_idx on rproots(kind, ukey);
ALTER TABLE murepls RENAME TO rpnodes;
ALTER TABLE rpnodes RENAME muhead_id TO rproot_id;
ALTER INDEX murepls_viuser_idx RENAME TO rpnodes_viuser_idx;
ALTER INDEX murepls_tagged_idx RENAME TO rpnodes_tagged_idx;
ALTER INDEX murepls_touser_idx RENAME TO rpnodes_touser_idx;
ALTER INDEX murepls_torepl_idx RENAME TO rpnodes_torepl_idx;
COMMIT;
