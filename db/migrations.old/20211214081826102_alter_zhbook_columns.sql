-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE zhbooks RENAME COLUMN cvbook_id TO nvinfo_id;
ALTER TABLE ubmemos RENAME COLUMN cvbook_id TO nvinfo_id;

ALTER TABLE zhbooks ADD COLUMN sname text not null default '';
ALTER TABLE zhbooks RENAME COLUMN bumped TO atime;
ALTER TABLE zhbooks RENAME COLUMN mftime TO utime;


-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE ubmemos RENAME COLUMN nvinfo_id TO cvbook_id;
ALTER TABLE zhbooks RENAME COLUMN nvinfo_id TO cvbook_id;

ALTER TABLE zhbooks DROP COLUMN sname;
ALTER TABLE zhbooks RENAME COLUMN atime TO bumped;
ALTER TABLE zhbooks RENAME COLUMN utime TO mftime;
