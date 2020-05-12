#!/bin/bash

# This scritp can create/delete CockroachDB Local Cluster by using Docker.

# Variables
# Version of CockroachDB.
VERSION="v20.1.0"

# Docker Image of CockroachDB.
IMAGE="cockroachdb/cockroach"

# Number of cockroaches in the cluster.
COCKROACH_NUM=0

# Resource name.
# This script use this value as docker container name ${RESOURCE_NAME}-0,
# ${RESOURCE_NAME}-2, ..., ${RESOURCE_NAME}-9, and ${RESOURCE_NAME}-client.
# And use this value as docker network name ${RESOURCE_NAME}-net.
RESOURCE_NAME="cockroach"

# IP and Port that this script bind on the Docker Host, for listen client requests (SQL etc...).
# These values pass to the "-p" option of "docker run".
SQL_IP="127.0.0.1"
SQL_PORT=26257

# IP and Port that this script bind on the Docker Host, for listen HTTP requests (Web UI etc...).
# Each cockroach publish the HTTP port. HTTP_PORT is the first number of it.
# By default, 8081 (${RESOURCE_NAME}-1), 8082 (${RESOURCE_NAME}-2), ...,
# 8089 (${RESOURCE_NAME}-9) will be used.
# These values pass to the "-p" option of "docker run".
HTTP_IP="127.0.0.1"
HTTP_PORT=8081

# User name and password (If it is the Secure Cluster) of Non-root user.
NON_ROOT_USER_NAME="cockroach"
NON_ROOT_USER_PASSWORD="cockroach"

# Counter for loop process that execute "docker run". It will start cockroaches.
COUNT=1

# If "insecure" specified, create Insecure Cluster. (Add "--insecure" flag to "cockroach start".)
# This script will create Secure Cluster by default. (Add "--certs-dir" flag to "cockroach start" by default.)
INSECURE=0
SECURE_FLAG="--certs-dir=certs"

# If the number of cockroaches is 3, 6, or 9, ,enable "--locality" flag of "cockroach start".
LOCALITY=0
LOCALITY_FLAG=""

# The region name that this script pass to the first value of "--locality" flag.
REGION=()
REGION[0]="region-1"
REGION[1]="region-2"
REGION[2]="region-3"

# The zone name that this script pass to the second value of "--locality" flag.
ZONE=()
ZONE[0]="zone-a"
ZONE[1]="zone-b"
ZONE[2]="zone-c"

# Work directory that includes DB data, Cert files, and Status file.
WORK_DIR_RELATIVE_PATH="cockroach-cluster"
WORK_DIR_ABSOLUTE_PATH="${PWD}/${WORK_DIR_RELATIVE_PATH}"

# Directory that includes DB data.
DATA_DIR="${WORK_DIR_ABSOLUTE_PATH}/cockroach-data"

# Directory that includes Certification files.
CERT_DIR="${WORK_DIR_ABSOLUTE_PATH}/cockroach-cert"

# File that includes status information for this script.
STATUS_FILE="${WORK_DIR_ABSOLUTE_PATH}/cluster-status"

# Return value of this script.
RETURN=0

# Create CockroachDB Local Cluster.
create() {
	# Check the status file.
	if [ -f ${STATUS_FILE} ]; then
		echo -e "INFO: The status file ${STATUS_FILE} exists."
		# If the status is "Running", return error.
		if [ "$(head -n 1 ${STATUS_FILE})" = "Running" ]; then
			echo -e "ERROR: Maybe the CockroachDB Local Cluster is running." 1>&2
			RETURN=1
			exit ${RETURN}
		fi
	fi


	# Check argument.
	# If there is no argument, set default number of cockroaches (3 cockroaches).
	case "$1" in
		# If the argument is valid, use it.
		[1-9])
			COCKROACH_NUM=$1
			;;
		# If there is no argument, set the default value 3 as the number of cockroaches.
		"")
			COCKROACH_NUM=3
			echo -e "INFO: Set the number of cockroaches to 3 (default)."
			;;
		# If "create insecure" specified, check third argument.
		insecure)
			case "$2" in
				# If the argument is valid, use it.
				[1-9])
					COCKROACH_NUM=$2
					;;
				# If there is no argument, set the default value 3 as the number of cockroaches.
				"")
					COCKROACH_NUM=3
					echo -e "INFO: Set the number of cockroaches to 3 (default)."
					;;
				# If the argument is invalid, return error.
				*)
					echo -e "ERROR: Invalid argument. Please specify the number of cockroaches between 1 and 9." 1>&2
					echo -e "HINT: The max number of cockroaches of this script is 9." 1>&2
					RETURN=1
					exit ${RETURN}
					;;
			esac
			# If the third argument valid, set INSECURE to 1.
			INSECURE=1
			SECURE_FLAG="--insecure"
			echo -e "INFO: Create Insecure Cluster."
			;;
		# If the argument is invalid, return error.
		*)
			echo -e "ERROR: Invalid argument. Please specify the number of cockroaches between 1 and 9." 1>&2
			echo -e "HINT: The max number of cockroaches of this script is 9." 1>&2
			RETURN=1
			exit ${RETURN}
			;;
	esac

	# Show the number of cockroaches that will run in the local cluster.
	echo -e "INFO: The number of cockroaches in the cluster is ${COCKROACH_NUM}."


	# If the argument is valid, start creating cluster.
	echo -e "\n*** Start Creating CockroachDB Local Cluster ***\n"

	# If the number of cockroaches is 3, 6, or 9, add --locality flag to each cockroach.
	if [ $(expr ${COCKROACH_NUM} % 3) -eq 0 ]; then
		LOCALITY=1
		echo -e "INFO: Add --locality flag to each cockroach."
	else
		LOCALITY=0
	fi


	# If "insecure" specified, we don't need to create certification files.
	if [ ${INSECURE} -eq 0 ]; then
		# Create certification files.
		echo -e "INFO: Creating certification files."

		# Create CA dir.
		echo -e "INFO: Creating ${CERT_DIR} and sub directories."
		mkdir -p ${CERT_DIR}/certs ${CERT_DIR}/my-safe-directory
		if [ $? -ne 0 ]; then
			echo -e "ERROR: mkdir -p ${CERT_DIR}/certs ${CERT_DIR}/my-safe-directory failed." 1>&2
			RETURN=1
			exit ${RETURN}
		fi

		# Create cert dir of each cockroach.
		for i in `seq ${COCKROACH_NUM}`; do
			mkdir -p ${CERT_DIR}/${RESOURCE_NAME}-${i}
			if [ $? -ne 0 ]; then
				echo -e "ERROR: mkdir -p ${CERT_DIR}/${RESOURCE_NAME}-${i} failed." 1>&2
				RETURN=1
				exit ${RETURN}
			fi
		done
	fi


	# Create Docker Network that each cockroach and client will join.
	echo -e "INFO: Create Docker Network ${RESOURCE_NAME}-net."
	docker network create -d bridge ${RESOURCE_NAME}-net \
		-o "com.docker.network.bridge.name"="${RESOURCE_NAME}-net"
	if [ $? -ne 0 ]; then
		echo -e "ERROR: docker network create -d bridge ${RESOURCE_NAME}-net failed." 1>&2
		echo -e "HINT: Please check the docker network by \"docker network ls\" command." 1>&2
		echo -e "      If the ${RESOURCE_NAME}-net exists, please remove it manually." 1>&2
		RETURN=1
		exit ${RETURN}
	fi
	echo -e "INFO: Create Docker Network ${RESOURCE_NAME}-net done."

	# Start client container for setup processes and access CockroachDB Local Cluster.
	echo -e "INFO: Creating client container start."
	docker run -d \
		--name=${RESOURCE_NAME}-client \
		--hostname=${RESOURCE_NAME}-client \
		--net=${RESOURCE_NAME}-net \
		-v "${CERT_DIR}:/cockroach/.setup" \
		-v "${CERT_DIR}/${RESOURCE_NAME}-client:/cockroach/certs" \
		--entrypoint tail \
		${IMAGE}:${VERSION} \
		-f /dev/null
	if [ $? -ne 0 ]; then
		echo -e "ERROR: docker run -d --name=${RESOURCE_NAME}-client... failed." 1>&2
		echo -e "HINT: Please check the status of container by \"docker container ls -a\" command." 1>&2
		echo -e "      If the ${RESOURCE_NAME}-client container exists, please remove it manually." 1>&2
		RETURN=1
		exit ${RETURN}
	fi
	echo -e "INFO: Creating client container done."


	# If "insecure" specified, we don't need to create certification files.
	if [ ${INSECURE} -eq 0 ]; then
		# Create CA.
		docker exec ${RESOURCE_NAME}-client \
			./cockroach cert create-ca \
			--certs-dir=/cockroach/.setup/certs \
			--ca-key=/cockroach/.setup/my-safe-directory/ca.key \
			--allow-ca-key-reuse \
			--overwrite
		if [ $? -ne 0 ]; then
			echo -e "ERROR: docker exec ${RESOURCE_NAME}-client ./cockroach cert create-ca... failed." 1>&2
			RETURN=1
			exit ${RETURN}
		fi

		# Create cockroach (node) certs.
		for i in `seq ${COCKROACH_NUM}`; do
			docker exec ${RESOURCE_NAME}-client \
				./cockroach cert create-node ${RESOURCE_NAME}-${i} \
				--certs-dir=/cockroach/.setup/certs \
				--ca-key=/cockroach/.setup/my-safe-directory/ca.key \
				--overwrite
			if [ $? -ne 0 ]; then
				echo -e "ERROR: docker exec ${RESOURCE_NAME}-client ./cockroach cert create-node ${RESOURCE_NAME}-${i}... failed." 1>&2
				RETURN=1
				exit ${RETURN}
			fi

			cp ${CERT_DIR}/certs/* ${CERT_DIR}/${RESOURCE_NAME}-${i}/
			if [ $? -ne 0 ]; then
				echo -e "ERROR: cp ${CERT_DIR}/certs/* ${CERT_DIR}/${RESOURCE_NAME}-${i}/ failed." 1>&2
				RETURN=1
				exit ${RETURN}
			fi
		done

		# Create client certs.
		docker exec ${RESOURCE_NAME}-client \
			./cockroach cert create-client root \
			--certs-dir=/cockroach/.setup/certs \
			--ca-key=/cockroach/.setup/my-safe-directory/ca.key \
			--overwrite
		if [ $? -ne 0 ]; then
			echo -e "ERROR: docker exec ${RESOURCCE_NAME}-client ./cockroach cert create-client root... failed." 1>&2
			RETURN=1
			exit ${RETURN}
		fi

		mv ${CERT_DIR}/certs/client.root.* ${CERT_DIR}/${RESOURCE_NAME}-client/
		if [ $? -ne 0 ]; then
			echo -e "ERROR: mv ${CERT_DIR}/certs/client.root.* ${CERT_DIR}/${RESOURCE_NAME}-client/ failed." 1>&2
			RETURN=1
			exit ${RETURN}
		fi

		cp ${CERT_DIR}/${RESOURCE_NAME}-1/* ${CERT_DIR}/${RESOURCE_NAME}-client/
		if [ $? -ne 0 ]; then
			echo -e "ERROR: cp ${CERT_DIR}/${RESOURCE_NAME}-1/* ${CERT_DIR}/${RESOURCE_NAME}-client/" 1>&2
			RETURN=1
			exit ${RETURN}
		fi

		# Create certification files done.
		echo -e "INFO: Creating certification files done."
	fi


	# Create data dir of CockroachDB.
	echo -e "INFO: Creating data dir start."
	for i in `seq ${COCKROACH_NUM}`; do
		mkdir -p ${DATA_DIR}/${RESOURCE_NAME}-${i}
		if [ $? -ne 0 ]; then
			echo -e "ERROR: mkdir -p ${DATA_DIR}/${RESOURCE_NAME}-${i} failed." 1>&2
			RETURN=1
			exit ${RETURN}
		fi
	done
	echo -e "INFO: Creating data dir done."


	# Create cluster.
	echo -e "INFO: Creating cluster start."
	# Use REGION for outer loop.
	for i in ${REGION[@]}; do
		# Use ZONE for inner loop.
		for j in ${ZONE[@]}; do
			# Loop count. It depends on the number of cockroaches.
			if [ ${COUNT} -le ${COCKROACH_NUM} ]; then
				# Add "--locality flag to the each cockroach, if the number of cockroaches is 3, 6, or 9."
				if [ ${LOCALITY} -eq 1 ]; then
					LOCALITY_FLAG="--locality=region=${i},zone=${j}"
				# Don't add "--locality" flag to the each cockroach, if the number of cockroaches is 1, 2, 4, 5, 7, and 8.
				else
					LOCALITY_FLAG=""
				fi
				# Run the first cockroach.
				if [ ${COUNT} -eq 1 ]; then
					docker run -d \
						--name=${RESOURCE_NAME}-${COUNT} \
						--hostname=${RESOURCE_NAME}-${COUNT} \
						--net=${RESOURCE_NAME}-net \
						-p ${SQL_IP}:${SQL_PORT}:26257 \
						-p ${HTTP_IP}:${HTTP_PORT}:8080 \
						-v "${CERT_DIR}/${RESOURCE_NAME}-${COUNT}:/cockroach/certs" \
						-v "${DATA_DIR}/${RESOURCE_NAME}-${COUNT}:/cockroach/cockroach-data" \
						${IMAGE}:${VERSION} start \
						${SECURE_FLAG} \
						--join=${RESOURCE_NAME}-1,${RESOURCE_NAME}-2,${RESOURCE_NAME}-3 \
						${LOCALITY_FLAG}
					if [ $? -ne 0 ]; then
						echo -e "ERROR: docker run -d --name=${RESOURCE_NAME}-${COUNT}... (First cockroach) failed.\n" 1>&2
						echo -e "       *** Please check the status of each container by \"docker container ls -a\" command. " 1>&2
						echo -e "       *** If there are any failed container, please kill and remove them manually by \"docker kill\" and \"docker rm\" command.\n" 1>&2
						echo -e "       ***   There is a possibility that the following containers exist at this step.\n"
						echo -e "       ***   ${RESOURCE_NAME}-1, ${RESOURCE_NAME}-client" 1>&2
						RETURN=1
						exit ${RETURN}
					fi
					# Wait for 2 second just in case, for waiting first node start before init cluster.
					sleep 2
					# Init CockroachDB Cluster.
					# For sorting internal IDs of each cockroach in ascending order, we init cluster after first node run..
					# And, after that, we will run the second and later cockroaches.
					# If the ${STATUS_FILE} exsit, there is cluster (DB) data that is already initialized.
					# We don't need to initialize cluster, if it is already initialized. 
					if [ ! -f ${STATUS_FILE} ]; then
						echo -e "INFO: Initialize Cluster."
						docker exec ${RESOURCE_NAME}-client \
							./cockroach init \
							${SECURE_FLAG} \
							--host=${RESOURCE_NAME}-1:26257
						# Wait for 3 second just in case, for waiting cluster initialization fihish.
						sleep 3
						if [ $? -ne 0 ]; then
							echo -e "ERROR: docker exec ${RESOURCE_NAME}-client ./cockroach init ... failed." 1>&2
							RETURN=1
							exit ${RETURN}
						fi
					else
						echo -e "INFO: Skip initializing cluster, because the status file ${STATUS_FILE} exists."
					fi
				# Run the second and later cockroaches.
				# Add "--join" flag.
				else
					docker run -d \
						--name=${RESOURCE_NAME}-${COUNT} \
						--hostname=${RESOURCE_NAME}-${COUNT} \
						--net=${RESOURCE_NAME}-net \
						-p ${HTTP_IP}:${HTTP_PORT}:8080 \
						-v "${CERT_DIR}/${RESOURCE_NAME}-${COUNT}:/cockroach/certs" \
						-v "${DATA_DIR}/${RESOURCE_NAME}-${COUNT}:/cockroach/cockroach-data" \
						${IMAGE}:${VERSION} start \
						${SECURE_FLAG} \
						--join=${RESOURCE_NAME}-1,${RESOURCE_NAME}-2,${RESOURCE_NAME}-3 \
						${LOCALITY_FLAG}
					if [ $? -ne 0 ]; then
						echo -e "ERROR: docker run -d --name=${RESOURCE_NAME}-${COUNT}... (Second and later cockroaches) failed.\n" 1>&2
						echo -e "       *** Please check the status of each container by \"docker container ls -a\" command. " 1>&2
						echo -e "       *** If there are any failed container, please kill and remove them manually by \"docker kill\" and \"docker rm\" command.\n" 1>&2
						echo -e "       ***   There is a possibility that the following containers exist at this step.\n"
						echo -e "       ***   ${RESOURCE_NAME}-1, ${RESOURCE_NAME}-2, ${RESOURCE_NAME}-3" 1>&2
						echo -e "       ***   ${RESOURCE_NAME}-4, ${RESOURCE_NAME}-5, ${RESOURCE_NAME}-6" 1>&2
						echo -e "       ***   ${RESOURCE_NAME}-7, ${RESOURCE_NAME}-8, ${RESOURCE_NAME}-9" 1>&2
						echo -e "       ***   ${RESOURCE_NAME}-client\n" 1>&2
						RETURN=1
						exit ${RETURN}
					fi
				fi
				# Wait for 3 second just in case, for sorting internal IDs of each cockroach in ascending order.
				sleep 3
				# Increase loop counter.
				COUNT=$(expr ${COUNT} + 1)
				# Increase the number of HTTP port.
				HTTP_PORT=$(expr ${HTTP_PORT} + 1)
			# End loop, if ran required number of cockroaches.
			else
				break
			fi
		done
	done

	# Create status file. It includes "Running" and ${COCKROACH_NUM}.
	# The information of ${COCKROACH_NUM} will be used in the delete processes.
	touch ${STATUS_FILE}
	if [ $? -ne 0 ]; then
		echo -e "ERROR: touch ${STATUS_FILE} failed. (In the create process)" 1>&2
		RETURN=1
		exit ${RETURN}
	fi

	echo -e "Running" > ${STATUS_FILE}
	if [ $? -ne 0 ]; then
		echo -e "ERROR: echo -e \"Running\" > ${STATUS_FILE} failed." 1>&2
		RETURN=1
		exit ${RETURN}
	fi

	echo -e ${COCKROACH_NUM} >> ${STATUS_FILE}
	if [ $? -ne 0 ]; then
		echo -e "ERROR: echo -e ${COCKROACH_NUM} >> ${STATUS_FILE} failed." 1>&2
		RETURN=1
		exit ${RETURN}
	fi

	# Wait for the CockroachDB will be ready to accept connections.
	echo -e "INFO: Waiting for CockroachDB is ready to acccept connections."
	for i in `seq 10`; do
		sleep 3
		# Even if try to connect to DB 10 times (even if waiting about 30 second), if the DB will not be ready to accept connections, exit this script with return value 1.
		if [ ${i} -eq 10 ]; then
			echo -e "ERROR: CockroachDB was NOT ready to accept connections, even if try to connect to DB 10 times (even if waiting about 30 second)." 1>&2
			echo -e "HINT: There is possibility that some error occurred. Please check the DB or Container log." 1>&2
			RETURN=1
			exit ${RETURN}
		# Check if the DB is accessible or not, by using "SELECT 1".
		else
			docker exec ${RESOURCE_NAME}-client \
				./cockroach sql \
				${SECURE_FLAG} \
				--host=${RESOURCE_NAME}-1:26257 \
				-e "SELECT 1" > /dev/null
			if [ $? -eq 0 ];then
				echo -e "INFO: CockroachDB is ready to accept connections."
				break
			elif [ $? -ne 0 ]; then
				echo -e "INFO: CockroachDB is NOT ready to accept connections."
			fi
		fi
	done

	echo -e "INFO: Creating cluster done."


	# Create non-root user for access DB and Web UI.
	echo -e "INFO: Creating non-root user for access DB and Web UI start."


	# Use "--insecure" flag, if the cluster is Insecure Cluster.
	# And, create user without password. You can access CockroachDB without authentication, if it is Insecure Cluster.
	if [ ${INSECURE} -eq 1 ]; then
		docker exec ${RESOURCE_NAME}-client \
			./cockroach sql \
			${SECURE_FLAG} \
			--host=${RESOURCE_NAME}-1:26257 \
			-e "CREATE USER IF NOT EXISTS ${NON_ROOT_USER_NAME}"
		if [ $? -ne 0 ]; then
			echo -e "ERROR: docker exec ${RESOURCE_NAME}-client ./cockroach sql ... -e \"CREATE USER IF NOT EXISTS ${NON_ROOT_USER_NAME}\" failed." 1>&2
			RETURN=1
			exit ${RETURN}
		fi
	# Use "--certs-dir" flag, if the cluster is Secure Cluster.
	# And, create user with password. You need password or certificate authentication for access cockroachDB, if it is Secure Cluster.
	elif [ ${INSECURE} -eq 0 ]; then
		docker exec ${RESOURCE_NAME}-client \
			./cockroach sql \
			${SECURE_FLAG} \
			--host=${RESOURCE_NAME}-1:26257 \
			-e "CREATE USER IF NOT EXISTS ${NON_ROOT_USER_NAME} WITH PASSWORD '${NON_ROOT_USER_PASSWORD}'"
		if [ $? -ne 0 ]; then
			echo -e "ERROR: docker exec ${RESOURCE_NAME}-client ./cockroach sql ... -e \"CREATE USER IF NOT EXISTS ${NON_ROOT_USER_NAME} WITH PASSWORD '${NON_ROOT_USER_PASSWORD}'\" failed." 1>&2
			RETURN=1
			exit ${RETURN}
		fi
	fi
	echo -e "Creating non-root user for access DB and Web UI done."


	# Confirm the cluster status.
	echo -e "INFO: CockroachDB Cluster Status is the following."
	docker exec -t ${RESOURCE_NAME}-client \
		./cockroach node status \
		${SECURE_FLAG} \
		--host=${RESOURCE_NAME}-1:26257
	if [ $? -ne 0 ]; then
		echo -e "ERROR: docker exec ${RESOURCE_NAME}-client ./cockroach node status... failed." 1>&2
		RETURN=1
		exit ${RETURN}
	fi


	# Chech intro DB exists or not.
	docker exec ${RESOURCE_NAME}-client \
		./cockroach sql \
		${SECURE_FLAG} \
		--host=${RESOURCE_NAME}-1:26257 \
		-e "SELECT l FROM intro.mytable LIMIT 0" > /dev/null 2>&1
	# Here is no error handling, because we use the return code even if error (No such table) occurred.
	# If intor DB exist, set "0" to RESULT. If it does not exist, set "1" to RESULT.
	RESULT=$?

	# If the intro DB does not exist, create it.
	if [ ${RESULT} -eq 1 ]; then
		# If it is Insecure Cluster, we don't need authentication for access CockroachDB.
		if [ ${INSECURE} -eq 1 ]; then
		docker exec ${RESOURCE_NAME}-client \
			./cockroach workload init intro \
			"postgresql://root@${RESOURCE_NAME}-1:26257?sslmode=disable"
			if [ $? -ne 0 ]; then
			echo -e "ERROR: docker exec ${RESOURCE_NAME}-client ./cockroach workload init intro... failed." 1>&2
			RETURN=1
			exit ${RETURN}
			fi
		# If it is Secure Cluster, we need certificate authentication for access CockroachDB as a root user.
		elif [ ${INSECURE} -eq 0 ]; then
		docker exec ${RESOURCE_NAME}-client \
			./cockroach workload init intro \
			"postgresql://root@${RESOURCE_NAME}-1:26257?sslcert=certs%2Fclient.root.crt&sslkey=certs%2Fclient.root.key&sslmode=verify-full&sslrootcert=certs%2Fca.crt"
			if [ $? -ne 0 ]; then
			echo -e "ERROR: docker exec ${RESOURCE_NAME}-client ./cockroach workload init intro... failed." 1>&2
			RETURN=1
			exit ${RETURN}
			fi
		fi
	fi


	# Show the cockroach!!!
	docker exec -t ${RESOURCE_NAME}-client \
		./cockroach sql \
		${SECURE_FLAG} \
		--host=${RESOURCE_NAME}-1:26257 \
		-e "SELECT v as \"Hello, CockroachDB!\" FROM intro.mytable WHERE (l % 2) = 0"
	if [ $? -ne 0 ]; then
		echo -e "ERROR: docker exec ${RESOURCE_NAME}-client ./cockroach sql ... -e \"SELECT v as \"Hello, CockroachDB!\" FROM intro.mytable WHERE (l % 2) = 0\" failed." 1>&2
		RETURN=1
		exit ${RETURN}
	fi


	echo -e "\n*** Creating CockroachDB Local Cluster done ***\n"
	echo -e "INFO: Let's access to the CockroachDB by using built-in SQL Shell, and Web UI!"

	# The way to acccess DB and Web UI.
	# You can also use the "Connection Strings" of PostgreSQL (libpq) to access DB (using --url flag).
	# Use "--insecure" flag to access CockroachDB Cluster, if the cluster is Insecure Cluster.
	if [ ${INSECURE} -eq 1 ]; then
		# The way to access DB as a root user.
		echo -e "\n  Access DB as a root user:"
		echo -e "    sudo docker exec -it ${RESOURCE_NAME}-client ./cockroach sql --user=root ${SECURE_FLAG} --host=${RESOURCE_NAME}-1:26257"
		# echo -e "      or"
		# echo -e "    sudo docker exec -it ${RESOURCE_NAME}-client ./cockroach sql --url=\"postgresql://root@${RESOURCE_NAME}-1:26257/defaultdb?sslmode=disable\""

		# The way to access DB as a non-root user.
		echo -e "\n  Access DB as a non-root user (user name: ${NON_ROOT_USER_NAME}):"
		echo -e "    sudo docker exec -it ${RESOURCE_NAME}-client ./cockroach sql --user=${NON_ROOT_USER_NAME} ${SECURE_FLAG} --host=${RESOURCE_NAME}-1:26257"
		# echo -e "      or"
		# echo -e "    sudo docker exec -it ${RESOURCE_NAME}-client ./cockroach sql --url=\"postgresql://${NON_ROOT_USER_NAME}@${RESOURCE_NAME}-1:26257/defaultdb?sslmode=disable\""

		# The way to access Web UI as a root user.
		# If it is a Insecure Cluster, you can access Web UI as a root user without authentication.
		echo -e "\n  Access Web UI as a root user:"
		echo -e "    URL: http://${HTTP_IP}:$(expr ${HTTP_PORT} - ${COCKROACH_NUM})/"

	# Use "--certs-dir" flag to access CockroachDB Cluster, if the cluster is Secure Cluster.
	elif [ ${INSECURE} -eq 0 ]; then
		# The way to access as a root user.
		echo -e "\n  Access DB as a root user:"
		echo -e "    sudo docker exec -it ${RESOURCE_NAME}-client ./cockroach sql --user=root ${SECURE_FLAG} --host=${RESOURCE_NAME}-1:26257"
		# echo -e "      or"
		# echo -e "    sudo docker exec -it ${RESOURCE_NAME}-client ./cockroach sql --url=\"postgresql://root@${RESOURCE_NAME}-1:26257/defaultdb?sslcert=certs%2Fclient.root.crt&sslkey=certs%2Fclient.root.key&sslmode=verify-full&sslrootcert=certs%2Fca.crt\""

		# The way to access as a non-root user.
		echo -e "\n  Access DB as a non-root user (user name: ${NON_ROOT_USER_NAME} / password: ${NON_ROOT_USER_PASSWORD}):"
		echo -e "    sudo docker exec -it ${RESOURCE_NAME}-client ./cockroach sql --user=${NON_ROOT_USER_NAME} ${SECURE_FLAG} --host=${RESOURCE_NAME}-1:26257"
		# echo -e "      or"
		# echo -e "    sudo docker exec -it ${RESOURCE_NAME}-client ./cockroach sql --url=\"postgresql://${NON_ROOT_USER_NAME}:${NON_ROOT_USER_PASSWORD}@${RESOURCE_NAME}-1:26257/defaultdb?sslmode=require\""

		# The way to access Web UI as a non-root user.
		# If it is a Secure Cluster, you cannot access Web UI as a root, you need access as a non-root user with password authentication.
		echo -e "\n  Access Web UI as a non-root user (user name: ${NON_ROOT_USER_NAME} / password: ${NON_ROOT_USER_PASSWORD}):"
		echo -e "    URL: https://${HTTP_IP}:$(expr ${HTTP_PORT} - ${COCKROACH_NUM})/"
	fi
	echo -e ""

	exit ${RETURN}
}


# Delete CockroachDB Local Cluster.
delete() {
	# Check argument.
	case "$1" in
		# Normal delete processes.
		# This script gets the number of cockroaches that it will delete from ${STATUS_FILE}.
		"")
			# Check ${STATUS_FILE}.
			if [ -f ${STATUS_FILE} ]; then
				echo -e "INFO: The status file ${STATUS_FILE} exists."
				# If the status is "Deleted", return error.
				if [ "$(head -n 1 ${STATUS_FILE})" = "Deleted" ]; then
					echo -e "ERROR: Maybe the CockroachDB Local Cluster already deleted." 1>&2
					RETURN=1
					exit ${RETURN}
				# Get the number of cockroaches in the cluster.
				else
					# Get the number of cockroaches in the cluster from ${STATUS_FILE}.
					COCKROACH_NUM=$(tail -n 1 ${STATUS_FILE})
					# Check value of ${COCKROACH_NUM}.
					case "${COCKROACH_NUM}" in
						# If the value is valid, report it.
						[1-9])
							echo -e "INFO: Getting the number of cockroaches from status file succeeded."
							;;
						# If the value is invalid, return error.
						*)
							echo -e "ERROR: Invalid or Missing information about the number of cockroaches in the status file." 1>&2
							echo -e "HINT: Please check the status file ${STATUS_FILE}." 1>&2
							echo -e "HINT: If there is some issue in the status file and you want to force the delete processes, specify the "force" and "number of cockroaches"." 1>&2
							echo -e "Ex: sudo ./cockroachdb-local-cluster.sh delete force 3" 1>&2
							RETURN=1
							exit ${RETURN}
							;;
					esac
				fi
			# If the ${STATUS_FILE} does not exists, return error.
			else
				echo -e "ERROR: The status file ${STATUS_FILE} does not exist." 1>&2
				echo -e "HINT: Maybe the CockroachDB Local Cluster is not running." 1>&2
				echo -e "HINT: If the status file is missing and you want to force the delete processes, specify the "force" and "number of cockroaches"." 1>&2
				echo -e "Ex: sudo ./cockroachdb-local-cluster.sh delete force 3" 1>&2
				RETURN=1
				exit ${RETURN}
			fi
			;;
		# If "force" specified, this script start the delete processes without error handling.
		force)
			force $2
			;;
		# If there is some invalid argument, return error.
		*)
			echo -e "ERROR: Invalid argument." 1>&2
			echo -e "HINT: Basically, you don't need to specify some argument to "delete", because this script will get information from status file." 1>&2
			echo -e "HINT: If you want to force the delete processes, specify the "force" and "number of cockroaches"." 1>&2
			echo -e "Ex: sudo ./cockroachdb-local-cluster.sh delete force 3" 1>&2
			RETURN=1
			exit ${RETURN}
			;;
	esac
	echo -e "INFO: The number of cockroaches in the cluster is ${COCKROACH_NUM}."

	# Start delete processes.
	echo -e "\n*** Start Deleting CockroachDB Local Cluster ***\n"

	# Show the resources that will be deleted.
	echo -e "INFO: Delete the following resources.\n"
	echo -e "Docker Containers:"
	for i in `seq ${COCKROACH_NUM}`; do
		echo -e "  ${RESOURCE_NAME}-${i}"
	done
	echo -e "  ${RESOURCE_NAME}-client"
	echo -e "\nDocker Network:"
	echo -e "  ${RESOURCE_NAME}-net\n"

	# Kill containers.
	# If use "docker stop" for stop cockroaches, it takes a long time.
	# So, this script use "docker kill" instead of "docker stop".
	for i in `seq ${COCKROACH_NUM}`; do
		docker kill ${RESOURCE_NAME}-${i}
		if [ $? -ne 0 ]; then
			echo -e "ERROR: docker kill ${RESOURCE_NAME}-${i} failed." 1>&2
			echo -e "       *** Please check the status of each container by \"docker container ls -a\" command. " 1>&2
			echo -e "       *** If there are any failed container, please kill and remove them manually by \"docker kill\" and \"docker rm\" command.\n" 1>&2
			echo -e "       ***   There is a possibility that the following containers exist at this step.\n"
			echo -e "       ***   ${RESOURCE_NAME}-1, ${RESOURCE_NAME}-2, ${RESOURCE_NAME}-3" 1>&2
			echo -e "       ***   ${RESOURCE_NAME}-4, ${RESOURCE_NAME}-5, ${RESOURCE_NAME}-6" 1>&2
			echo -e "       ***   ${RESOURCE_NAME}-7, ${RESOURCE_NAME}-8, ${RESOURCE_NAME}-9\n" 1>&2
			RETURN=1
			exit ${RETURN}
		fi
	done

	# Remove stopped containers.
	for i in `seq ${COCKROACH_NUM}`; do
		docker rm ${RESOURCE_NAME}-${i}
		if [ $? -ne 0 ]; then
			echo -e "ERROR: docker rm ${RESOURCE_NAME}-${i} failed." 1>&2
			echo -e "       *** Please check the status of each container by \"docker container ls -a\" command. " 1>&2
			echo -e "       *** If there are any failed container, please kill and remove them manually by \"docker kill\" and \"docker rm\" command.\n" 1>&2
			echo -e "       ***   There is a possibility that the following containers exist at this step.\n"
			echo -e "       ***   ${RESOURCE_NAME}-1, ${RESOURCE_NAME}-2, ${RESOURCE_NAME}-3" 1>&2
			echo -e "       ***   ${RESOURCE_NAME}-4, ${RESOURCE_NAME}-5, ${RESOURCE_NAME}-6" 1>&2
			echo -e "       ***   ${RESOURCE_NAME}-7, ${RESOURCE_NAME}-8, ${RESOURCE_NAME}-9\n" 1>&2
			RETURN=1
			exit ${RETURN}
		fi
	done

	# Kill and remove client container.
	docker kill ${RESOURCE_NAME}-client
	if [ $? -ne 0 ]; then
		echo -e "ERROR: docker kill ${RESOURCE_NAME}-client failed." 1>&2
		echo -e "       *** Please check the status of each container by \"docker container ls -a\" command. " 1>&2
		echo -e "       *** If there are any failed container, please kill and remove it manually by \"docker kill\" and \"docker rm\" command.\n" 1>&2
		echo -e "       ***   There is a possibility that the following container exists at this step.\n"
		echo -e "       ***   ${RESOURCE_NAME}-client\n" 1>&2
		RETURN=1
		exit ${RETURN}
	fi

	docker rm ${RESOURCE_NAME}-client
	if [ $? -ne 0 ]; then
		echo -e "ERROR: docker rm ${RESOURCE_NAME}-client failed." 1>&2
		echo -e "       *** Please check the status of each container by \"docker container ls -a\" command. " 1>&2
		echo -e "       *** If there are any failed container, please kill and remove it manually by \"docker kill\" and \"docker rm\" command.\n" 1>&2
		echo -e "       ***   There is a possibility that the following container exists at this step.\n"
		echo -e "       ***   ${RESOURCE_NAME}-client\n" 1>&2
		RETURN=1
		exit ${RETURN}
	fi

	# Remove docker network.
	docker network rm ${RESOURCE_NAME}-net
	if [ $? -ne 0 ]; then
		echo -e "ERROR: docker network rm ${RESOURCE_NAME}-net failed." 1>&2
		echo -e "       *** Please check the status of docker network by \"docker network ls\" command. " 1>&2
		echo -e "       *** If does the \"${RESOURCE_NAME}-net\" exist, please remove it manually by \"docker network rm\" command.\n" 1>&2
		echo -e "       ***   There is a possibility that the following docker network exists at this step.\n"
		echo -e "       ***   ${RESOURCE_NAME}-net\n" 1>&2
		RETURN=1
		exit ${RETURN}
	fi

	# Create status file that includes information about deleteing cluster done.
	touch ${STATUS_FILE}
	if [ $? -ne 0 ]; then
		echo -e "ERROR: touch ${STATUS_FILE} failed." 1>&2
		RETURN=1
		exit ${RETURN}
	fi

	echo -e "Deleted" > ${STATUS_FILE}
	if [ $? -ne 0 ]; then
		echo -e "ERROR: echo -e \"Deleted\" > ${STATUS_FILE} failed." 1>&2
		RETURN=1
		exit ${RETURN}
	fi

	# Delete done.
	# This script does not delete the ./${WORK_DIR_RELATIVE_PATH}.
	# It includes DB data and certification files.
	# If you don't need the DB data, remove it manually.
	echo -e "\n*** Deleting CockroachDB Local Cluster done ***\n"
	echo -e "INFO: You can re-create the cluster with DB DATA of deleted cluster (you can re-use deleted cluster's DATA), if you want re-use old DATA, re-run this script with "create" option."
	echo -e "  Ex: sudo ./cockroachdb-local-cluster.sh create\n"
	echo -e "INFO: If you don't need the DB DATA of deleted cluster, remove the ./${WORK_DIR_RELATIVE_PATH}/ dir manually."
	echo -e "  Ex: sudo rm -rf ./${WORK_DIR_RELATIVE_PATH}/\n"

	exit ${RETURN}
}


force() {
	# Check the second argument.
	case "$1" in
		[1-9])
			COCKROACH_NUM=$1
			# Show the WARNING message.
			# You should to confirm docker containers and docker network after "delete force".
			echo -e "\nWARNING: *** Do the force deleting processes ***\n"
			echo -e "           *** After force deleting process, please check the status of each resource.\n"
			echo -e "           *** Docker containers (you can check them by \"docker container ls -a\" command)."
			echo -e "           ***   There is a possibility that the following containers exist.\n"
			echo -e "           ***   ${RESOURCE_NAME}-1, ${RESOURCE_NAME}-2, ${RESOURCE_NAME}-3" 1>&2
			echo -e "           ***   ${RESOURCE_NAME}-4, ${RESOURCE_NAME}-5, ${RESOURCE_NAME}-6" 1>&2
			echo -e "           ***   ${RESOURCE_NAME}-7, ${RESOURCE_NAME}-8, ${RESOURCE_NAME}-9" 1>&2
			echo -e "           ***   ${RESOURCE_NAME}-client\n" 1>&2
			echo -e "           *** Docker network (you can check it by \"docker network ls\" command)."
			echo -e "           ***   There is a possibility that the following docker network exists.\n"
			echo -e "           ***   ${RESOURCE_NAME}-net\n" 1>&2
			;;
		# The "delete force" have to get number of cockroaches that it will delete from argument.
		# If there is no argument, return error.
		"")
			echo -e "ERROR: Missing argument. You need to specify the number of cockroaches between 1 and 9 as an argument of "delete force"." 1>&2
			echo -e "HINT: There is no default value in "delete force"." 1>&2
			RETURN=1
			exit ${RETURN}
			;;
		# If the argument is invalid, return error.
		*)
			echo -e "ERROR: Invalid argument. Please specify the number of cockroaches between 1 and 9 as an argument of "delete force"." 1>&2
			echo -e "HINT: The max number of cockroaches of this script is 9." 1>&2
			RETURN=1
			exit ${RETURN}
			;;
	esac
	echo -e "INFO: The number of cockroaches that will be killed is ${COCKROACH_NUM}."

	# At this steps, there is no error hadling.
	# Because, this script force deleting processes. Run all commands ("docker kill", "docker rm" and "docker network rm").
	# So, this steps (delete force) will not stop, even if any error occurs.

	# Start force deleting processes.
	echo -e "\n*** Start *FORCE* Deleting CockroachDB Local Cluster ***\n"
	echo -e "INFO: Try to delete the following all resources.\n"

	# Show the resources that will be deleted.
	echo -e "INFO: Delete the following resources.\n"
	echo -e "Docker Containers:"
	for i in `seq ${COCKROACH_NUM}`; do
		echo -e "  ${RESOURCE_NAME}-${i}"
	done
	echo -e "  ${RESOURCE_NAME}-client"
	echo -e "\nDocker Network:"
	echo -e "  ${RESOURCE_NAME}-net\n"

	# Kill containers.
	# If use "docker stop" for stop cockroaches, it takes a long time.
	# So, this script use "docker kill" instead of "docker stop".
	for i in `seq ${COCKROACH_NUM}`; do
		docker kill ${RESOURCE_NAME}-${i}
	done

	# Remove stopped containers.
	for i in `seq ${COCKROACH_NUM}`; do
		docker rm ${RESOURCE_NAME}-${i}
	done

	# Kill and remove client container.
	docker kill ${RESOURCE_NAME}-client
	docker rm ${RESOURCE_NAME}-client

	# Remove docker network.
	docker network rm ${RESOURCE_NAME}-net

	# Create status file that includes information about deleteing cluster done.
	touch ${STATUS_FILE}
	echo -e "Deleted" > ${STATUS_FILE}

	# Force deleting done.
	# This script does not delete the ./${WORK_DIR_RELATIVE_PATH}.
	# It includes DB data and certification files.
	# If you don't need the DB data, remove it manually.
	echo -e "\n*** *FORCE* Deleting CockroachDB Local Cluster done ***\n"
	echo -e "INFO: You can re-create the cluster with DB DATA of deleted cluster (you can re-use deleted cluster's DATA), if you want re-use old DATA, re-run this script with "create" option."
	echo -e "  Ex: sudo ./cockroachdb-local-cluster.sh create\n"
	echo -e "INFO: If you don't need the DB DATA of deleted cluster, remove the ./${WORK_DIR_RELATIVE_PATH}/ dir manually."
	echo -e "  Ex: sudo rm -rf ./${WORK_DIR_RELATIVE_PATH}/\n"

	exit ${RETURN}
}


help() {
	# Show usages.
	echo -e "
Deploy the swarm of cockroaches on your local environment with Docker.

Usage:
  sudo ./cockroachdb-local-cluster.sh create [insecure] [number_of_cockroaches]
  sudo ./cockroachdb-local-cluster.sh delete [force number_of_cockroaches]

    Note: The max number of cockroaches of this script (number_of_cockroaches) is 9.


Examples:

  1. Create Secure Cluster:
     Ex: sudo ./cockroachdb-local-cluster.sh create 9

       Note: If you don't specify the number of cockroaches, the default value is 3.

     After create Secure Cluster, you can access to the CockroachDB by using built-in SQL shell.
       Ex: sudo docker exec -it ${RESOURCE_NAME}-client ./cockroach sql --certs-dir=certs --host=${RESOURCE_NAME}-1:26257


  2. Create Insecure Cluster:
     Ex: sudo ./cockroachdb-local-cluster.sh create insecure 9

       Note: If you don't specify the number of cockroaches, the default value is 3.

     After create Insecure Cluster, you can access to the CockroachDB by using built-in SQL shell.
       Ex: sudo docker exec -it ${RESOURCE_NAME}-client ./cockroach sql --insecure --host=${RESOURCE_NAME}-1:26257


  3. Delete Cluster:
     Ex: sudo ./cockroachdb-local-cluster.sh delete

       Note: Basically, you don't need to specify the number of cockroaches, because this script will get it from status file.
             If some failure occur and you want to force the delete processes, specify the "force" and the number of cockroaches.


  4. Force Delete Cluster:
     Ex: sudo ./cockroachdb-local-cluster.sh delete force 9

       Note: \"delete force\" will kill and remove the following containers and docker network.
             Please check the each resources after \"delete force\" processes by using the following commands.

              Docker containers (you can check them by \"docker container ls -a\" command).
              There is a possibility that the following containers exist.
                ${RESOURCE_NAME}-1, ${RESOURCE_NAME}-2, ${RESOURCE_NAME}-3
                ${RESOURCE_NAME}-4, ${RESOURCE_NAME}-5, ${RESOURCE_NAME}-6
                ${RESOURCE_NAME}-7, ${RESOURCE_NAME}-8, ${RESOURCE_NAME}-9
                ${RESOURCE_NAME}-client

              Docker network (you can check it by \"docker network ls\" command).
              There is a possibility that the following docker network exists.
                ${RESOURCE_NAME}-net
	"
	exit ${RETURN}
}


# Check the number of argument.
if [ "$#" -gt 3 ]; then
	echo -e "ERROR: Invalid number of arguments." 1>&2
	echo -e "HINT: The number of arguments of this script is between 1 and 3." 1>&2
	RETURN=1
	exit ${RETURN}
fi

# Check first argument.
case "$1" in
	# Run the create process.
	create)
		create $2 $3
		;;
	# Run the create process.
	delete)
		delete $2 $3
		;;
	# Show the usage.
	help)
		help
		;;
	# Invalid argument.
	*)
		echo -e "ERROR: Invalid argument." 1>&2
		echo -e "HINT: Please run the './cockroachdb-local-cluster.sh help'." 1>&2
		RETURN=1
		exit ${RETURN}
		;;
esac

exit ${RETURN}
