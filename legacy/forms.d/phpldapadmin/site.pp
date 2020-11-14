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

	for i in ${packages}; do
		[ "${i}" = "0" ] && continue
		cat << EOF
package { "${i}": ensure => "installed" }
EOF
	done

	cat <<EOF

openldap::server { "openldap":
EOF

	for i in ${param}; do
		eval _T=\${${i}}
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
