create or replace package body g is

	procedure finish is
	begin
		raise pv.ex_resp_done;
	end;

	procedure filter_pass is
	begin
		raise pv.ex_fltr_done;
	end;

	procedure interrupt(url varchar2) is
		v_sep char(1) := t.tf(instrb(url, '?') > 0, '&', '?');
	begin
		h.go(url || v_sep || 'action=' || utl_url.escape(r.url || '&$referer=' || utl_url.escape(r.referer, true), true));
	end;

end g;
/
