create or replace package body auth_b is

	procedure basic is
		v_user varchar2(30) := 'psp.web';
		v_pass varchar2(30) := 'best';
	begin
		if (r.user is null or r.user != v_user) and (r.pass is null or r.pass != v_pass) then
			h.www_authenticate_basic('test');
			p.h;
			p.p('Username should be ' || v_user || ' to pass');
			p.p('Password should be ' || v_pass || ' to pass');
			return;
		end if;
		p.h;
		src_b.link_proc;
		p.p('Hello ' || r.user || ', Welcome to access this page.');
		p.p('You have passed the http basic authentication.');
	end;

	procedure digest is
	begin
		h.sts_501_not_implemented;
		p.h;
		src_b.link_proc;
		p.p('PSP.WEB have not implemented http digest authentication by now.');
	end;

	procedure cookie_gac is
	begin
		p.h;
		src_b.link_proc;
		p.br;
	
		s.use('BSID');
		if s.user_id is not null then
			p.p(t.ps('You are :1, You have already logged ( at :2 ) in.', st(s.user_id, t.dt2s(s.login_time))));
			p.a('Logout', 'logout');
		else
			p.p('You are anonymous.');
		end if;
	
		p.p('Please fill your name and password to log in.');
		p.form_open('f', 'login', method => 'post');
		p.input_text('name', '', 'username: ');
		p.br;
		p.input_text('pass', '', 'password: ');
		p.br;
		p.input_reset('', 'reset');
		p.input_submit('', 'login');
		p.form_close;
	end;

	procedure login is
		v user_t%rowtype;
	begin
		h.allow('POST');
		v.name := r.getc('name');
		v.pass := r.getc('pass');
		select count(*)
			into tmp.cnt
			from user_t a
		 where a.name = v.name
			 and a.pass = v.pass;
		e.report(tmp.cnt = 0, 'User name or password is wrong.');
	
		s.use;
		s.login(v.name);
	
		p.h;
		src_b.link_proc;
		p.p('Welcome ' || v.name || ', you have logged in successfully.');
		p.a('relogin', 'cookie_gac');
	end;

	procedure logout is
	begin
		s.logout;
		-- k_sess.rm;
		h.go('cookie_gac');
	end;

	procedure protected_page is
	begin
		p.h;
		rcpv.msid := s.use_msid_cookie;
		s.use;
	
		if s.user_id is null then
			h.sts_403_forbidden;
			p.p('You have not logged in.');
			p.a('login now', 'cookie_gac');
			s.rm;
			return;
		end if;
	
		s.chk_max_idle('+00 00:01:00');
		s.chk_max_keep('+00 00:10:00');
	
		src_b.link_proc;
		p.br;
		p.p('This page show how to deal with login/logout fair, instead of using k_filter.before.');
		p.p(t.ps('You are :1, You have already logged ( at :2 ) in.', st(s.user_id, t.dt2s(s.login_time))));
		p.a('relogin', 'cookie_gac');
	
		p.br(4);
		src_b.link_proc('rc.set_user_info');
		rc.set_user_info(s.user_id);
		p.p('using result cache for user_t, we got the rowtype info');
		p.p('result cache ' || t.tf(rcpv.user_hit, 'hit', 'miss'));
		p.p('username=' || rcpv.user_row.name);
		p.p('password=' || rcpv.user_row.pass);
		p.p('crt_time=' || t.dt2s(rcpv.user_row.ctime));
	exception
		when s.over_max_idle then
			h.sts_403_forbidden;
			p.p(t.ps('You are :1, You last access time is ( at :2 ) in.', st(s.user_id, t.dt2s(s.last_access_time))));
			p.p('But this system allow only 60 seconds of idle time, then it will timeout the session.');
			p.a('relogin now', 'cookie_gac');
		when s.over_max_keep then
			h.sts_403_forbidden;
			p.p(t.ps('You are :1, You have already logged ( at :2 ) in.', st(s.user_id, t.dt2s(s.login_time))));
			p.p('But this system allow only 10 minute use after successful login.');
			p.a('relogin now', 'cookie_gac');
	end;

	procedure basic_and_cookie is
		v_user varchar2(30) := 'psp.web';
		v_pass varchar2(30) := 'best';
		v      user_t%rowtype;
	begin
		s.use;
		if s.user_id is not null then
			null;
			k_debug.trace('user in login sts');
		elsif r.user is null and r.pass is null then
			k_debug.trace('no user/pass');
			h.www_authenticate_basic('test');
			p.h;
			p.p('You should login first');
			p.script_text('alert("You should login first.");');
			g.finish;
		elsif r.user = v_user and r.pass = v_pass then
			s.login(r.user);
			k_debug.trace('user psp.web passed');
		else
			v.name := r.user;
			v.pass := r.pass;
			select count(*)
				into tmp.cnt
				from user_t a
			 where a.name = v.name
				 and a.pass = v.pass;
			if tmp.cnt = 0 then
				k_debug.trace('user dbu not passed');
				h.www_authenticate_basic('test');
				p.h;
				p.p('Username should be ' || v_user || ' to pass');
				p.p('Password should be ' || v_pass || ' to pass');
				p.p('Or user/pass should be in user_t table.' || p.a('see data', 'user_b.register'));
				g.finish;
			else
				k_debug.trace('user dbu passed');
				s.login(r.user);
			end if;
		end if;
	
		-- already logged in
		p.h;
		src_b.link_proc;
		p.br;
		p.a('Logout', 'logout_basic');
		p.p('Hello ' || r.user || ', Welcome to access this page.');
		p.p('You have passed the http basic authentication sometime ago or at right now.');
		p.p('And you use cookie and gac to mark your logged-in status.');
		p.p('So you do not need to check user/password(cause I/O from password table) for every request.');
		p.p('So you saved the so frenquently I/O operation and avoid the tranditional I/O budden of http basic authentication');
		p.p('Normally, you can not logout for http basic authentication.');
		p.p('But sometime you MAY logout with response 401, so the browser will not send last used user/pass to server.');
	end;

	procedure logout_basic is
	begin
		s.logout;
		h.www_authenticate_basic('please click cancel to logout basic authentication.');
		p.h;
		p.a('login', 'basic_and_cookie');
	end;

end auth_b;
/
