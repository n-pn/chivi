-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

ALTER TABLE zhbooks ADD ix bigint not null default '0';

CREATE INDEX zhbooks_unique_idx on zhbooks(ix);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

ALTER TABLE zhbooks drop ix;
