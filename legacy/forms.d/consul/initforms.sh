#!/bin/sh
MYDIR="$( /usr/bin/dirname $0 )"
FORM_PATH="$( /bin/realpath ${MYDIR} )"
HELPER="consul"

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
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,1,"-",'Global Consul params:','-','','',1, "maxlen=128", "delimer", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,2,"server",'server? default is: true','1','','',1, "maxlen=30", "radio", "truefalse", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,3,"ui",'ui: default is: yes','1','','',1, "maxlen=30", "radio", "yesno", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,4,"client_addr",'client_addr: default is 0.0.0.0','0.0.0.0','','',1, "maxlen=60", "inputbox", "client_addr_autocomplete", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,5,"bind_addr",'bind_addr: default is YOUR ip address','','','',0, "maxlen=60", "inputbox", "bind_addr_autocomplete", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,6,"datacenter",'datacenter: default is: east-aws','east-aws','','',0, "maxlen=60", "inputbox", "datacenter_autocomplete", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,7,"log_level",'log_level: default is: INFO','3','','',0, "maxlen=30", "radio", "log_level_select", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,8,"node_name",'node_name: default is FQDN of machine','','','',0, "maxlen=30", "inputbox", "node_name_autocomplete", "" );

INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,100,"-",'ACL policy and settings:','-','','',1, "maxlen=128", "delimer", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,101,"acl_datacenter",'acl_datacenter: default is: east-aws','east-aws','1','',1, "maxlen=128", "inputbox", "datacenter_autocomplete", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,102,"acl_master_token",'acl_master_token: secret master token','','','',0, "maxlen=128", "password", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,103,"acl_default_policy",'acl_default_policy','1','1','',1, "maxlen=128", "radio", "allowdeny", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,104,"acl_down_policy",'acl_down_policy','1','1','',1, "maxlen=128", "radio", "allowdeny", "" );

COMMIT;
EOF

# Put version
/usr/local/bin/cbsd ${miscdir}/updatesql ${FORM_PATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_system.schema system

# yesno
/usr/local/bin/cbsd ${miscdir}/updatesql ${FORM_PATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema yesno

# truefalse
/usr/local/bin/cbsd ${miscdir}/updatesql ${FORM_PATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema truefalse

# allowdeny
/usr/local/bin/cbsd ${miscdir}/updatesql ${FORM_PATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema allowdeny

# log_level_select
/usr/local/bin/cbsd ${miscdir}/updatesql ${FORM_PATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema log_level_select

# autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${FORM_PATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema client_addr_autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${FORM_PATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema bind_addr_autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${FORM_PATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema datacenter_autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${FORM_PATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema node_name_autocomplete

# Autocomplete
${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO client_addr_autocomplete ( text, order_id ) VALUES ( '0.0.0.0', 1 );
COMMIT;
EOF

${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO bind_addr_autocomplete ( text, order_id ) VALUES ( '$ipaddress_em0', 1 );
COMMIT;
EOF

${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO datacenter_autocomplete ( text, order_id ) VALUES ( 'east-aws', 1 );
COMMIT;
EOF

${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO node_name_autocomplete ( text, order_id ) VALUES ( '$fqdn', 1 );
COMMIT;
EOF

# Put boolean for yesno
${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO yesno ( text, order_id ) VALUES ( "yes", 0 );
INSERT INTO yesno ( text, order_id ) VALUES ( "no", 1 );
COMMIT;
EOF

# Put boolean for truefalse
${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO truefalse ( text, order_id ) VALUES ( "true", 0 );
INSERT INTO truefalse ( text, order_id ) VALUES ( "false", 1 );
COMMIT;
EOF

# Put boolean for allowdeny
${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO allowdeny ( text, order_id ) VALUES ( "allow", 0 );
INSERT INTO allowdeny ( text, order_id ) VALUES ( "deny", 1 );
COMMIT;
EOF

# Put boolean for syslog_noyes
${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO log_level_select ( text, order_id ) VALUES ( "err", 4 );
INSERT INTO log_level_select ( text, order_id ) VALUES ( "warn", 3 );
INSERT INTO log_level_select ( text, order_id ) VALUES ( "info", 2 );
INSERT INTO log_level_select ( text, order_id ) VALUES ( "debug", 1 );
INSERT INTO log_level_select ( text, order_id ) VALUES ( "trace", 0 );
COMMIT;
EOF

${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO system ( helpername, version, packages, have_restart ) VALUES ( "consul", "201607", "sysutils/consul", "service consul restart" );
COMMIT;
EOF

# long description
${SQLITE3_CMD} ${FORM_PATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
UPDATE system SET longdesc='\
Consul is a distributed, highly available and data center aware tool for \
discovering and configuring services. \
';
COMMIT;
EOF
