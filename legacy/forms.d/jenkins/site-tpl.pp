#class { 'nginx': }

include jenkins

jenkins::plugin { 'git': }
jenkins::plugin { 'ldap': }

        # git dependency:
jenkins::plugin { 'workflow-scm-step': }
jenkins::plugin { 'workflow-step-api': }
jenkins::plugin { 'git-client': }
#       jenkins::plugin { 'mailer': }
#       jenkins::plugin { 'matrix-project': }
jenkins::plugin { 'scm-api': }
jenkins::plugin { 'ssh-credentials': }
jenkins::plugin { 'script-security': }
jenkins::plugin { 'junit': }
jenkins::plugin { 'display-url-api': }
jenkins::plugin { 'matrix-project': }
jenkins::plugin { 'promoted-builds': }
jenkins::plugin { 'token-macro': }
jenkins::plugin { 'parameterized-trigger': }
jenkins::plugin { 'structs': }
jenkins::plugin { 'maven-plugin': }
jenkins::plugin { 'mailer': }
jenkins::plugin { 'conditional-buildstep': }
jenkins::plugin { 'javadoc': }
jenkins::plugin { 'run-condition': }
#       jenkins::plugin { 'conditional-buildstep': }
