-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

ALTER TABLE dtopics RENAME COLUMN dboard_id TO nvinfo_id;
ALTER TABLE dtopics ADD COLUMN dtbody_id integer not null default '0';
ALTER TABLE dtopics ADD COLUMN labels text[] not null default '{}';

ALTER TABLE nvinfos ADD COLUMN dt_view_count integer not null default '0';
ALTER TABLE nvinfos ADD COLUMN dt_post_utime bigint not null default '0';

DROP INDEX IF EXISTS dtopic_labels_idx;
CREATE INDEX dtopic_labels_idx ON dtopics using GIN(labels);
CREATE INDEX nvinfo_dutime_idx ON nvinfos (dt_post_utime);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE dtopics RENAME COLUMN nvinfo_id TO dboard_id;
ALTER TABLE dtopics DROP COLUMN dtbody_id;
ALTER TABLE dtopics DROP COLUMN labels;

ALTER TABLE nvinfos DROP COLUMN dt_view_count;
ALTER TABLE nvinfos DROP COLUMN dt_post_utime;
