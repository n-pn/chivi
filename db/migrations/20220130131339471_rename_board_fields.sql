-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE dtopics ADD COLUMN ii integer not null default 1;
ALTER TABLE dtposts RENAME COLUMN dt_id to ii;
ALTER TABLE dtposts ALTER COLUMN ii set default 1;

DROP INDEX IF EXISTS dtopic_dboard_idx;
CREATE INDEX dtopic_sorted_idx ON dtopics (_sort, nvinfo_id);
CREATE INDEX dtopic_number_idx ON dtopics (nvinfo_id, ii);


-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

ALTER TABLE dtopics DROP COLUMN ii;
ALTER TABLE dtposts RENAME COLUMN ii to dt_id;

DROP INDEX dtopic_sorted_idx;
