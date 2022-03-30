-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE ubmemos ADD COLUMN lr_sname text not null default '';
ALTER TABLE ubmemos RENAME COLUMN access TO atime;
ALTER TABLE ubmemos RENAME COLUMN bumped TO utime;

CREATE INDEX ubmemo_sname_idx ON ubmemos (lr_sname);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE ubmemos DROP COLUMN lr_sname;
