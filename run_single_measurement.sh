#!/bin/bash

WORKSPACE="$HOME/workspace"

CUSTOMER_CORE_HOME="$WORKSPACE/LakesideMutual/customer-core"
CUSTOMER_MANAGEMENT_HOME="$WORKSPACE/LakesideMutual/customer-management-backend"
CUSTOMER_SELF_SERVICE_HOME="$WORKSPACE/LakesideMutual/customer-self-service-backend"
POLICY_MANAGEMENT_HOME="$WORKSPACE/LakesideMutual/policy-management-backend"

JMETER_CONFIG="$WORKSPACE/LakesideMutual-energy-benchmarking/jmeter-LakesideMutual-SOA-server.jmx"

JOULARJX_CONFIG="$WORKSPACE/LakesideMutual-energy-benchmarking/joularjx_LakesideMutual-SOA_config.properties"

APP_RUN_IDENTIFIER="$(date +%Y-%m-%d_%H-%M-%S)"
OUTPUT_FOLDER="$WORKSPACE/LakesideMutual-energy-benchmarking/out/$APP_RUN_IDENTIFIER"

JAVA_OPTS="-Xmx2g -Xms2g -XX:ActiveProcessorCount=2 -javaagent:$WORKSPACE/joularjx/target/joularjx-3.0.1.jar -Djoularjx.config=$JOULARJX_CONFIG -Dspring.profiles.active=default,test"

CUSTOMER_CORE_PORT="8110"
CUSTOMER_MANAGEMENT_PORT="8100"
CUSTOMER_SELF_SERVICE_PORT="8080"
POLICY_MANAGEMENT_PORT="8090"

  CUSTOMER_CORE_URL="localhost:$CUSTOMER_CORE_PORT"
CUSTOMER_MANAGEMENT_URL="localhost:$CUSTOMER_MANAGEMENT_PORT"
CUSTOMER_SELF_SERVICE_URL="localhost:$CUSTOMER_SELF_SERVICE_PORT"
POLICY_MANAGEMENT_URL="localhost:$POLICY_MANAGEMENT_PORT"

virtual_threads="false"

# Parse command line arguments
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    --spring-boot-version)
    spring_boot_version="${2#*=}"
    shift
    ;;
    --jvm-version)
    jvm_version="${2#*=}"
    shift
    ;;
    --java-version)
    java_version="${2#*=}"
    shift
    ;;
    --webserver)
    webserver="${2#*=}"
    shift
    ;;
    --virtual-threads)
    virtual_threads="${2#*=}"
    shift
    ;;
    *)
    echo "ERROR: Invalid argument: $1"
    exit 1
    ;;
  esac
  shift
done

if [ -n "$webserver" ] && [[ $spring_boot_version =~ ^2.* ]]; then
  echo "ERROR: Both webserver and Spring Boot 2 cannot be set at the same time."
  exit 1
fi

if [ -z "$spring_boot_version" ]; then
  echo "ERROR: Spring Boot version is required."
  exit 1
fi

if [ -z "$jvm_version" ]; then
  echo "ERROR: JVM version is required."
  exit 1
fi

if [ -z "$java_version" ]; then
  echo "ERROR: Java version (for compilation) is required."
  exit 1
fi

create_output_folders() {
  mkdir -p "$OUTPUT_FOLDER/log"
}

switch_application_branch() {
  echo "+================================+"
  echo "| Switching Application Branch"
  echo "+================================+"

  # Select the branch according to the Spring Boot version
  if [[ $spring_boot_version =~ ^3.* ]]; then
    switch_branch_command_customer_core="git -C $CUSTOMER_CORE_HOME checkout -f spring-boot-v3.x.x-$webserver"
    switch_branch_command_customer_management="git -C $CUSTOMER_MANAGEMENT_HOME checkout -f spring-boot-v3.x.x-$webserver"
    switch_branch_command_customer_self_service="git -C $CUSTOMER_SELF_SERVICE_HOME checkout -f spring-boot-v3.x.x-$webserver"
    switch_branch_command_policy_management="git -C $POLICY_MANAGEMENT_HOME checkout -f spring-boot-v3.x.x-$webserver"
  else
    echo "ERROR: Spring Boot version must start with 3."
    return 1
  fi
  
  echo "$switch_branch_command_customer_core"
  eval "$switch_branch_command_customer_core"

  echo "$switch_branch_command_customer_management"
  eval "$switch_branch_command_customer_management"

  echo "$switch_branch_command_customer_self_service"
  eval "$switch_branch_command_customer_self_service"

  echo "$switch_branch_command_policy_management"
  eval "$switch_branch_command_policy_management"
}

change_spring_boot_version() {
  echo "+================================+"
  echo "| Changing Spring Boot Version"
  echo "+================================+"
  change_spring_boot_version_command_customer_core="$CUSTOMER_CORE_HOME/mvnw -f $CUSTOMER_CORE_HOME/pom.xml versions:update-parent -DparentVersion=[$spring_boot_version] versions:set-property -Dproperty="java.version" -DnewVersion=$java_version -DgenerateBackupPoms=false"
  change_spring_boot_version_command_customer_management="$CUSTOMER_MANAGEMENT_HOME/mvnw -f $CUSTOMER_MANAGEMENT_HOME/pom.xml versions:update-parent -DparentVersion=[$spring_boot_version] versions:set-property -Dproperty="java.version" -DnewVersion=$java_version -DgenerateBackupPoms=false"
  change_spring_boot_version_command_customer_self_service="$CUSTOMER_SELF_SERVICE_HOME/mvnw -f $CUSTOMER_SELF_SERVICE_HOME/pom.xml versions:update-parent -DparentVersion=[$spring_boot_version] versions:set-property -Dproperty="java.version" -DnewVersion=$java_version -DgenerateBackupPoms=false"
  change_spring_boot_version_command_policy_management="$POLICY_MANAGEMENT_HOME/mvnw -f $POLICY_MANAGEMENT_HOME/pom.xml versions:update-parent -DparentVersion=[$spring_boot_version] versions:set-property -Dproperty="java.version" -DnewVersion=$java_version -DgenerateBackupPoms=false"

  echo "$change_spring_boot_version_command_customer_core"
  eval "cd $CUSTOMER_CORE_HOME; $change_spring_boot_version_command_customer_core"

  echo "$change_spring_boot_version_command_customer_management"
  eval "cd $CUSTOMER_MANAGEMENT_HOME; $change_spring_boot_version_command_customer_management"

  echo "$change_spring_boot_version_command_customer_self_service"
  eval "cd $CUSTOMER_SELF_SERVICE_HOME; $change_spring_boot_version_command_customer_self_service"

  echo "$change_spring_boot_version_command_policy_management"
  eval "cd $POLICY_MANAGEMENT_HOME; $change_spring_boot_version_command_policy_management"
}

change_jvm_version() {
  echo "+================================+"
  echo "| Changing JVM Version"
  echo "+================================+"
  change_jvm_version_command="sdk use java $jvm_version"
  echo "$change_jvm_version_command"
  eval "$change_jvm_version_command"

  verify_jvm_version=$(java -version 2>&1 | awk -F ' ' '/Runtime/ {print $4}')

  # Verify the JVM version:
  if [[ $verify_jvm_version =~ ^$jvm_version* ]]; then
    echo "ERROR: JVM version $jvm_version is not set correctly. Current JVM version is $verify_jvm_version."
    return 1
  fi

}

build_application_component() {
    local build_cmd="$1"
    local build_output_file="$2"
    local app_home="$3"

    app_build_command="$build_cmd > $build_output_file 2>&1"
    echo "$app_build_command"

    eval "cd $app_home; $app_build_command"
    if [ $? -ne 0 ]; then
      echo "ERROR: Build failed for application. Check $build_output_file for details."
      return 1
    fi
}

build_application() {
  echo "+================================+"
  echo "| Building Application"
  echo "+================================+"
  build_output_file_customer_core="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-core-build.log"
  build_output_file_customer_management="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-management-build.log"
  build_output_file_customer_self_service="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-self-service-build.log"
  build_output_file_policy_management="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-policy-management-build.log"

  BUILD_CMD_CUSTOMER_CORE="$CUSTOMER_CORE_HOME/mvnw -f $CUSTOMER_CORE_HOME/pom.xml clean package -Dmaven.test.skip -Dmaven.compiler.release=$java_version"
  BUILD_CMD_CUSTOMER_MANAGEMENT="$CUSTOMER_MANAGEMENT_HOME/mvnw -f $CUSTOMER_MANAGEMENT_HOME/pom.xml clean package -Dmaven.test.skip -Dmaven.compiler.release=$java_version"
  BUILD_CMD_CUSTOMER_SELF_SERVICE="$CUSTOMER_SELF_SERVICE_HOME/mvnw -f $CUSTOMER_SELF_SERVICE_HOME/pom.xml clean package -Dmaven.test.skip -Dmaven.compiler.release=$java_version"
  BUILD_CMD_POLICY_MANAGEMENT="$POLICY_MANAGEMENT_HOME/mvnw -f $POLICY_MANAGEMENT_HOME/pom.xml clean package -Dmaven.test.skip -Dmaven.compiler.release=$java_version"

  build_application_component "$BUILD_CMD_CUSTOMER_CORE" "$build_output_file_customer_core" "$CUSTOMER_CORE_HOME"
  build_application_component "$BUILD_CMD_CUSTOMER_MANAGEMENT" "$build_output_file_customer_management" "$CUSTOMER_MANAGEMENT_HOME"
  build_application_component "$BUILD_CMD_CUSTOMER_SELF_SERVICE" "$build_output_file_customer_self_service" "$CUSTOMER_SELF_SERVICE_HOME"
  build_application_component "$BUILD_CMD_POLICY_MANAGEMENT" "$build_output_file_policy_management" "$POLICY_MANAGEMENT_HOME"
}

print_app_info() {
  echo "+================================+"
  echo "| Configuration Properties"
  echo "+================================+"
  echo "JVM: $jvm_version"
  echo "Java: $java_version"
  echo "Spring Boot: $spring_boot_version"
  echo "Webserver: $webserver"
  echo "Customer-Core Home: $CUSTOMER_CORE_HOME"
  echo "Customer-Management-Backend Home: $CUSTOMER_MANAGEMENT_HOME"
  echo "Customer-Self-Service-Backend Home: $CUSTOMER_SELF_SERVICE_HOME"
  echo "Policy-Management-Backend Home: $POLICY_MANAGEMENT_HOME"
  echo "JMeter Config: $JMETER_CONFIG"
  echo "Output Folder: $OUTPUT_FOLDER"
  echo "App Run Identifier: $APP_RUN_IDENTIFIER"
}

check_if_port_is_open() {
  local app_port="$1"

  if lsof -Pi :$app_port -sTCP:LISTEN -t >/dev/null; then
    echo "ERROR Port $app_port is already in use. Please stop the application running on this port."
    return 1
  fi
}

check_if_ports_are_open() {
  check_if_port_is_open "$CUSTOMER_CORE_PORT"
  check_if_port_is_open "$CUSTOMER_MANAGEMENT_PORT"
  check_if_port_is_open "$CUSTOMER_SELF_SERVICE_PORT"
  check_if_port_is_open "$POLICY_MANAGEMENT_PORT"
}

start_mysql_container() {
  echo "+================================+"
  echo "| Starting MySQL Container"
  echo "+================================+"
  mysql_docker_compose_build_command="docker-compose -f docker-compose.yml build"
  mysql_docker_compose_up_command="docker-compose -f docker-compose.yml up -d"

  echo "$mysql_docker_compose_build_command"
  eval "$mysql_docker_compose_build_command"

  echo "$mysql_docker_compose_up_command"
  eval "$mysql_docker_compose_up_command"

  # Wait until the container is ready
  echo "Waiting for MySQL container to start and initialize..."
  sleep 30

  # give it a few more seconds to be ready
  sleep 5

  extract_container_id_command="docker-compose ps -q mysql"
  db_container_id=$(eval "$extract_container_id_command")

  # 2000 is the number of expected pets
  verify_import_command="docker exec -i $db_container_id mysql -u root -pcustomercore -e \"USE customercore; SELECT count(*) FROM customers;\" | grep 1001"
  echo "$verify_import_command"
  eval "$verify_import_command"
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to verify import. Check the MySQL container logs for details."
    return 1
  fi

  echo "MySQL container is ready."
}

start_application() {
  echo "+================================+"
  echo "| Starting Application"
  echo "+================================+"
  run_output_file_customer_core="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-core-run.log"
  run_output_file_customer_management="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-management-run.log"
  run_output_file_customer_self_service="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-self-service-run.log"
  run_output_file_policy_management="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-policy-management-run.log"

  RUN_CMD_CUSTOMER_CORE="java $JAVA_OPTS -Dspring.threads.virtual.enabled=$virtual_threads -jar $CUSTOMER_CORE_HOME/target/*.jar"
  RUN_CMD_CUSTOMER_MANAGEMENT="java $JAVA_OPTS -Dspring.threads.virtual.enabled=$virtual_threads -jar $CUSTOMER_MANAGEMENT_HOME/target/*.jar"
  RUN_CMD_CUSTOMER_SELF_SERVICE="java $JAVA_OPTS -Dspring.threads.virtual.enabled=$virtual_threads -jar $CUSTOMER_SELF_SERVICE_HOME/target/*.jar"
  RUN_CMD_POLICY_MANAGEMENT="java $JAVA_OPTS -Dspring.threads.virtual.enabled=$virtual_threads -jar $POLICY_MANAGEMENT_HOME/target/*.jar"

  customer_core_run_command="$RUN_CMD_CUSTOMER_CORE > $run_output_file_customer_core 2>&1 &"
  echo "$customer_core_run_command"
  eval "$customer_core_run_command"

  CUSTOMER_CORE_PID=$!
  sleep 2

  if ! ps -p "$CUSTOMER_CORE_PID" > /dev/null; then
    echo "ERROR: Run failed for application. Check $run_output_file_customer_core for details."
    return 1
  fi


  customer_management_run_command="$RUN_CMD_CUSTOMER_MANAGEMENT > $run_output_file_customer_management 2>&1 &"
  echo "$customer_management_run_command"
  eval "$customer_management_run_command"

  CUSTOMER_MANAGEMENT_PID=$!
  sleep 2

  if ! ps -p "$CUSTOMER_MANAGEMENT_PID" > /dev/null; then
    echo "ERROR: Run failed for application. Check $run_output_file_customer_management for details."
    return 1
  fi


  customer_self_service_run_command="$RUN_CMD_CUSTOMER_SELF_SERVICE > $run_output_file_customer_self_service 2>&1 &"
  echo "$customer_management_run_command"
  eval "$customer_management_run_command"

  CUSTOMER_SELF_SERVICE_PID=$!
  sleep 2

  if ! ps -p "$CUSTOMER_SELF_SERVICE_PID" > /dev/null; then
    echo "ERROR: Run failed for application. Check $run_output_file_customer_self_service for details."
    return 1
  fi


  policy_management_run_command="$RUN_CMD_POLICY_MANAGEMENT > $run_output_file_policy_management 2>&1 &"
  echo "$policy_management_run_command"
  eval "$policy_management_run_command"

  POLICY_MANAGEMENT_PID=$!
  sleep 2

  if ! ps -p "$POLICY_MANAGEMENT_PID" > /dev/null; then
    echo "ERROR: Run failed for application. Check $run_output_file_policy_management for details."
    return 1
  fi
}

check_service_initial_request() {
  local timeout="$1"
  local end_time="$2"
  local app_url="$3"
  local app_pid="$4"

  # Wait until we get a 200 response
  while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://$app_url)" != "200" ]]; do
    sleep .00001

    # Check if the timeout has been reached
    if [ $SECONDS -ge $end_time ]; then
      echo "ERROR: Application with PID $app_pid did not respond within $timeout seconds (timeout)."
      return 1
    fi
  done

  echo "Application with PID $app_pid successfully started at $(date)."
}

check_application_initial_request() {
  timeout=45
  end_time=$((SECONDS + timeout))

  check_service_initial_request "$timeout" "$end_time" "$CUSTOMER_CORE_URL" "$CUSTOMER_CORE_PID"
  check_service_initial_request "$timeout" "$end_time" "$CUSTOMER_MANAGEMENT_URL" "$CUSTOMER_MANAGEMENT_PID"
  check_service_initial_request "$timeout" "$end_time" "$CUSTOMER_SELF_SERVICE_URL" "$CUSTOMER_SELF_SERVICE_PID"
  check_service_initial_request "$timeout" "$end_time" "$POLICY_MANAGEMENT_URL" "$POLICY_MANAGEMENT_PID"
}

stop_service() {
  local app_kill_command="$1"
  local app_pid="$2"

  echo "$app_kill_command"
  eval "$app_kill_command"
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to stop application with PID $app_pid."
    return 1
  fi
}

stop_application() {
  echo "+================================+"
  echo "| Stopping Application"
  echo "+================================+"
  stop_service "kill -15 $CUSTOMER_CORE_PID && sleep 10" "$CUSTOMER_CORE_PID"
  stop_service "kill -15 $CUSTOMER_MANAGEMENT_PID && sleep 10" "$CUSTOMER_MANAGEMENT_PID"
  stop_service "kill -15 $CUSTOMER_SELF_SERVICE_PID && sleep 10" "$CUSTOMER_SELF_SERVICE_PID"
  stop_service "kill -15 $POLICY_MANAGEMENT_PID && sleep 10" "$POLICY_MANAGEMENT_PID"
}

stop_mysql_container() {
  echo "+================================+"
  echo "| Stopping MySQL Container"
  echo "+================================+"
  mysql_stop_command="docker-compose -f docker-compose.yml down -v"
  echo "$mysql_stop_command"
  eval "$mysql_stop_command"
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to stop MySQL container."
    return 1
  fi
}

start_jmeter_service() {
  local jmeter_cmd="$1"
  local jmeter_output_file="$2"

  jmeter_command="$jmeter_cmd > $jmeter_output_file 2>&1"
  echo "$jmeter_command"

  eval "$jmeter_command"
  if [ $? -ne 0 ]; then
    echo "ERROR: JMeter run failed. Check $jmeter_output_file for details."
    return 1
  fi
}

start_jmeter() {
  echo "+================================+"
  echo "| Starting JMeter"
  echo "+================================+"
  jmeter_output_file_customer_core="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-core-jmeter.log"
  jmeter_output_file_customer_management="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-management-jmeter.log"
  jmeter_output_file_customer_self_service="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-self-service-jmeter.log"
  jmeter_output_file_policy_management="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-policy-management-jmeter.log"

  JMETER_CMD_CUSTOMER_CORE="jmeter -n -t $JMETER_CONFIG -l $OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-core-jmeter.jtl -j $OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-core-jmeter.log"
  JMETER_CMD_CUSTOMER_MANAGEMENT="jmeter -n -t $JMETER_CONFIG -l $OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-management-jmeter.jtl -j $OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-management-jmeter.log"
  JMETER_CMD_CUSTOMER_SELF_SERVICE="jmeter -n -t $JMETER_CONFIG -l $OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-self-service-jmeter.jtl -j $OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-self-service-jmeter.log"
  JMETER_CMD_POLICY_MANAGEMENT="jmeter -n -t $JMETER_CONFIG -l $OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-policy-management-jmeter.jtl -j $OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-policy-management-jmeter.log"

  start_jmeter_service "$JMETER_CMD_CUSTOMER_CORE" "$jmeter_output_file_customer_core"
  start_jmeter_service "$JMETER_CMD_CUSTOMER_MANAGEMENT" "$jmeter_output_file_customer_management"
  start_jmeter_service "$JMETER_CMD_CUSTOMER_SELF_SERVICE" "$jmeter_output_file_customer_self_service"
  start_jmeter_service "$JMETER_CMD_POLICY_MANAGEMENT" "$jmeter_output_file_policy_management"
}

save_energy_measurement() {
  echo "+================================+"
  echo "| Saving Energy Measurement"
  echo "+================================+"

  save_energy_measurement_command_customer_core="find $CUSTOMER_CORE_HOME/joularjx-result -name '*.csv' | xargs -I '{}' mv '{}' $OUTPUT_FOLDER/"
  echo "$save_energy_measurement_command_customer_core"
  eval "$save_energy_measurement_command_customer_core"

  save_energy_measurement_command_customer_management="find $CUSTOMER_MANAGEMENT_HOME/joularjx-result -name '*.csv' | xargs -I '{}' mv '{}' $OUTPUT_FOLDER/"
  echo "$save_energy_measurement_command_customer_management"
  eval "$save_energy_measurement_command_customer_management"

  save_energy_measurement_command_customer_self_service="find $CUSTOMER_SELF_SERVICE_HOME/joularjx-result -name '*.csv' | xargs -I '{}' mv '{}' $OUTPUT_FOLDER/"
  echo "$save_energy_measurement_command_customer_self_service"
  eval "$save_energy_measurement_command_customer_self_service"

  save_energy_measurement_command_policy_management="find $POLICY_MANAGEMENT_HOME/joularjx-result -name '*.csv' | xargs -I '{}' mv '{}' $OUTPUT_FOLDER/"
  echo "$save_energy_measurement_command_policy_management"
  eval "$save_energy_measurement_command_policy_management"
}

extract_run_properties() {
  echo "+================================+"
  echo "| Extracting Run Properties"
  echo "+================================+"

  # used_jvm_version=$(java -XshowSettings:properties -version 2>&1 | grep "java.runtime.version" | sed -e 's/^[^=]*= *//' -e 's/ *$//')
  # used_jvm_vendor=$(java -XshowSettings:properties -version 2>&1 | grep "java.vendor " | sed -e 's/^[^=]*= *//' -e 's/ *$//')

  echo "JVM: $jvm_version"

  used_java_version_customer_core=$(javap -verbose $CUSTOMER_CORE_HOME/target/classes/com/lakesidemutual/customercore/CustomerCoreApplication.class | grep "major version" | awk '{print $3 - 44}')
  used_java_version_customer_management=$(javap -verbose $CUSTOMER_MANAGEMENT_HOME/target/classes/com/lakesidemutual/customermanagement/CustomerManagementApplication.class | grep "major version" | awk '{print $3 - 44}')
  used_java_version_customer_self_service=$(javap -verbose $CUSTOMER_SELF_SERVICE_HOME/target/classes/com/lakesidemutual/customerselfservice/CustomerSelfServiceApplication.class | grep "major version" | awk '{print $3 - 44}')
  used_java_version_policy_management=$(javap -verbose $POLICY_MANAGEMENT_HOME/target/classes/com/lakesidemutual/policymanagement/PolicyManagementApplication.class | grep "major version" | awk '{print $3 - 44}')

  echo "Java Version Customer-Core: $used_java_version_customer_core"
  echo "Java Version Customer-Management-Backend: $used_java_version_customer_management"
  echo "Java Version Customer-Self-Service-Backend: $used_java_version_customer_self_service"
  echo "Java Version Policy-Management-Backend: $used_java_version_policy_management"

  spring_versions_customer_core=($(grep 'Running with' $run_output_file_customer_core | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/v//'))
  spring_versions_customer_management=($(grep 'Running with' $run_output_file_customer_management | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/v//'))
  spring_versions_customer_self_service=($(grep 'Running with' $run_output_file_customer_self_service | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/v//'))
  spring_versions_policy_management=($(grep 'Running with' $run_output_file_policy_management | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/v//'))

  # Output the variables to check
  echo "Spring Boot Version Customer-Core: ${spring_versions_customer_core[0]}"
  echo "Spring Version Customer-Core: ${spring_versions_customer_core[1]}"
  echo "Spring Boot Version Customer-Management-Backend: ${spring_versions_customer_management[0]}"
  echo "Spring Version Customer-Management-Backend: ${spring_versions_customer_management[1]}"
  echo "Spring Boot Version Customer-Self-Service-Backend: ${spring_versions_customer_self_service[0]}"
  echo "Spring Version Customer-Self-Service-Backend: ${spring_versions_customer_self_service[1]}"
  echo "Spring Boot Version Policy-Management-Backend: ${spring_versions_policy_management[0]}"
  echo "Spring Version Policy-Management-Backend: ${spring_versions_policy_management[1]}"

  profiles_customer_core=($(grep 'profiles are active' $run_output_file_customer_core | grep -oE '"[^"]+"' | sed 's/"//g' | tr '\n' '+' | sed 's/\+$/\n/'))
  profiles_customer_management=($(grep 'profiles are active' $run_output_file_customer_management | grep -oE '"[^"]+"' | sed 's/"//g' | tr '\n' '+' | sed 's/\+$/\n/'))
  profiles_customer_self_service=($(grep 'profiles are active' $run_output_file_customer_self_service | grep -oE '"[^"]+"' | sed 's/"//g' | tr '\n' '+' | sed 's/\+$/\n/'))
  profiles_policy_management=($(grep 'profiles are active' $run_output_file_policy_management | grep -oE '"[^"]+"' | sed 's/"//g' | tr '\n' '+' | sed 's/\+$/\n/'))

  echo "Profiles Customer-Core: $profiles_customer_core"
  echo "Profiles Customer-Management-Backend: $profiles_customer_management"
  echo "Profiles Customer-Self-Service-Backend: $profiles_customer_self_service"
  echo "Profiles Policy-Management-Backend: $profiles_policy_management"

  joules_customer_core=($(grep 'Program consumed' $run_output_file_customer_core | grep -oE '[0-9]+(\.[0-9]+)? joules' | sed 's/ joules//'))
  joules_customer_management=($(grep 'Program consumed' $run_output_file_customer_management | grep -oE '[0-9]+(\.[0-9]+)? joules' | sed 's/ joules//'))
  joules_customer_self_service=($(grep 'Program consumed' $run_output_file_customer_self_service | grep -oE '[0-9]+(\.[0-9]+)? joules' | sed 's/ joules//'))
  joules_policy_management=($(grep 'Program consumed' $run_output_file_policy_management | grep -oE '[0-9]+(\.[0-9]+)? joules' | sed 's/ joules//'))

  echo "Joules Customer-Core: $joules_customer_core"
  echo "Joules Customer-Management-Backend: $joules_customer_management"
  echo "Joules Customer-Self-Service-Backend: $joules_customer_self_service"
  echo "Joules Policy-Management-Backend: $joules_policy_management"

  jmetertime_customer_core=$(grep "summary =" "$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-core-jmeter.log" | tail -n 1 | awk -F'=' '{print $2}' | sed -E 's/.*in ([0-9]{2}:[0-9]{2}:[0-9]{2}).*/\1/')
  jmetertime_customer_management=$(grep "summary =" "$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-management-jmeter.log" | tail -n 1 | awk -F'=' '{print $2}' | sed -E 's/.*in ([0-9]{2}:[0-9]{2}:[0-9]{2}).*/\1/')
  jmetertime_customer_self_service=$(grep "summary =" "$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-self-service-jmeter.log" | tail -n 1 | awk -F'=' '{print $2}' | sed -E 's/.*in ([0-9]{2}:[0-9]{2}:[0-9]{2}).*/\1/')
  jmetertime_policy_management=$(grep "summary =" "$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-policy-management-jmeter.log" | tail -n 1 | awk -F'=' '{print $2}' | sed -E 's/.*in ([0-9]{2}:[0-9]{2}:[0-9]{2}).*/\1/')

  echo "JMeter Customer-Core: $jmetertime_customer_core"
  echo "JMeter Customer-Management-Backend: $jmetertime_customer_management"
  echo "JMeter Customer-Self-Service-Backend: $jmetertime_customer_self_service"
  echo "JMeter Policy-Management-Backend: $jmetertime_policy_management"

  jmeter_errors_customer_core=$(grep "summary =" "$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-core-jmeter.log" | tail -n 1 | awk -F'Err:' '{gsub(/^[ \t]+/, "", $2); split($2, a, " "); print a[1]}')
  jmeter_errors_customer_management=$(grep "summary =" "$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-management-jmeter.log" | tail -n 1 | awk -F'Err:' '{gsub(/^[ \t]+/, "", $2); split($2, a, " "); print a[1]}')
  jmeter_errors_customer_self_service=$(grep "summary =" "$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-self-service-jmeter.log" | tail -n 1 | awk -F'Err:' '{gsub(/^[ \t]+/, "", $2); split($2, a, " "); print a[1]}')
  jmeter_errors_policy_management=$(grep "summary =" "$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-policy-management-jmeter.log" | tail -n 1 | awk -F'Err:' '{gsub(/^[ \t]+/, "", $2); split($2, a, " "); print a[1]}')

  if [ "$jmeter_errors_customer_core" != "0" ]; then
    echo "ERROR: JMeter run failed with errors. Check $OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-core-jmeter.log for details."
    exit 1
  fi

  if [ "$jmeter_errors_customer_management" != "0" ]; then
    echo "ERROR: JMeter run failed with errors. Check $OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-management-jmeter.log for details."
    exit 1
  fi

  if [ "$jmeter_errors_customer_self_service" != "0" ]; then
    echo "ERROR: JMeter run failed with errors. Check $OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-customer-self-service-jmeter.log for details."
    exit 1
  fi

  if [ "$jmeter_errors_policy_management" != "0" ]; then
    echo "ERROR: JMeter run failed with errors. Check $OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-policy-management-jmeter.log for details."
    exit 1
  fi

  results_output_file="$OUTPUT_FOLDER/results.txt"

  > "$results_output_file"
  
  if [ "$virtual_threads" == "true" ]; then
    echo "JVM: $jvm_version (Virtual Threads)" >> "$results_output_file"
  else
    echo "JVM: $jvm_version" >> "$results_output_file"
  fi

  echo "Java Version Customer-Core: $used_java_version_customer_core" >> "$results_output_file"
  echo "Java Version Customer-Management-Backend: $used_java_version_customer_management" >> "$results_output_file"
  echo "Java Version Customer-Self-Service-Backend: $used_java_version_customer_self_service" >> "$results_output_file"
  echo "Java Version Policy-Management-Backend: $used_java_version_policy_management" >> "$results_output_file"

  echo "Spring Boot Version Customer-Core: ${spring_versions_customer_core[0]}" >> "$results_output_file"
  echo "Spring Version Customer-Core: ${spring_versions_customer_core[1]}" >> "$results_output_file"
  echo "Spring Boot Version Customer-Management-Backend: ${spring_versions_customer_management[0]}" >> "$results_output_file"
  echo "Spring Version Customer-Management-Backend: ${spring_versions_customer_management[1]}" >> "$results_output_file"
  echo "Spring Boot Version Customer-Self-Service-Backend: ${spring_versions_customer_self_service[0]}" >> "$results_output_file"
  echo "Spring Version Customer-Self-Service-Backend: ${spring_versions_customer_self_service[1]}" >> "$results_output_file"
  echo "Spring Boot Version Policy-Management-Backend: ${spring_versions_policy_management[0]}" >> "$results_output_file"
  echo "Spring Version Policy-Management-Backend: ${spring_versions_policy_management[1]}" >> "$results_output_file"

  echo "Webserver: $webserver" >> "$results_output_file"

  echo "Profiles Customer-Core: $profiles_customer_core" >> "$results_output_file"
  echo "Profiles Customer-Management-Backend: $profiles_customer_management" >> "$results_output_file"
  echo "Profiles Customer-Self-Service-Backend: $profiles_customer_self_service" >> "$results_output_file"
  echo "Profiles Policy-Management-Backend: $profiles_policy_management" >> "$results_output_file"

  echo "Joules Customer-Core: $joules_customer_core" >> "$results_output_file"
  echo "Joules Customer-Management-Backend: $joules_customer_management" >> "$results_output_file"
  echo "Joules Customer-Self-Service-Backend: $joules_customer_self_service" >> "$results_output_file"
  echo "Joules Policy-Management-Backend: $joules_policy_management" >> "$results_output_file"

  echo "JMeter Customer-Core: $jmetertime_customer_core" >> "$results_output_file"
  echo "JMeter Customer-Management-Backend: $jmetertime_customer_management" >> "$results_output_file"
  echo "JMeter Customer-Self-Service-Backend: $jmetertime_customer_self_service" >> "$results_output_file"
  echo "JMeter Policy-Management-Backend: $jmetertime_policy_management" >> "$results_output_file"

  # Extract the energy measurements, excluding some methods that we are not interested in
  find_command="find $OUTPUT_FOLDER/ -name '*filtered-methods-energy.csv' | xargs cat | grep -v 'CGLIB\$STATICHOOK' | grep -v '0.0000' | grep -v 'equals' | grep -v 'invoke' | grep -v 'init' | grep -v 'setCallbacks'| grep -v 'isFrozen' | grep -v 'addAdvisor' | grep -v 'getIndex' | grep -v 'getTargetClass' | sed 's/com.lakesidemutual.customercore.interfaces.//' | sed 's/,/: /' | sort"
  eval "$find_command >> $results_output_file"
  find_command="find $OUTPUT_FOLDER/ -name '*filtered-methods-energy.csv' | xargs cat | grep -v 'CGLIB\$STATICHOOK' | grep -v '0.0000' | grep -v 'equals' | grep -v 'invoke' | grep -v 'init' | grep -v 'setCallbacks'| grep -v 'isFrozen' | grep -v 'addAdvisor' | grep -v 'getIndex' | grep -v 'getTargetClass' | sed 's/com.lakesidemutual.customermanagement.interfaces.//' | sed 's/,/: /' | sort"
  eval "$find_command >> $results_output_file"
  find_command="find $OUTPUT_FOLDER/ -name '*filtered-methods-energy.csv' | xargs cat | grep -v 'CGLIB\$STATICHOOK' | grep -v '0.0000' | grep -v 'equals' | grep -v 'invoke' | grep -v 'init' | grep -v 'setCallbacks'| grep -v 'isFrozen' | grep -v 'addAdvisor' | grep -v 'getIndex' | grep -v 'getTargetClass' | sed 's/com.lakesidemutual.customerselfservice.interfaces.//' | sed 's/,/: /' | sort"
  eval "$find_command >> $results_output_file"
  find_command="find $OUTPUT_FOLDER/ -name '*filtered-methods-energy.csv' | xargs cat | grep -v 'CGLIB\$STATICHOOK' | grep -v '0.0000' | grep -v 'equals' | grep -v 'invoke' | grep -v 'init' | grep -v 'setCallbacks'| grep -v 'isFrozen' | grep -v 'addAdvisor' | grep -v 'getIndex' | grep -v 'getTargetClass' | sed 's/com.lakesidemutual.policymanagement.interfaces.//' | sed 's/,/: /' | sort"
  eval "$find_command >> $results_output_file"

  mv "$OUTPUT_FOLDER" "$OUTPUT_FOLDER-Java-$jvm_version-Spring-Boot-$used_spring_boot_version"
}

cleanup() {
  echo "+================================+"
  echo "| Cleaning up"
  echo "+================================"
  cleanup_command="rm -rf $CUSTOMER_CORE_HOME/joularjx-result && rm -rf $CUSTOMER_MANAGEMENT_HOME/joularjx-result && rm -rf $CUSTOMER_SELF_SERVICE_HOME/joularjx-result && rm -rf $POLICY_MANAGEMENT_HOME/joularjx-result"
  echo "$cleanup_command"
  eval "$cleanup_command"
}

create_output_folders

print_app_info

# switch_application_branch || { exit 1; }

change_spring_boot_version || { exit 1; }

#change_jvm_version || { exit 1; }

build_application || { exit 1; }

check_if_ports_are_open || { exit 1; }

start_mysql_container || { stop_mysql_container && exit 1; }

start_application || { stop_mysql_container && exit 1; }

check_application_initial_request || { stop_mysql_container &&  exit 1; }

start_jmeter || { stop_application && stop_mysql_container && exit 1; }

stop_application || { stop_mysql_container && exit 1; }

stop_mysql_container || { exit 1; }

save_energy_measurement || { exit 1; }

extract_run_properties || { exit 1; }

cleanup || { exit 1; }

}