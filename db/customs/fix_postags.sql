
update terms set ptag = "al" where ptag = "~ap";
update terms set ptag = "vl" where ptag = "~vp";
update terms set ptag = "nl" where ptag = "~np";

update terms set ptag = "+dp" where ptag = "~dp";
update terms set ptag = "+sa" where ptag = "~na";
update terms set ptag = "+sa" where ptag = "~sa";
update terms set ptag = "+sv" where ptag = "~sv";
update terms set ptag = "+pp" where ptag = "~pp";
update terms set ptag = "+pp" where ptag = "~pn";

update terms set ptag = "~vd" where ptag = "vd";
update terms set ptag = "~vn" where ptag = "vn";
update terms set ptag = "~ad" where ptag = "ad";
update terms set ptag = "~an" where ptag = "an";

update terms set ptag = "e" where ptag in ('o', 'y', 'xe', 'xo', 'xy', 'xc');

update terms set ptag = "li" where ptag in ('i', 'il');

update terms set ptag = "lt" where ptag = 'xt';
update terms set ptag = "lq" where ptag = 'xq';

update terms set ptag = "a" where ptag = "ag";
update terms set ptag = "a!" where ptag in ("b", "ab", "bl");

update terms set ptag = "vi" where ptag = '["vi"]';
update terms set ptag = "u" where ptag like "u%";
update terms set ptag = "p" where ptag like "p%";

update terms set ptag = "v" where ptag = "vg";
update terms set ptag = "v!" where ptag in ("vyou", "vshi", "vf", "vx");

update terms set ptag = "" where ptag = 'false';
update terms set ptag = "l" where ptag = '_';
update terms set ptag = "l" where ptag = '-';

update terms set ptag = "Nb" where ptag = 'Nl';
update terms set ptag = "Ns" where ptag = 'Nal';
update terms set ptag = "Nt" where ptag = 'Nag';
update terms set ptag = "Nt" where ptag = 'Na';

update terms set ptag = "n" where ptag = 'ng';

update terms set ptag = "!" where ptag = 'ahao';

update terms set ptag = "d" where ptag = 'dp';
update terms set ptag = "k" where ptag like 'k%';
update terms set ptag = "r" where ptag like 'r%';

update terms set ptag = "v!" where ptag in ("vm");

update terms set ptag = 'x' where ptag like 'x%';
update terms set ptag = 'c' where ptag = 'cc';
update terms set ptag = 'v' where ptag = 'vc';

update terms set ptag = 'Nr' where ptag = 'Nrf';
update terms set ptag = '~nd' where ptag = 'nd';
update terms set ptag = 'n' where ptag = 'nc';
update terms set ptag = 'no' where ptag = 'nv';

update terms set ptag = 's' where ptag = 'nf';
update terms set ptag = 's' where ptag = 'nf';

update terms set ptag = 't' where ptag = 'nt';
update terms set ptag = 'Ns' where ptag = 'nn';
update terms set ptag = 'Nz' where ptag = 'nz';
update terms set ptag = 'vl' where ptag = 'vp';
update terms set ptag = 'nl' where ptag = 'nj';
update terms set ptag = 'nl' where ptag = 'np';
update terms set ptag = 'Nr' where ptag = 'nr';
update terms set ptag = 'Ns' where ptag = 'ns';

update terms set ptag = 'q' where ptag = 'qt';
update terms set ptag = 'q' where ptag = 'qv';
