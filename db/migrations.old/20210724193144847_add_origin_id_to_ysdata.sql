-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE yscrits add origin_id text not null unique;
ALTER TABLE yslists add origin_id text not null unique;

DROP INDEX yscrit_ysuser_idx;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE yscrits DROP column origin_id;
ALTER TABLE yslists DROP column origin_id;
CREATE INDEX yscrit_ysuser_idx ON yscrits (ysuser_id, created_at);
