-- rename nvseeds to chroots

alter table nvseeds rename to chroots;
alter table chroots alter column id type int;

alter sequence nvseeds_id_seq rename to chroots_id_seq;
alter sequence chroots_id_seq as int;

alter index nvseed_unique_idx rename to chroot_unique_idx;
alter index nvseed_nvinfo_idx rename to chroot_nvinfo_idx;
alter index nvseed_stime_idx rename to chroot_update_idx;

-- rename chtrans to chap_edits and fix nvseed_id column

alter table chedits rename to chap_edits;
alter sequence chedits_id_seq rename to chap_edits_id_seq;

alter table chap_edits rename column nvseed_id to chroot_id;
alter table chap_edits alter column chroot_id type int;

alter index chedits_viuser_idx rename to chap_edits_viuser_idx;
alter index chedits_nvseed_idx rename to chap_edits_chroot_idx;

-- rename chtrans to chap_trans and fix nvseed_id column

alter table chtrans rename to chap_trans;
alter sequence chtrans_id_seq rename to chap_trans_id_seq;

alter table chap_trans rename column nvseed_id to chroot_id;
alter table chap_trans alter column chroot_id type int;

alter index chtrans_cvuser_idx rename to chap_trans_viuser_idx;
alter index chtrans_nvseed_idx rename to chap_trans_chroot_idx;
