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
Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin" }
\$provider = "pkgng"
EOF

	cat <<EOF
#	class { "redis::install": }

class { "redis":
EOF

	for i in ${param}; do
		_T=""
		eval _T=\${${i}}

		case "$i" in
			-)
				continue
				;;
			slaveof|requirepass)
				[ -z "${_T}" ] && _T="" && continue
				;;
		esac

		cat <<EOF
 $i => "${_T}",
EOF
done

	cat <<EOF
}
EOF

}

generate_hieradata()
{
}
