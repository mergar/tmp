#
define sysctl::conf ( $value, $ensure='present' ) {
	case $ensure {
		'present','absent':{
			include sysctl
			sysctl{"${name}":
				value  => $value,
				ensure => $ensure,
				notify => Exec["sysctl -p"]
			}
		}
		default: {
			fail("ensure must be 'present' or 'absent', not '${ensure}'!")
		}
	}
}
