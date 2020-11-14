$acl_master_token="#acl_master_token#";

$packages = [ "security/ca_root_nss" ]

package { $packages:
	ensure => "latest",
}

class { '::consul':
	manage_service => true,
	config_dir => '/usr/local/etc/consul.d',

	config_hash => {
		'data_dir'         => '/var/tmp/consul',
		'bootstrap_expect' => 1,
		'client_addr'      => "#client_addr#",
		#                       'bind_addr'        =>   $ipaddress_enp0s4,
		'datacenter'       => "#datacenter#",
		'log_level'        => '#log_level#',
		'node_name'        => "$fqdn",
		'server'           => #server#,
		##    'encrypt'          => "secret",
		'acl_datacenter'   => '#acl_datacenter#',
		'acl_master_token' => "#acl_master_token#",
		'acl_default_policy' => "#acl_default_policy#",
		'acl_down_policy'  => "#acl_down_policy#",
		'ui_dir'           => '/var/tmp/consul/ui',
	}
}
