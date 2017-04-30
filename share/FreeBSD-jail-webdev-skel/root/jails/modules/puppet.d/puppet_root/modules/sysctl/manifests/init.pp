#
class sysctl {
	exec { "sysctl -p":
		command     => "sysctl -p",
		refreshonly => true,
	}
}
