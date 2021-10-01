-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE ubmemos ADD access bigint not null default '0';
ALTER TABLE ubmemos ADD lr_cpart integer not null default '0';
CREATE INDEX ubmemo_access_idx ON ubmemos (access);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE ubmemos DROP COLUMN access;
ALTER TABLE ubmemos DROP COLUMN lr_cpart;
