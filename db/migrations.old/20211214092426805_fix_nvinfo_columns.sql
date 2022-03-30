-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE nvinfos ALTER COLUMN cv_utime TYPE bigint;
ALTER TABLE nvinfos ALTER COLUMN ys_utime TYPE bigint;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
