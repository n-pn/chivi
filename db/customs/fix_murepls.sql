
alter table muheads rename to rproots;
alter index muheads_viuser_idx rename to rproots_viuser_idx;

alter table rproots add column view_count int not null default 0;
alter table rproots add column like_count int not null default 0;
alter table rproots add column star_count int not null default 0;

alter table rproots add column kind smallint not null default 0;
alter table rproots add column ukey citext not null default '';

create index rproots_unique_idx on rproots(kind, ukey);
-- create unique index rproots_unique_idx on rproots(kind, ukey);

alter table murepls rename to rpnodes;

ALTER TABLE rpnodes
  rename muhead_id to rproot_id;

alter index murepls_viuser_idx rename to rpnodes_viuser_idx;
alter index murepls_tagged_idx rename to rpnodes_tagged_idx;
alter index murepls_touser_idx rename to rpnodes_touser_idx;
alter index murepls_torepl_idx rename to rpnodes_torepl_idx;
