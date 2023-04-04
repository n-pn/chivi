-- ALTER TABLE yscrits
--   ALTER COLUMN ysbook_id TYPE int;
-- ALTER TABLE yscrits
--   ADD CONSTRAINT yscrits_ysbooks_fkey FOREIGN KEY (ysbook_id) REFERENCES ysbooks (id) ON UPDATE CASCADE ON DELETE CASCADE;
-- ALTER TABLE yscrits
--   ALTER COLUMN nvinfo_id TYPE int;
-- ALTER TABLE yscrits
--   ADD CONSTRAINT yscrits_wninfos_fkey FOREIGN KEY (nvinfo_id) REFERENCES nvinfos (id) ON UPDATE CASCADE ON DELETE CASCADE;
-- ALTER TABLE yscrits
--   ALTER COLUMN ysuser_id TYPE int;
-- ALTER TABLE yscrits
--   ADD CONSTRAINT yscrits_ysusers_fkey FOREIGN KEY (ysuser_id) REFERENCES ysusers (id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ysrepls
  DROP CONSTRAINT ysrepls_pkey;

ALTER TABLE ysrepls
  ADD CONSTRAINT ysrepls_pkey PRIMARY KEY ("yr_id");

DROP INDEX ysrepl_origin_idx;

ALTER TABLE ysrepls
  ADD CONSTRAINT ysrepls_uniq UNIQUE ("id");

ALTER SEQUENCE yscrits_id_seq
  RESTART WITH 1;

UPDATE
  yscrits
SET
  id = nextval('yscrits_id_seq');

ALTER TABLE ysrepls
  ALTER COLUMN yr_id TYPE bytea
  USING decode(yr_id, 'hex');

ALTER TABLE ysrepls
  DROP CONSTRAINT ysrepls_pkey;

ALTER TABLE ysrepls
  ADD CONSTRAINT ysrepls_pkey PRIMARY KEY ("id");

ALTER TABLE ysrepls
  DROP CONSTRAINT ysrepls_uniq;

ALTER TABLE ysrepls
  ADD CONSTRAINT ysrepls_uniq UNIQUE ("yr_id");

ALTER TABLE ysrepls
  ADD CONSTRAINT yscrits_yscrits_fkey FOREIGN KEY (yscrit_id) REFERENCES yscrits (id) ON UPDATE CASCADE ON DELETE CASCADE;
