-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

ALTER TABLE cvusers ADD COLUMN pwtemp text not null default '';
ALTER TABLE cvusers ADD COLUMN pwtemp_until bigint not null default 0;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

ALTER TABLE cvusers DROP COLUMN pwtemp;
ALTER TABLE cvusers DROP COLUMN pwtemp_until;
