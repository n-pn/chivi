BEGIN;
--
ALTER TABLE yscrits
  DROP COLUMN ysuser_id;
ALTER TABLE yscrits RENAME COLUMN yu_id TO ysuser_id;
--
ALTER TABLE yslists
  DROP COLUMN ysuser_id;
ALTER TABLE yslists RENAME COLUMN yu_id TO ysuser_id;
--
ALTER TABLE ysrepls
  DROP COLUMN ysuser_id;
ALTER TABLE ysrepls RENAME COLUMN yu_id TO ysuser_id;
ALTER TABLE ysrepls RENAME COLUMN to_yu_id TO touser_id;
--
ALTER TABLE ysusers
  DROP COLUMN id;
ALTER TABLE ysusers RENAME COLUMN yu_id TO id;
ALTER TABLE ysusers
  ADD PRIMARY KEY (id);
--
COMMIT;
