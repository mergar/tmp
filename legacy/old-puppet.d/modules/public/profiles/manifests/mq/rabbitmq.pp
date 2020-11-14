class profiles::mq::rabbitmq (
  $globals = {},
  Hash $policy = {},
  Hash $users = {},
  Hash $instance = {},
  Hash $vhosts = {},
  Hash $user_permissions = {},
  Hash $plugins = {},
){

  class { '::rabbitmq':
    * => $globals,
  }
  create_resources(rabbitmq_vhost, $vhosts)
  create_resources(rabbitmq_user, $users)
  create_resources(rabbitmq_user_permissions, $user_permissions)
  create_resources(rabbitmq_plugin, $plugins)

  # should be after vhost
  # loop + timeout when vhost not exist
  create_resources(rabbitmq_policy, $policy)

}
