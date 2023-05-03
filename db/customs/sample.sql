ALTER TABLE btitles
  ALTER COLUMN id TYPE int;

ALTER SEQUENCE btitles_id_seq
  AS int;

---
ALTER TABLE wninfos
  ADD CONSTRAINT wninfos_author_id_fkey FOREIGN KEY (author_id) REFERENCES authors(id) ON UPDATE CASCADE ON DELETE CASCADE;
