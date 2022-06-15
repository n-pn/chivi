-- +micrate Up
ALTER TABLE ysbooks RENAME COLUMN info_stime TO stime;

ALTER TABLE ysbooks ADD COLUMN bcover text not null default '';
ALTER TABLE ysbooks ADD COLUMN bintro text not null default '';
ALTER TABLE ysbooks ADD COLUMN bgenre text not null default '';
ALTER TABLE ysbooks ADD COLUMN shield int not null default 0;

-- +micrate Down

ALTER TABLE ysbooks RENAME COLUMN stime TO info_stime;

ALTER TABLE ysbooks DROP COLUMN bcover;
ALTER TABLE ysbooks DROP COLUMN bintro;
ALTER TABLE ysbooks DROP COLUMN bgenre;
ALTER TABLE ysbooks DROP COLUMN shield;
