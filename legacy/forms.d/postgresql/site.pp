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
	class { 'profiles::db::postgresql': }
EOF

}

generate_hieradata()
{
	local my_common_yaml="${my_module_dir}/common.yaml"
	local databases_part_header="${my_module_dir}/databases_part_header.yaml"
	local databases_part_body="${my_module_dir}/databases_part_body.yaml"
	local hba_rules_part_header="${my_module_dir}/hba_rules_part_header.yaml"
	local hba_rules_part_body="${my_module_dir}/hba_rules_part_body.yaml"
	local _val _tpl

	if [ ! -r ${databases_part_header} ]; then
		echo "no such ${databases_part_header}"
		exit 0
	fi

	if [ ! -r ${databases_part_body} ]; then
		echo "no such ${databases_part_body}"
		exit 0
	fi

	if [ ! -r ${hba_rules_part_header} ]; then
		echo "no such ${hba_rules_part_header}"
		exit 0
	fi

	if [ ! -r ${hba_rules_part_body} ]; then
		echo "no such ${hba_rules_part_body}"
		exit 0
	fi

	local form_add_databases=0
	local form_add_hba_rule=0

	if [ -f "${my_common_yaml}" ]; then
		local tmp_common_yaml=$( mktemp )
		/bin/cp ${my_common_yaml} ${tmp_common_yaml}
		for i in ${param}; do
			case "${i}" in
				# start with databases  custom
				databases_name[1-9]*)
					form_add_databases=$(( form_add_databases + 1 ))
					continue;
					;;
				# start with databases  custom
				hba_rules_type[1-9]*)
					form_add_hba_rule=$(( form_add_hba_rule + 1 ))
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
			# Note that on Linux systems, a space after -i might cause an error
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

	# custom databases
	if [ ${form_add_databases} -ne 0 ]; then
		cat ${databases_part_header} >> ${tmp_common_yaml}
		for i in ${param}; do
			case "${i}" in
				databases_name[1-9]*)
					;;
				*)
					continue
					;;
			esac

			eval _val=\${${i}}
			[ -z "${_val}" ] && continue

			_tpl="#databases_name#"
			sed -Ees/"${_tpl}"/"${_val}"/g ${databases_part_body} >> ${tmp_common_yaml}
		done
	fi

	# custom hba rules
	if [ ${form_add_hba_rule} -ne 0 ]; then
		cat ${hba_rules_part_header} >> ${tmp_common_yaml}
		tmpfile=$( mktemp )
		cp -a ${hba_rules_part_body} ${tmpfile}
		for i in ${param}; do
			case "${i}" in
				hba_rules_type[1-9]*)
					_tpl="#hba_rules_type#"
					;;
				hba_rules_database[1-9]*)
					_tpl="#hba_rules_database#"
					;;
				hba_rules_user[1-9]*)
					_tpl="#hba_rules_user#"
					;;
				hba_rules_auth_method[1-9]*)
					_tpl="#hba_rules_auth_method#"
					;;
				hba_rules_order[1-9]*)
					_tpl="#hba_rules_order#"
					;;
				*)
					continue
					;;
			esac

			eval _val=\${${i}}
			[ -z "${_val}" ] && continue

			rule_name="XXX"		# concat from all field
			sed -i${sed_delimer}'' -Ees/"${_tpl}"/"${_val}"/g ${tmpfile}
		done
		cat ${tmpfile} >> ${tmp_common_yaml}
		cp -a ${tmpfile} /tmp/x.yaml
		rm -f ${tmpfile}
	fi

	cat ${tmp_common_yaml}
}
