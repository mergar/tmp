# my_module_dir variable define in puppet script

# GLOBAL_ENV: also store variables in $etcdir/forms_env.conf as global H_variable
GLOBAL_ENV="ldap_suffix ldap_bind_id ldap_bind_password"

# Linux required -i'', not "-i ''" for inplace
os=$( uname -s )
case "${os}" in
	Linux)
		# Linux require -i'', not -i ' '
		sed_delimer=
		;;
	FreeBSD)
		sed_delimer=" "
		;;
esac

if [ ! -r "${etcdir}/forms_env.conf" ]; then
	touch ${etcdir}/forms_env.conf
	chmod 0400 ${etcdir}/forms_env.conf
fi


# $1 - param
# return 0 if variable $1 exist in GLOBAL_ENV
is_global()
{
	local i _ret

	for i in ${GLOBAL_ENV}; do
		[ "${i}" = "${1}" ] && return 0
	done

	return 1
}


generate_manifest()
{

cat <<EOF

	class { 'nginx': }
	class { 'php': }
	class { 'cix_ldap::server': }
	class { 'cix_ldap::client': }

	\$sha_password = sha1digest("\$plain_ldap_admin_password")

	class { 'cix_lam':
		sha_password => "\${sha_password}",
	}

EOF
}

generate_hieradata()
{
	local my_common_yaml="${my_module_dir}/common.yaml"
	local _val _tpl

	if [ -f "${my_common_yaml}" ]; then
		local tmp_common_yaml=$( mktemp )
		trap "/bin/rm -f ${tmp_common_yaml}" HUP INT ABRT BUS TERM EXIT
		/bin/cp ${my_common_yaml} ${tmp_common_yaml}
		for i in ${param}; do
			eval _val=\${${i}}
			_tpl="#${i}#"
			sed -i${sed_delimer}'' -Ees:${_tpl}:${_val}:g ${tmp_common_yaml}

			if is_global ${i}; then
				sysrc -qf ${etcdir}/forms_env.conf H_${i}="${_val}"
			fi

		done
		cat ${tmp_common_yaml}
	else
		for i in ${param}; do
			eval _val=\${${i}}
		cat <<EOF
 $i: "${_val}"
EOF
		done
	fi
}
