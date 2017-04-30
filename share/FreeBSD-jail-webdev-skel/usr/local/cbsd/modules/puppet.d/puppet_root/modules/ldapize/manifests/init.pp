# alternative redis name sets via $redisname

class ldapize ( $ensure=present,
	$ldapserver="192.168.1.3",
	$database="dc=example,dc=com",
#	$ou="ou=People",
	$ou=undef,
	$binddn=undef,
	$bindpw=undef ) {

#	$packages = [ "pam_mkhomedir", "nss_ldap", "pam_ldap" ]

#	package { $packages:
#		ensure  => $ensure
#	}

	if $ensure == "absent" {
		$ldapize=undef
	} else {
		$ldapize=true
	}

	file {'/usr/local/etc':
		ensure => directory,
	}

	file {'/usr/local/etc/openldap':
		ensure => directory,
		require => File["/usr/local/etc"],
	}

	file { "/usr/local/etc/ldap.conf":
		ensure  => present,
		content => template("$module_name/ldap.conf.erb"),
		mode => '0644',
		require => File["/usr/local/etc"],
	}

	file { "/etc/nsswitch.conf":
		ensure  => present,
		content => template("$module_name/nsswitch.conf.erb"),
		mode => '0644',
	}

	file { "/etc/pam.d/sshd":
		ensure  => present,
		content => template("$module_name/sshd.erb"),
		mode => '0644',
	}


	file { "/usr/local/etc/nss_ldap.conf":
		ensure  => present,
		content => template("$module_name/nss_ldap.conf.erb"),
		mode => '0644',
		require => File["/usr/local/etc"],
	}

	file { "/usr/local/etc/openldap/ldap.conf":
		ensure  => present,
		content => template("$module_name/openldap/ldap.conf.erb"),
		mode => '0644',
		require => File["/usr/local/etc/openldap"],
	}

}
