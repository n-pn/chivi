-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

--- foreign

alter table ubmemos alter column cvuser_id type int;
alter table ubmemos rename column cvuser_id to viuser_id;

alter table cvposts alter column cvuser_id type int;
alter table cvposts rename column cvuser_id to viuser_id;

alter table cvrepls alter column cvuser_id type int;
alter table cvrepls rename column cvuser_id to viuser_id;

alter table cvrepls alter column repl_cvuser_id type int;
alter table cvrepls rename column repl_cvuser_id to repl_viuser_id;

alter table user_posts alter column cvuser_id type int;
alter table user_posts rename column cvuser_id to viuser_id;

alter table user_repls alter column cvuser_id type int;
alter table user_repls rename column cvuser_id to viuser_id;

alter table donates alter column cvuser_id type int;
alter table donates rename column cvuser_id to viuser_id;

alter table unotifs alter column cvuser_id type int;
alter table unotifs rename column cvuser_id to viuser_id;

alter table uqueues alter column cvuser_id type int;
alter table uqueues rename column cvuser_id to viuser_id;

alter table chedits alter column cvuser_id type int;
alter table chedits rename column cvuser_id to viuser_id;

alter table chtrans alter column cvuser_id type int;
alter table chtrans rename column cvuser_id to viuser_id;


--- main

alter table cvusers alter column id type int;
alter sequence cvusers_id_seq as int;

alter table cvusers rename to viusers;
alter sequence cvusers_id_seq rename to viusers_id_seq;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

-- main

alter sequence viusers_id_seq rename to cvusers_id_seq;
alter table viusers rename to cvusers;

alter sequence cvusers_id_seq as bigint;
alter table cvusers alter column id type bigint;

--- foreign

alter table ubmemos alter column viuser_id type bigint;
alter table ubmemos rename column viuser_id to cvuser_id;

alter table cvposts alter column viuser_id type bigint;
alter table cvposts rename column viuser_id to cvuser_id;

alter table cvrepls alter column viuser_id type bigint;
alter table cvrepls rename column viuser_id to cvuser_id;
alter table cvrepls alter column repl_viuser_id type bigint;
alter table cvrepls rename column repl_viuser_id to repl_cvuser_id;

alter table user_posts alter column viuser_id type bigint;
alter table user_posts rename column viuser_id to cvuser_id;

alter table user_repls alter column viuser_id type bigint;
alter table user_repls rename column viuser_id to cvuser_id;

alter table donates alter column viuser_id type bigint;
alter table donates rename column viuser_id to cvuser_id;

alter table unotifs alter column viuser_id type bigint;
alter table unotifs rename column viuser_id to cvuser_id;

alter table uqueues alter column viuser_id type bigint;
alter table uqueues rename column viuser_id to cvuser_id;

alter table chedits alter column viuser_id type bigint;
alter table chedits rename column viuser_id to cvuser_id;

alter table chtrans alter column viuser_id type bigint;
alter table chtrans rename column viuser_id to cvuser_id;
