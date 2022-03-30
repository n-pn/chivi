-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

ALTER TABLE dtopics ADD lasttp_id bigint not null default '0';

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE dtopics remove lasttp_id;
