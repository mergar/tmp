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
  class { 'zookeeper': }
  class { 'profiles::mq::kafka': }
EOF

}

generate_hieradata()
{
	local my_common_yaml="${my_module_dir}/common.yaml"
	local topic_part_header="${my_module_dir}/topic_part_header.yaml"
	local topic_part_body="${my_module_dir}/topic_part_body.yaml"
	local _val _tpl

	if [ ! -r ${topic_part_header} ]; then
		echo "no such ${topic_part_header}" 1>&2
		exit 1
	fi
	if [ ! -r ${topic_part_body} ]; then
		echo "no such ${topic_part_body}" 1>&2
		exit 1
	fi

	local form_add_topic_name=0

	if [ -f "${my_common_yaml}" ]; then
		local tmp_common_yaml=$( mktemp )
		/bin/cp ${my_common_yaml} ${tmp_common_yaml}
		for i in ${param}; do
			case "${i}" in
				topic_name[1-9]*)
					form_add_topic_name=$(( form_add_topic_name + 1 ))
					continue;
					;;
				user_name[1-9]*)
					form_add_user_name=$(( form_add_user_name + 1 ))
					continue;
					;;
				permission_user_topic[1-9]*)
					form_add_permission_user_topic=$(( form_add_permission_user_topic + 1 ))
					continue;
					;;
				plugin_name[1-9]*)
					form_add_plugin_name=$(( form_add_plugin_name + 1 ))
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
			sed -i${sed_delimer}'' -Ees%"${_tpl}"%"${_val}"%g ${tmp_common_yaml}
		done
	else
		for i in ${param}; do
			eval _val=\${${i}}
		cat <<EOF
 $i: "${_val}"
EOF
		done
	fi

	# custom topic
	if [ ${form_add_topic_name} -ne 0 ]; then
		cat ${topic_part_header} >> ${tmp_common_yaml}

		# populate topic_policy part in parallel for each topic
		tmpfile=$( mktemp )
		cp -a ${topic_part_body} ${tmpfile}
		allfound=0

		for i in ${param}; do
			case "${i}" in
				topic_name[1-9]*)
					_tpl="#topic_name#"
					allfound=$(( allfound + 1 ))
					;;
				topic_zookeeper[1-9]*)
					_tpl="#topic_zookeeper#"
					allfound=$(( allfound + 1 ))
					;;
				topic_replication_factor[1-9]*)
					_tpl="#topic_replication_factor#"
					allfound=$(( allfound + 1 ))
					;;
				topic_partitions[1-9]*)
					_tpl="#topic_partitions#"
					allfound=$(( allfound + 1 ))
					;;
				*)
					continue
					;;
			esac

			eval _val=\${${i}}
			[ -z "${_val}" ] && continue

			sed -i${sed_delimer}'' -Ees/"${_tpl}"/"${_val}"/g ${tmpfile}

			if [ ${allfound} -eq 4 ]; then
				cat ${tmpfile} >> ${tmp_common_yaml}
				cat ${topic_part_body} > ${tmpfile}
				allfound=0
			fi
		done
		rm -f ${tmpfile}
	fi

	cat ${tmp_common_yaml}
}
