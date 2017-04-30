#!/bin/sh

ver="12.0"
myfile="pkg_bootstrap-${ver}.sh"
mydir="/usr/home/web/olevole.ru"

dst="${mydir}/${myfile}"

mypkg=$( ls -1 /usr/obj/usr/jails/src/src_12/src/repo/FreeBSD:12:amd64/latest | grep -e "^FreeBSD\-" |sed "s:-${ver}.: :g" |awk '{printf $1" "}' )

if [ -z "${mypkg}" ]; then
	echo "No packages"
	exit 0
fi

cat > ${dst} <<EOF
#!/bin/sh

pkg update -f

[ ! -d /usr/local/etc/pkg/repos ] && mkdir -p /usr/local/etc/pkg/repos

cat > /usr/local/etc/pkg/repos/convectix.conf <<FEOF
FreeBSD-base: {
	url: "http://pkg.convectix.com/\\\${ABI}/latest",
	mirror_type: "none",
	enabled: yes
}
FEOF

pkg update

mypkg="${mypkg}"

myarg=""
count=0
busy=0

for i in \$mypkg; do
	busy=1
	myarg="\${myarg} \${i}"
	count=\$(( count + 1 ))
	if [ \$count -gt 30 ]; then
		echo "Install: \$myarg"
		pkg install -y \${myarg}
		myarg=""
		count=0
		busy=0
	fi
done

[ \$busy -ne 0 ] && pkg install -y \${myarg}
pkg clean -y -a
EOF


chmod +x ${dst}

