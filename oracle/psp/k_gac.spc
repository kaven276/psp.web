create or replace package k_gac authid current_user is

	procedure set
	(
		ctx   varchar2,
		attr  varchar2,
		value varchar2
	);

	procedure rm
	(
		ctx  varchar2,
		attr varchar2
	);

	procedure rm(ctx varchar2);

	procedure gset
	(
		ctx   varchar2,
		attr  varchar2,
		value varchar2
	);

	procedure grm
	(
		ctx  varchar2,
		attr varchar2
	);

	procedure grm(ctx varchar2);

end k_gac;
/
