
alter table btitles alter column id type int;
alter sequence authors_id_seq as int;

alter table authors alter column zname type varchar;
alter table authors alter column vname type varchar;
alter table authors alter column vslug type varchar;

---

alter table btitles alter column id type int;
alter sequence btitles_id_seq as int;

alter table btitles alter column zname type varchar;
alter table btitles alter column vname type varchar;
alter table btitles alter column hname type varchar;
alter table btitles alter column vslug type varchar;
alter table btitles alter column hslug type varchar;

---

alter table nvinfos alter column author_id type int;
alter table nvinfos alter column btitle_id type int;

alter table nvinfos alter column vname type varchar;
alter table nvinfos alter column bslug type varchar;
alter table nvinfos alter column scover type varchar;
alter table nvinfos alter column bcover type varchar;

alter table nvinfos alter column vlabels type varchar[];

alter table nvinfos add constraint nvinfos_author_id_fkey
  foreign key (author_id) references authors (id)
  on update cascade on delete cascade;

alter table nvinfos add constraint nvinfos_btitle_id_fkey
  foreign key (btitle_id) references btitles (id)
  on update cascade on delete cascade;
