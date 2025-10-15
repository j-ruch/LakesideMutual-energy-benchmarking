#!/bin/bash

source "$HOME/.sdkman/bin/sdkman-init.sh"

WORKSPACE="$HOME/workspace"

BENCHMARK_HOME="$WORKSPACE/LakesideMutual-energy-benchmarking"

LAKESIDEMUTUAL_HOME="$WORKSPACE/LakesideMutual-Monolith"

JMETER_CONFIG="$WORKSPACE/LakesideMutual-energy-benchmarking/jmeter-LakesideMutual-SOA-server.jmx"

JOULARJX_CONFIG="$WORKSPACE/LakesideMutual-energy-benchmarking/joularjx_LakesideMutual-SOA_config.properties"

FLAMEGRAPH_HOME="$WORKSPACE/FlameGraph"

DOCKER_COMPOSE_FILE="$WORKSPACE/LakesideMutual-energy-benchmarking/docker-compose.yml"

APP_RUN_IDENTIFIER="$(date +%Y-%m-%d_%H-%M-%S)"
OUTPUT_FOLDER="$WORKSPACE/LakesideMutual-energy-benchmarking/out/$APP_RUN_IDENTIFIER"

JAVA_OPTS="-Xmx8g -Xms8g -XX:ActiveProcessorCount=8 -javaagent:$WORKSPACE/joularjx/target/joularjx-3.0.1.jar -Djoularjx.config=$JOULARJX_CONFIG -Dspring.profiles.active=default,test -Dspring.jpa.database-platform=org.hibernate.dialect.MySQLDialect"

LAKESIDEMUTUAL_PORT="8080"

URL_SWAGGER_SUFFIX="swagger-ui/index.html"

LAKESIDEMUTUAL_URL="localhost:$LAKESIDEMUTUAL_PORT/$URL_SWAGGER_SUFFIX"

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
    switch_branch_command="git -C $LAKESIDEMUTUAL_HOME checkout -f spring-boot-v3.x.x-$webserver"
  else
    echo "ERROR: Spring Boot version must start with 3."
    return 1
  fi
  
  echo "$switch_branch_command"
  eval "$switch_branch_command"
}

change_spring_boot_version() {
  echo "+================================+"
  echo "| Changing Spring Boot Version"
  echo "+================================+"
  change_spring_boot_version_command="$LAKESIDEMUTUAL_HOME/mvnw -f $LAKESIDEMUTUAL_HOME/pom.xml versions:update-parent -DparentVersion=[$spring_boot_version] versions:set-property -Dproperty="java.version" -DnewVersion=$java_version -DgenerateBackupPoms=false"

  echo "$change_spring_boot_version_command"
  eval "cd $LAKESIDEMUTUAL_HOME; $change_spring_boot_version_command"

  echo "Switching back to $BENCHMARK_HOME"
  eval "cd $BENCHMARK_HOME"
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
  build_output_file="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-build.log"

  BUILD_CMD="$LAKESIDEMUTUAL_HOME/mvnw -f $LAKESIDEMUTUAL_HOME/pom.xml clean package -Dmaven.test.skip -Dmaven.compiler.release=$java_version"

  build_application_component "$BUILD_CMD" "$build_output_file" "$LAKESIDEMUTUAL_HOME" || { exit 1; }

  echo "Switching back to $BENCHMARK_HOME"
  eval "cd $BENCHMARK_HOME"
}

print_app_info() {
  echo "+================================+"
  echo "| Configuration Properties"
  echo "+================================+"
  echo "JVM: $jvm_version"
  echo "Java: $java_version"
  echo "Spring Boot: $spring_boot_version"
  echo "Webserver: $webserver"
  echo "LakesideMutual Home: $LAKESIDEMUTUAL_HOME"
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
  check_if_port_is_open "$LAKESIDEMUTUAL_PORT" || { exit 1; }
}

start_mysql_container() {
  echo "+================================+"
  echo "| Starting MySQL Container"
  echo "+================================+"
  #mysql_container_command="docker run -d --rm -e MYSQL_USER=sa -e MYSQL_PASSWORD=sa -e MYSQL_ROOT_PASSWORD=sa -e MYSQL_DATABASE=lakesidemutual -p 3306:3306 mysql:8"
  #echo "$mysql_container_command"
  #db_container_id=$(eval "$mysql_container_command")
  #echo "Container ID: $db_container_id"
  
  mysql_docker_compose_build_command="docker compose -f $DOCKER_COMPOSE_FILE build"
  mysql_docker_compose_up_command="docker compose -f $DOCKER_COMPOSE_FILE up -d"

  echo "$mysql_docker_compose_build_command"
  eval "$mysql_docker_compose_build_command"

  echo "$mysql_docker_compose_up_command"
  eval "$mysql_docker_compose_up_command"

  sleep 10

  extract_container_id_command="docker ps -qf 'name=lakeside_mutual'"
  db_container_id=$(eval "$extract_container_id_command")
  echo "Container ID: $db_container_id"
  
  # Wait until the container is ready
  echo "Waiting for MySQL container to start and initialize..."
  until docker exec -it $db_container_id mysql -uroot -psa -e "SELECT '1';" >/dev/null 2>&1; do
    sleep 1
  done

  # give it a few more seconds to be ready
  echo "Give it 5s to be ready"
  sleep 5

  # 1001 is the number of expected customers
  verify_import_command="docker exec -it $db_container_id mysql -u root -psa -e \"USE lakesidemutual; SELECT count(*) FROM customers;\" | grep 1001"
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
  run_output_file="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-run.log"

  jfr_recording_file="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-recording.jfr"


  RUN_CMD="java $JAVA_OPTS -XX:StartFlightRecording=filename=$jfr_recording_file,settings=profile -Dspring.threads.virtual.enabled=$virtual_threads -jar $LAKESIDEMUTUAL_HOME/target/*.jar"

  run_command="$RUN_CMD > $run_output_file 2>&1 &"
  echo "$run_command"
  eval "$run_command"

  LAKESIDEMUTUAL_PID=$!
  sleep 2

  if ! ps -p "$LAKESIDEMUTUAL_PID" > /dev/null; then
    echo "ERROR: Run failed for application. Check $run_output_file for details."
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
  timeout=60
  end_time=$((SECONDS + timeout))

  check_service_initial_request "$timeout" "$end_time" "$LAKESIDEMUTUAL_URL" "$LAKESIDEMUTUAL_PID" || { exit 1; }
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
  stop_service "kill -15 $LAKESIDEMUTUAL_PID" "$LAKESIDEMUTUAL_PID" || { exit 1; }
  sleep_command="sleep 10"
  echo "$sleep_command"
  eval "$sleep_command"
}

stop_mysql_container() {
  echo "+================================+"
  echo "| Stopping MySQL Container"
  echo "+================================+"
  #mysql_stop_command="docker stop $db_container_id"
  mysql_stop_command="docker compose -f $DOCKER_COMPOSE_FILE down -v"
  echo "$mysql_stop_command"
  eval "$mysql_stop_command"
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to stop MySQL container."
    return 1
  fi
}

start_jmeter() {
  echo "+================================+"
  echo "| Starting JMeter"
  echo "+================================+"
  jmeter_output_file="$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-jmeter.log"

  JMETER_CMD="jmeter -n -t $JMETER_CONFIG -l $OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-jmeter.jtl -j $OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-jmeter.log"

  jmeter_command="$JMETER_CMD > $jmeter_output_file 2>&1"
  echo "$JMETER_CMD"

  eval "$JMETER_CMD"
  if [ $? -ne 0 ]; then
    echo "ERROR: JMeter run failed. Check $jmeter_output_file for details."
  fi
}

save_energy_measurement() {
  echo "+================================+"
  echo "| Saving Energy Measurement"
  echo "+================================+"

  save_energy_measurement_command="find $BENCHMARK_HOME/joularjx-result -name '*.csv' | xargs -I '{}' mv '{}' $OUTPUT_FOLDER/"
  echo "$save_energy_measurement_command"
  eval "$save_energy_measurement_command"

  # Combine all call tree CSV files into one file
  concatenate_command="find $OUTPUT_FOLDER/ -name '*all-call-trees-energy.csv' | xargs cat >> $OUTPUT_FOLDER/joularJX-all-call-trees-energy-combined.csv"
  echo "$concatenate_command"
  eval "$concatenate_command"

  concatenate_command="find $OUTPUT_FOLDER/ -name '*filtered-call-trees-energy.csv' | xargs cat >> $OUTPUT_FOLDER/joularJX-filtered-call-trees-energy-combined.csv"
  echo "$concatenate_command"
  eval "$concatenate_command"

  # Generate a folded stack file based on the combined call tree CSV files, remove the last delimiter (,) and replace it with a space
  fold_command="awk -F, 'NR>1 {print \$1 \" \" \$2}' $OUTPUT_FOLDER/joularJX-all-call-trees-energy-combined.csv > $OUTPUT_FOLDER/joularJX-all-call-trees-energy-combined-folded.txt"
  echo "$fold_command"
  eval "$fold_command"

  fold_command="awk -F, 'NR>1 {print \$1 \" \" \$2}' $OUTPUT_FOLDER/joularJX-filtered-call-trees-energy-combined.csv > $OUTPUT_FOLDER/joularJX-filtered-call-trees-energy-combined-folded.txt"
  echo "$fold_command"
  eval "$fold_command"

  # Generate flamegraphs based on the folded stack files
  flamegraph_command="$FLAMEGRAPH_HOME/flamegraph.pl $OUTPUT_FOLDER/joularJX-all-call-trees-energy-combined-folded.txt > $OUTPUT_FOLDER/joularJX-all-call-trees-energy-combined.svg"
  echo "$flamegraph_command"
  eval "$flamegraph_command"
  rc=$?
  if [ $rc -ne 0 ]; then
      echo "Warning: flamegraph command failed, continuing..."
  fi

  flamegraph_command="$FLAMEGRAPH_HOME/flamegraph.pl $OUTPUT_FOLDER/joularJX-filtered-call-trees-energy-combined-folded.txt > $OUTPUT_FOLDER/joularJX-filtered-call-trees-energy-combined.svg"
  echo "$flamegraph_command"
  eval "$flamegraph_command"
  rc=$?
  if [ $rc -ne 0 ]; then
      echo "Warning: flamegraph command failed, continuing..."
  fi
}

extract_run_properties() {
  echo "+================================+"
  echo "| Extracting Run Properties"
  echo "+================================+"

  # used_jvm_version=$(java -XshowSettings:properties -version 2>&1 | grep "java.runtime.version" | sed -e 's/^[^=]*= *//' -e 's/ *$//')
  # used_jvm_vendor=$(java -XshowSettings:properties -version 2>&1 | grep "java.vendor " | sed -e 's/^[^=]*= *//' -e 's/ *$//')

  echo "JVM: $jvm_version"

  used_java_version=$(javap -verbose $LAKESIDEMUTUAL_HOME/target/classes/com/lakesidemutual/LakesideMutualApplication.class | grep "major version" | awk '{print $3 - 44}')

  echo "Java Version LakesideMutual: $used_java_version"

  spring_versions=($(grep 'Running with' $run_output_file | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/v//'))

  # Output the variables to check
  echo "Spring Boot Version LakesideMutual: ${spring_versions[0]}"
  echo "Spring Version LakesideMutual: ${spring_versions[1]}"

  profiles=($(grep 'profiles are active' $run_output_file | grep -oE '"[^"]+"' | sed 's/"//g' | tr '\n' '+' | sed 's/\+$/\n/'))

  echo "Profiles LakesideMutual: $profiles"

  joules=($(grep 'Program consumed' $run_output_file | grep -oE '[0-9]+(\.[0-9]+)? joules' | sed 's/ joules//'))

  echo "Joules LakesideMutual: $joules"

  jmetertime=$(grep "summary =" "$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-jmeter.log" | tail -n 1 | awk -F'=' '{print $2}' | sed -E 's/.*in ([0-9]{2}:[0-9]{2}:[0-9]{2}).*/\1/')

  echo "JMeter: $jmetertime"

  jmeter_errors=$(grep "summary =" "$OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-jmeter.log" | tail -n 1 | awk -F'Err:' '{gsub(/^[ \t]+/, "", $2); split($2, a, " "); print a[1]}')

  if [ "$jmeter_errors" != "0" ]; then
    echo "ERROR: JMeter run failed with errors. Check $OUTPUT_FOLDER/log/$APP_RUN_IDENTIFIER-jmeter.log for details."
  fi

  results_output_file="$OUTPUT_FOLDER/results.txt"

  > "$results_output_file"
  
  if [ "$virtual_threads" == "true" ]; then
    echo "JVM: $jvm_version (Virtual Threads)" >> "$results_output_file"
  else
    echo "JVM: $jvm_version" >> "$results_output_file"
  fi

  echo "Java Version LakesideMutual: $used_java_version" >> "$results_output_file"

  echo "Spring Boot Version LakesideMutual: ${spring_versions[0]}" >> "$results_output_file"
  echo "Spring Version LakesideMutual: ${spring_versions[1]}" >> "$results_output_file"

  echo "Webserver: $webserver" >> "$results_output_file"

  echo "Profiles LakesideMutual: $profiles" >> "$results_output_file"

  echo "Joules LakesideMutual: $joules" >> "$results_output_file"

  echo "JMeter: $jmetertime" >> "$results_output_file"

  # Extract the energy measurements, excluding some methods that we are not interested in
  find_command="find $OUTPUT_FOLDER/ -name '*filtered-methods-energy.csv' | xargs cat | grep -v 'CGLIB\$STATICHOOK' | grep -v '0.0000' | grep -v 'equals' | grep -v 'invoke' | grep -v 'init' | grep -v 'setCallbacks'| grep -v 'isFrozen' | grep -v 'addAdvisor' | grep -v 'getIndex' | grep -v 'getTargetClass' | sed 's/com.lakesidemutual.interfaces.//' | sed 's/,/: /' | sort"
  eval "$find_command >> $results_output_file"

  mv "$OUTPUT_FOLDER" "$OUTPUT_FOLDER-Java-$jvm_version-Spring-Boot-$spring_boot_version"
}

cleanup() {
  echo "+================================+"
  echo "| Cleaning up"
  echo "+================================"
  cleanup_command="rm -rf $BENCHMARK_HOME/joularjx-result"
  echo "$cleanup_command"
  eval "$cleanup_command"
}

create_output_folders

print_app_info

# switch_application_branch || { exit 1; }

change_spring_boot_version || { exit 1; }

change_jvm_version || { exit 1; }

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

