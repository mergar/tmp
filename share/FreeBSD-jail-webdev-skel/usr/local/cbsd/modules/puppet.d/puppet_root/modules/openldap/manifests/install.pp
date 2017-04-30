# logfile can be "/dev/null"

class openldap::install($ensure = present, $version="latest" ){

	if $ensure == "absent" {
		$myversion="absent"
	} else {
		$myversion=$version
	}

	case $operatingsystem {
		centos, redhat: { }
		freebsd: {
			$packages = [ "openldap-server" ]
		}
		debian, ubuntu: {
			$packages = [ "openldap-tools", "openldap-server" ]
		}
		default: {
			fail("Unrecognized operating system")
			}
	}

	package { $packages:
		ensure  => $myversion,
	}
}
