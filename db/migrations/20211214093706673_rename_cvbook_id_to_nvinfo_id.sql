-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE yscrits RENAME COLUMN cvbook_id TO nvinfo_id;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE yscrits RENAME COLUMN nvinfo_id TO cvbook_id;
