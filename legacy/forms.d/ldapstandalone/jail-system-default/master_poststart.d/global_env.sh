#!/bin/sh

IWM=${ip4_addr%%/*}
/usr/sbin/sysrc -qf ${workdir}/etc/forms_env.conf H_ldap_host="${IWM}"

# re-export global variable
if [ -r "${workdir}/modules/puppet.d/sync_env2form" ]; then
	/usr/local/bin/cbsd sync_env2form
fi
