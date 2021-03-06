create or replace package output is

	procedure "_init"(passport pls_integer);

	procedure write_head;

	procedure css(str varchar2);

	procedure do_css_write;

	procedure line
	(
		str    varchar2 character set any_cs,
		nl     varchar2 := chr(10),
		indent pls_integer := null
	);

	procedure flush;

	procedure finish;

	procedure do_write
	(
		v_len  in integer,
		v_gzip in boolean
	);

end output;
/
