#!/bin/sh

#WILDFLY_STARTED_MSG="WFLYSRV0025"
#WILDFLY_STOPPED_MSG="WFLYSRV0050"

execute_pre_start_scripts() {
  SCRIPTS_DIR="${JBOSS_HOME}/bin/pre-start.d"

  echo ""
  echo "----------------------------------------"
  echo "executing pre-start scripts ..."
  for f in "${SCRIPTS_DIR}"/*; do
    if [ -f "${f}" ]; then
      if [ "${f##*.}" = "sh" ]; then
        eval "${f}"
      fi
    fi
  done
  echo "pre-start scripts executed"
  echo "----------------------------------------"
  echo ""

  return 0
}

stop_wildfly() {
  echo "stopping wildfly ..."
  "${JBOSS_HOME}/bin/jboss-cli.sh" --connect --controller="${IP_ADDR}:9990" --user="admin" --password="admin123" "command=:shutdown"
  echo "waiting for wildfly shutdown ..."
}

# get current host IP address (wildfly must be bound to it)
IP_ADDR=$(hostname -i)
echo ""
echo "----------------------------------------"
echo "wildfly will bind to: $IP_ADDR"
echo "----------------------------------------"
echo ""

# execute pre-start scripts
execute_pre_start_scripts

# start wildfly in background (this way the standalone.sh script will register traps for a clean shutdown)
export LAUNCH_JBOSS_IN_BACKGROUND=true
exec "${JBOSS_HOME}/bin/standalone.sh" -c standalone.xml -Djboss.bind.address="${IP_ADDR}" -Djboss.bind.address.management="${IP_ADDR}" -Djboss.node.name="server-${IP_ADDR}"
