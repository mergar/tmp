#!/bin/sh
MYDIR="$( /usr/bin/dirname $0 )"
FORM_PATH="$( /bin/realpath ${MYDIR} )"
HELPER="ldapize"

: ${distdir="/usr/local/cbsd"}
# MAIN
if [ -z "${workdir}" ]; then
	[ -z "${cbsd_workdir}" ] && . /etc/rc.conf
	[ -z "${cbsd_workdir}" ] && exit 0
	workdir="${cbsd_workdir}"
fi

set -e
. ${distdir}/cbsd.conf
. ${distdir}/tools.subr
. ${subr}
set +e

FORM_PATH="${workdir}/formfile"

[ ! -d "${FORM_PATH}" ] && err 1 "No such ${FORM_PATH}"
[ -f "${FORM_PATH}/${HELPER}.sqlite" ] && /bin/rm -f "${FORM_PATH}/${HELPER}.sqlite"

/usr/local/bin/cbsd ${miscdir}/updatesql ${FORM_PATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms.schema forms

${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;

INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,1,"ldap_host",'LDAP server','192.168.1.3','','',1, "maxlen=60", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,2,"ldap_suffix",'LDAP ldap_suffix (dc)','dc=example,dc=com','','',1, "maxlen=60", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,3,"ldap_ou",'Organization Unit (ou, e.g: ou=People)','ou=People','','',0, "maxlen=60", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,4,"ldap_bind_id",'Ldap Bind User, cn (eg: cn=admin,dc=example,dc=com)','cn=admin,dc=example,dc=com','','',0, "maxlen=60", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,3,"ldap_bind_password",'Ldap Bind password for Bind User','password','','',0, "maxlen=60", "inputbox", "", "" );

COMMIT;
EOF

# Put version
/usr/local/bin/cbsd ${miscdir}/updatesql ${FORM_PATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_system.schema system

${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO system ( helpername, version, packages, have_restart ) VALUES ( "ldapize", "201607", "pam_mkhomedir nss_ldap pam_ldap", "" );
COMMIT;
EOF

# long description
${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
UPDATE system SET longdesc='\
Ldapize jail \
';
COMMIT;
EOF
