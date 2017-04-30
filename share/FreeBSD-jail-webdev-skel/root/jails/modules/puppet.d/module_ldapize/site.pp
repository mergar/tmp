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
# class { "ldapize": }

class { "ldapize":
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
