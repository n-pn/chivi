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
ALTER TABLE yslists
  DROP CONSTRAINT yslists_pkey;

ALTER TABLE yslists
  ADD CONSTRAINT yslists_pkey PRIMARY KEY ("yl_id");

DROP INDEX yslist_origin_idx;

ALTER TABLE yslists
  ADD CONSTRAINT yslists_uniq UNIQUE ("id");

ALTER SEQUENCE yslists_id_seq
  RESTART WITH 1;

UPDATE
  yslists
SET
  id = nextval('yslists_id_seq');
