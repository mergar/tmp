class cbsd_k8s::config(
  $ensure           = 'present',
  $config_file_path = '/kubernetes/config',
  $config_source    = 'standalone',
  $etcd_ver         = 'v3.4.13',
  $cluster_name     = 'cloud.com',
  $api_server       = 'https://master.cloud.com',
  $api_servers      = 'https://master.cloud.com',
  $apiserver_host   = 'https://master.cloud.com',
  $vip              = '10.0.0.100',
)
{
  file { $config_file_path:
    mode    => '0644',
    ensure  => $ensure,
    content => template("${module_name}/${config_source}.erb"),
    owner   => 0,
    group   => 0,
  }

}
