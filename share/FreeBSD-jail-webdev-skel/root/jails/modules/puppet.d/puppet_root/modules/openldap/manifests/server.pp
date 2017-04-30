# alternative openldap name sets via $openldapname

define openldap::server( $ensure=present,
	$version="latest",
	$database='dc=example,dc=com',
	$cn="Manager",
	$rootdn='cn=$cn,dc=example,dc=com',
	$rootpw='secret' ) {

	case $operatingsystem {
		centos, redhat, debian, ubuntu: {
			$openldapconfig="/etc/openldap/ldap.conf"
			$servicename="slapd"
			class { "openldap::install": ensure => $ensure, version => $version }
			}
		freebsd: {
			$openldapconfig="/usr/local/etc/openldap/ldap.conf"
			$slapdconfig="/usr/local/etc/openldap/slapd.conf"
			$servicename="slapd"
			}
	}

	file { "$openldapconfig":
		notify  => $notify_restart ? {
			true    => Exec["openldap-server_restart"],
			default => undef,
		},
		mode => '0600',
		ensure  => present,
		content => template("openldap/ldap.conf.erb"),
	}

	file { "$slapdconfig":
		notify  => $notify_restart ? {
			true    => Exec["openldap-server_restart"],
			default => undef,
		},
		mode => '0600',
		ensure  => present,
		content => template("openldap/slapd.conf.erb"),
	}

	file { "/root/example_user.ldif":
		mode => '0400',
		ensure  => present,
		content => template("openldap/example_user.ldif.erb"),
	}

	file { "/root/example.ldif":
		mode => '0400',
		ensure  => present,
		content => template("openldap/example.ldif.erb"),
		notify => Exec["/root/example.ldif"],
	}

	exec {"/root/example.ldif":
		command     => "service $servicename onerestart && sleep 2 && ldapadd -Z -D \"cn=$cn,$database\" -w $rootpw -f /root/example.ldif",
		refreshonly => true,
		require => [ Service["$servicename"], File["/root/example_user.ldif"] ]
	}

	exec {"openldap-server_restart":
		command     => "service $servicename restart",
		refreshonly => true,
	}

	service {"$servicename":
		enable     => true,
		hasrestart => true,
		hasstatus  => true,
	}
}
