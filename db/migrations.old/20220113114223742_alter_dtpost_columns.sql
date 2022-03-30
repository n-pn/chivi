-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

ALTER TABLE dtposts RENAME COLUMN odesc TO otext;

ALTER TABLE dtposts RENAME COLUMN edits TO edit_count;
ALTER TABLE dtposts RENAME COLUMN likes TO like_count;
ALTER TABLE dtposts ADD COLUMN repl_count int not null default '0';

ALTER TABLE dtposts ADD COLUMN repl_dtpost_id bigint not null default '0';
ALTER TABLE dtposts ADD COLUMN repl_cvuser_id bigint not null default '0';

ALTER TABLE dtposts RENAME COLUMN award TO coins;

CREATE INDEX dtpost_repl_dtpost_idx ON dtposts (repl_dtpost_id);
CREATE INDEX dtpost_repl_cvuser_idx ON dtposts (repl_cvuser_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

ALTER TABLE dtposts RENAME COLUMN otext TO odesc;

ALTER TABLE dtposts RENAME COLUMN edit_count TO edits;
ALTER TABLE dtposts RENAME COLUMN like_count TO likes;
ALTER TABLE dtposts DROP COLUMN repl_count;

ALTER TABLE dtposts DROP COLUMN repl_dtpost_id;
ALTER TABLE dtposts DROP COLUMN repl_cvuser_id;

ALTER TABLE dtposts RENAME COLUMN coins TO award;
