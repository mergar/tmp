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
	local my_common_yaml="${my_module_dir}/site-tpl.pp"
	local _val _tpl

	if [ -f "${my_common_yaml}" ]; then
		local tmp_common_yaml=$( mktemp )
		trap "/bin/rm -f ${tmp_common_yaml}" HUP INT ABRT BUS TERM EXIT
		/bin/cp ${my_common_yaml} ${tmp_common_yaml}
		for i in ${param}; do
			eval _val=\${${i}}
			_tpl="#${i}#"
			sed -i${sed_delimer}'' -Ees:${_tpl}:${_val}:g ${tmp_common_yaml}
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


generate_hieradata()
{
	local my_common_yaml="${my_module_dir}/common.yaml"
	local my_common_yaml_add="${my_module_dir}/common1.yaml"
	local my_common_yaml_add_group="${my_module_dir}/common1_group.yaml"

	local _val _tpl

	add_group=0

	# generic body
	if [ -f "${my_common_yaml}" ]; then
		local tmp_common_yaml=$( mktemp )
		trap "/bin/rm -f ${tmp_common_yaml}" HUP INT ABRT BUS TERM EXIT
		/bin/cp ${my_common_yaml} ${tmp_common_yaml}

		for i in ${param}; do
			case "${i}" in
				config[1-9]*)
					add_group=$(( add_group + 1 ))
					continue;
					;;
				content[1-9]*)
					continue;
					;;
			esac

			eval _val=\${${i}}
			_tpl="#${i}#"
			sed -i${sed_delimer}'' -Ees/"${_tpl}"/"${_val}"/g ${tmp_common_yaml}
		done
	else
		for i in ${param}; do
			eval _val=\${${i}}
		cat <<EOF
 $i: "${_val}"
EOF
		done
	fi

	if [ ${add_group} -eq 0 ]; then
		cat ${tmp_common_yaml}
		return 0
	fi

	cat ${my_common_yaml_add_group} >> ${tmp_common_yaml}

	for i in $( seq 1 20 ); do
		[ ${i} -gt ${add_group} ] && break
#		cat ${my_common_yaml_add} >> ${tmp_common_yaml}
		sed -Ees/"@i@"/"${i}"/g  ${my_common_yaml_add} >> ${tmp_common_yaml}
	done

	for i in ${param}; do
		case "${i}" in
			config[1-9]*)
				;;
			content[1-9]*)
				;;
			*)
				continue
				;;
		esac

		eval _val=\${${i}}
		_tpl="#${i}#"
		sed -i${sed_delimer}'' -Ees/"${_tpl}"/"${_val}"/g ${tmp_common_yaml}
	done

	cat ${tmp_common_yaml}

}
