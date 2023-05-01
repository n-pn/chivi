ALTER TABLE rproots RENAME TO gdroots;

ALTER TABLE gdroots
  ADD COLUMN rlink text NOT NULL DEFAULT '',
  ADD COLUMN title text NOT NULL DEFAULT '',
  ADD COLUMN intro text NOT NULL DEFAULT '';

ALTER TABLE gdroots
  ADD COLUMN olink text NOT NULL DEFAULT '',
  ADD COLUMN oname text NOT NULL DEFAULT '';

ALTER TABLE gdroots
  ADD COLUMN htags text[] NOT NULL DEFAULT '{}';

CREATE INDEX gdroot_htags_idx ON gdroots USING gin(htags);

ALTER TABLE gdroots
  DROP COLUMN viuser_id;

ALTER TABLE gdroots
  DROP COLUMN dboard_id;
