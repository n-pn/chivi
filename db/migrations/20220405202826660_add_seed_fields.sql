-- +micrate Up
ALTER TABLE ysbooks RENAME COLUMN info_stime TO stime;

ALTER TABLE ysbooks ADD COLUMN bcover text not null default '';
ALTER TABLE ysbooks ADD COLUMN bintro text not null default '';
ALTER TABLE ysbooks ADD COLUMN bgenre text not null default '';
ALTER TABLE ysbooks ADD COLUMN shield int not null default 0;


ALTER TABLE nvseeds ADD COLUMN btitle text not null default '';
ALTER TABLE nvseeds ADD COLUMN author text not null default '';
ALTER TABLE nvseeds ADD COLUMN bcover text not null default '';
ALTER TABLE nvseeds ADD COLUMN bintro text not null default '';
ALTER TABLE nvseeds ADD COLUMN bgenre text not null default '';

-- +micrate Down

ALTER TABLE ysbooks RENAME COLUMN stime TO info_stime;

ALTER TABLE ysbooks DROP COLUMN bcover;
ALTER TABLE ysbooks DROP COLUMN bintro;
ALTER TABLE ysbooks DROP COLUMN bgenre;
ALTER TABLE ysbooks DROP COLUMN shield;


ALTER TABLE nvseeds DROP COLUMN btitle;
ALTER TABLE nvseeds DROP COLUMN author;
ALTER TABLE nvseeds DROP COLUMN bcover;
ALTER TABLE nvseeds DROP COLUMN bintro;
ALTER TABLE nvseeds DROP COLUMN bgenre;
