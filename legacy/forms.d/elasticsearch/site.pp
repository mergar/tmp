# my_module_dir variable define in puppet script

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

generate_manifest()
{

cat <<EOF
  class { 'java': }
  class { 'profiles::db::elasticsearch': }
EOF

}

generate_hieradata()
{
	local my_common_yaml="${my_module_dir}/common.yaml"
	local instance_part_header="${my_module_dir}/instance_part_header.yaml"
	local instance_part_body="${my_module_dir}/instance_part_body.yaml"
	local _val _tpl

	if [ ! -r ${instance_part_header} ]; then
		echo "no such ${instance_part_header}"
		exit 0
	fi

	if [ ! -r ${instance_part_body} ]; then
		echo "no such ${instance_part_body}"
		exit 0
	fi

	local form_add_instance=0

	if [ -f "${my_common_yaml}" ]; then
		local tmp_common_yaml=$( mktemp )
		/bin/cp ${my_common_yaml} ${tmp_common_yaml}
		for i in ${param}; do
			case "${i}" in
				# start with instance  custom
				instance_name[1-9]*)
					form_add_instance=$(( form_add_instance + 1 ))
					continue;
					;;
				-*)
					# delimier params
					continue
					;;
				Expand)
					# delimier params
					continue
					;;
			esac

			eval _val=\${${i}}
			_tpl="#${i}#"
			sed -i${sed_delimer}'' -Ees:"${_tpl}":"${_val}":g ${tmp_common_yaml}
		done
	else
		for i in ${param}; do
			eval _val=\${${i}}
		cat <<EOF
 $i: "${_val}"
EOF
		done
	fi

	# custom instance
	if [ ${form_add_instance} -ne 0 ]; then
		cat ${instance_part_header} >> ${tmp_common_yaml}
		tmpfile=$( mktemp )
		cp -a ${instance_part_body} ${tmpfile}
		allfound=0
		for i in ${param}; do
			case "${i}" in
				instance_name[1-9]*)
					_tpl="#instance_name#"
					allfound=$(( allfound + 1 ))
					;;
				instance_http_bind_host[1-9]*)
					_tpl="#instance_http_bind_host#"
					allfound=$(( allfound + 1 ))
					;;
				instance_http_port[1-9]*)
					_tpl="#instance_http_port#"
					allfound=$(( allfound + 1 ))
					;;
				*)
					continue
					;;
			esac

			eval _val=\${${i}}
			[ -z "${_val}" ] && continue

			sed -i${sed_delimer}'' -Ees/"${_tpl}"/"${_val}"/g ${tmpfile}
			if [ ${allfound} -eq 3 ]; then
				cat ${tmpfile} >> ${tmp_common_yaml}
				cat ${instance_part_body} > ${tmpfile}
				allfound=0
			fi
		done
#		cat ${tmpfile} >> ${tmp_common_yaml}
#		cp -a ${tmpfile} /tmp/x.yaml
		rm -f ${tmpfile}
	fi

	cat ${tmp_common_yaml}
}
