	class { 'loginconf': }
	exec { "/usr/sbin/sysrc sendmail_enable=NO": }
	exec { "/usr/sbin/sysrc redmine_enable=YES": }
	exec { "/usr/sbin/sysrc redmine_flags='-a 0.0.0.0 -p 8080 -e production'": }
	exec { "/usr/sbin/sysrc redmine_user=www": }
	exec { "/usr/sbin/sysrc redmine_group=www": }

	$mysql_server_root_password="#mysql_server_root_password#"
	$redmine_db="redmine_db"
	$redmine_db_user="redmine_db_user"
	$redmine_db_password="redmine_db_password"
	$redmine_fqdn="redmine.example.com"

	class { '::mysql::server':
		root_password           => '#mysql_server_root_password#',
		remove_default_accounts => true,
		override_options        => $override_options
	}

	mysql::db { "${redmine_db}":
		charset => 'utf8',
		user     => "${redmine_db_user}",
		password => "${redmine_db_password}",
		host     => '%',
		grant    => [ 'ALL' ],
	}

	mysql_user { "${redmine_db_user}@127.0.0.1":
		ensure                   => 'present',
		max_connections_per_hour => '0',
		max_queries_per_hour     => '0',
		max_updates_per_hour     => '0',
		max_user_connections     => '0',
	}

	$packages = [ "www/redmine", "misc/mc", "devel/git", "shells/bash" ]

	package { $packages:
		ensure => "latest",
	}

	class { 'nginx': }

#	Shellvar { target => '/etc/rc.conf' }
#	shellvar { "sendmail_enable": value => "NO" }

#	shellvar { "redmine_enable": value => "YES" }
#	shellvar { "redmine_flags": value => "-a 0.0.0.0 -p 8080 -e production" }
#	shellvar { "redmine_user": value => "www" }
#	shellvar { "redmine_group": value => "www" }

	exec { "run_rm_rminstall.sh":
		command => "/usr/sbin/chown -R www:www /usr/local/www/redmine && \
cd /usr/local/www/redmine && /usr/local/bin/bundle exec rake generate_secret_token && \
cd /usr/local/www/redmine && env RAILS_ENV=production /usr/local/bin/bundle exec rake db:migrate && \
cd /usr/local/www/redmine && env RAILS_ENV=production REDMINE_LANG=en /usr/local/bin/bundle exec rake redmine:load_default_data &&
/usr/bin/touch /var/log/rminstall.done > /var/log/rminstall.log 2>&1",
		onlyif => "/bin/test ! -f /var/log/rminstall.done && /usr/bin/grep -q cix_redmine /usr/local/www/redmine/config/database.yml",
		require => Package[ 'www/redmine'],
		notify  => Service['redmine'],
	}


	service { 'redmine':
		ensure => running,
		enable => true,
	}

	user { "www":
		ensure => present,
		shell      => '/bin/sh',
	}

	class { 'cix_redmine':
		redmine_db => "${redmine_db}",
		redmine_db_user => "${redmine_db_user}",
		redmine_db_password => "${redmine_db_password}",
	}
