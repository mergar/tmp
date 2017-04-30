# Global Defaults
Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin" }
# Global Defaults
stage { [ pre, post, pre-main, post-main ]: }
Stage[pre] -> Stage[pre-main] -> Stage[main] -> Stage[post-main] -> Stage[post]

File { backup => main }

case $operatingsystem {
	centos, redhat: {
		$provider = "yum"
		include linux-default
	}
	freebsd: {
		$provider = "pkgng"
		File {
			owner => root,
			group => wheel,
		}
		include freebsd-default
	}
	debian, ubuntu: {
		$provider = "dpkg"
		File {
			owner => root,
			group => root,
		}
		include linux-default
	}
	default: { fail("Unrecognized operating system") }
}

# ldapize
#class { "ldapize":
#                ldapserver => "206.54.181.148",
#                database => "dc=mobbtech,dc=com",
#                # ou => undef,
#                # ou => "ou=People",
#                binddn => "cn=readonly,dc=mobbtech,dc=com",
#                bindpw => "iequighaiMehah0ooxoh",
#        }
#
