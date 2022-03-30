-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE cvusers ADD wtheme text not null default 'light';
ALTER TABLE cvusers ADD tlmode integer not null default '0';
ALTER TABLE cvusers DROP COLUMN prefs;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE cvusers DROP COLUMN wtheme;
ALTER TABLE cvusers DROP COLUMN tlmode;
ALTER TABLE cvusers ADD prefs jsonb not null default '{}';
