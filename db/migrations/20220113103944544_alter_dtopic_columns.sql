-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

ALTER TABLE dtopics RENAME COLUMN label_ids TO dlabel_ids;
ALTER TABLE dtopics RENAME COLUMN uslug TO tslug;

ALTER TABLE dtopics RENAME COLUMN posts TO post_count;
ALTER TABLE dtopics RENAME COLUMN marks TO like_count;
ALTER TABLE dtopics RENAME COLUMN views TO view_count;


-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

ALTER TABLE dtopics RENAME COLUMN dlabel_ids TO label_ids;
ALTER TABLE dtopics RENAME COLUMN tslug TO uslug;

ALTER TABLE dtopics RENAME COLUMN post_count TO posts;
ALTER TABLE dtopics RENAME COLUMN like_count TO marks;
ALTER TABLE dtopics RENAME COLUMN view_count TO views;
