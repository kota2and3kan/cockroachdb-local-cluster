#!/bin/bash

# Test for cockroachdb-local-cluster.sh.

# Script that you will test.
SCRIPT="./cockroachdb-local-cluster.sh"

# These values must be the same as the value of cockroachdb-local-cluster.sh.
RESOURCE_NAME="cockroach"
WORK_DIR_RELATIVE_PATH="cockroach-cluster"
WORK_DIR_ABSOLUTE_PATH="${PWD}/${WORK_DIR_RELATIVE_PATH}"
STATUS_FILE="${WORK_DIR_RELATIVE_PATH}/cluster-status"
IMAGE="cockroachdb/cockroach"
VERSION="v21.2.0"

# Count the test number.
TEST_NO=0

# Count the number of succeeded test.
SUCCESS_COUNT=0

# Count the number of failed test.
FAIL_COUNT=0

# INPUT of each test.
INPUT=""

# Expected OUTPUT of each test.
OUTPUT=""


# Template of test.
### Template
#	INPUT=""
#	OUTPUT=""
#	TEST_NO=$(expr ${TEST_NO} + 1)
#	echo -e "\nTest No. ${TEST_NO}."
#
#	${SCRIPT} ${INPUT}
#	if [ $? = ${OUTPUT} ]; then
#		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
#	else
#		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
#		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
#		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
#		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
#	fi


#################################################
### Argument validation test. (Invalid arguments)
#################################################

echo -e "\n\n\n\n###### Argument validation test (Invalid arguments) ######"

### If there is no argument, return 1.
	INPUT=""
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

### If there are 4 or later arguments, return 1.
	INPUT="a b c d"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

### "create 0" will return 1.
	INPUT="create 0"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

### "create 10" will return 1.
	INPUT="create 10"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

### "create foobar" will return 1.
	INPUT="create foobar"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

### "delete force" will return 1.
	INPUT="delete force"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

### "delete force 0" will return 1.
	INPUT="delete force 0"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

### "delete force 10" will return 1.
	INPUT="delete force 10"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

### "delete force foobar" will return 1.
	INPUT="delete force foobar"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

### "create insecure 0" will return 1.
	INPUT="create insecure 0"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

### "create insecure 10" will return 1.
	INPUT="create insecure 10"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

### "create insecure foobar" will return 1.
	INPUT="create insecure foobar"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

### "foobar" will return 1.
	INPUT="foobar"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1


#####################
### Status file test.
#####################

echo -e "\n\n\n\n###### Status file test ######"

### If the ${STATUS_FILE} exists and status is "Running", "create" will return 1.
	INPUT="create"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	# Prepare for the test.
	mkdir -p ${WORK_DIR_RELATIVE_PATH}
	touch ${STATUS_FILE}
	echo "Running" > ${STATUS_FILE}
	echo 3 >> ${STATUS_FILE}
	sleep 1

	# Test.
	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi

	# Post process.
	rm -rf ./${WORK_DIR_RELATIVE_PATH}
	sleep 1

### If the ${STATUS_FILE} exists and status is "Deleted", "delete" will return 1.
	INPUT="delete"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	# Prepare for the test.
	mkdir -p ${WORK_DIR_RELATIVE_PATH}
	touch ${STATUS_FILE}
	echo "Deleted" > ${STATUS_FILE}
	sleep 1

	# Test.
	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi

	# Post process.
	rm -rf ./${WORK_DIR_RELATIVE_PATH}
	sleep 1

### If the ${STATUS_FILE} does not exist, "delete" will return 1.
	INPUT="delete"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1


############################################
### CREATE and DELETE test. (Secure Cluster)
############################################

echo -e "\n\n\n\n###### CREATE and DELETE test (Secure cluster) ######"

### "delete force" with argument from 1 to 9, it will return 0.
	for i in `seq 9`; do
		INPUT="delete force ${i}"
		OUTPUT=0
		TEST_NO=$(expr ${TEST_NO} + 1)
		echo -e "\nTest No. ${TEST_NO}."

		${SCRIPT} ${INPUT}
		if [ $? = ${OUTPUT} ]; then
			SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
		else
			FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
			echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
			echo -e "Failed test's INPUT is ${INPUT}." 1>&2
			echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
		fi
		sleep 1
	done

### CREATE and DELETE with default value of the number of node test. "create" will 3 node cluster (The default value is 3).
	# Create Cluster test.
	INPUT="create"
	OUTPUT=0
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		NODE_NUM=$(docker exec ${RESOURCE_NAME}-client ./cockroach sql --certs-dir=certs --host=cockroach-1:26257 -e "SELECT count(*) FROM crdb_internal.gossip_nodes" | tail -n 1)
		if [ ${NODE_NUM} -ne 3 ]; then
			FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
			echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
			echo -e "Failed test's INPUT is ${INPUT}." 1>&2
			echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
		else
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
		fi
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

	# Delete Cluster test.
	INPUT="delete"
	OUTPUT=0
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

	# Post process.
	${SCRIPT} delete force 9 > /dev/null 2>&1
	rm -rf ./${WORK_DIR_RELATIVE_PATH}
	sleep 1

### CREATE and DELETE cluster that its number of nodes is from 1 to 9.
	for i in `seq 9`; do
		# Create Cluster test.
		INPUT="create ${i}"
		OUTPUT=0
		TEST_NO=$(expr ${TEST_NO} + 1)
		echo -e "\nTest No. ${TEST_NO}."

		${SCRIPT} ${INPUT}
		if [ $? = ${OUTPUT} ]; then
			NODE_NUM=$(docker exec ${RESOURCE_NAME}-client ./cockroach sql --certs-dir=certs --host=cockroach-1:26257 -e "SELECT count(*) FROM crdb_internal.gossip_nodes" | tail -n 1)
			if [ ${NODE_NUM} -ne ${i} ]; then
				FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
				echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
				echo -e "Failed test's INPUT is ${INPUT}." 1>&2
				echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
			else
			SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
			fi
		else
			FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
			echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
			echo -e "Failed test's INPUT is ${INPUT}." 1>&2
			echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
		fi
		sleep 1

		# Delete Cluster test.
		INPUT="delete"
		OUTPUT=0
		TEST_NO=$(expr ${TEST_NO} + 1)
		echo -e "\nTest No. ${TEST_NO}."
	
		${SCRIPT} ${INPUT}
		if [ $? = ${OUTPUT} ]; then
			SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
		else
			FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
			echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
			echo -e "Failed test's INPUT is ${INPUT}." 1>&2
			echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
		fi
		sleep 1

		# Post process.
		${SCRIPT} delete force 9 > /dev/null 2>&1
		rm -rf ./${WORK_DIR_RELATIVE_PATH}
		sleep 1
	done
	sleep 1


##############################################
### CREATE and DELETE test. (Insecure Cluster)
##############################################

echo -e "\n\n\n\n###### CREATE and DELETE test (Insecure Cluster) ######"

### CREATE and DELETE with default value of the number of node test. "create" will 3 node cluster (The default value is 3).
	# Create Cluster test.
	INPUT="create insecure"
	OUTPUT=0
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		NODE_NUM=$(docker exec ${RESOURCE_NAME}-client ./cockroach sql --insecure --host=cockroach-1:26257 -e "SELECT count(*) FROM crdb_internal.gossip_nodes" | tail -n 1)
		if [ ${NODE_NUM} -ne 3 ]; then
			FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
			echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
			echo -e "Failed test's INPUT is ${INPUT}." 1>&2
			echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
		else
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
		fi
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

	# Delete Cluster test.
	INPUT="delete"
	OUTPUT=0
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

	# Post process.
	${SCRIPT} delete force 9 > /dev/null 2>&1
	rm -rf ./${WORK_DIR_RELATIVE_PATH}
	sleep 1

### CREATE and DELETE cluster that its number of nodes is from 1 to 9.
	for i in `seq 9`; do
		# Create Cluster test.
		INPUT="create insecure ${i}"
		OUTPUT=0
		TEST_NO=$(expr ${TEST_NO} + 1)
		echo -e "\nTest No. ${TEST_NO}."

		${SCRIPT} ${INPUT}
		if [ $? = ${OUTPUT} ]; then
			NODE_NUM=$(docker exec ${RESOURCE_NAME}-client ./cockroach sql --insecure --host=cockroach-1:26257 -e "SELECT count(*) FROM crdb_internal.gossip_nodes" | tail -n 1)
			if [ ${NODE_NUM} -ne ${i} ]; then
				FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
				echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
				echo -e "Failed test's INPUT is ${INPUT}." 1>&2
				echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
			else
			SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
			fi
		else
			FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
			echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
			echo -e "Failed test's INPUT is ${INPUT}." 1>&2
			echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
		fi
		sleep 1

		# Delete Cluster test.
		INPUT="delete"
		OUTPUT=0
		TEST_NO=$(expr ${TEST_NO} + 1)
		echo -e "\nTest No. ${TEST_NO}."
	
		${SCRIPT} ${INPUT}
		if [ $? = ${OUTPUT} ]; then
			SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
		else
			FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
			echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
			echo -e "Failed test's INPUT is ${INPUT}." 1>&2
			echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
		fi
		sleep 1

		# Post process.
		${SCRIPT} delete force 9 > /dev/null 2>&1
		rm -rf ./${WORK_DIR_RELATIVE_PATH}
		sleep 1
	done


#####################
### CREATE FAIL test.
#####################

echo -e "\n\n\n\n###### CREATE FAIL test ######"

### Try to CREATE cluster that its number of nodes is from 1 to 9. If there is any failure, it will return 1.
	for i in `seq 9`; do
		# Create Cluster Fail test.
		INPUT="create ${i}"
		OUTPUT=1
		TEST_NO=$(expr ${TEST_NO} + 1)
		echo -e "\nTest No. ${TEST_NO}."

		# Prepare for the test.
		# Run existing container that will conflict with the container ${SCRIPT} try to create.
		docker run -d --name ${RESOURCE_NAME}-${i} \
			--entrypoint tail \
			${IMAGE}:${VERSION} \
			-f /dev/null
		sleep 1

		# Test. The ${SCRIPT} will fail. Because the container name conflict.
		${SCRIPT} ${INPUT}
		if [ $? = ${OUTPUT} ]; then
			SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
		else
			FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
			echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
			echo -e "Failed test's INPUT is ${INPUT}." 1>&2
			echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
		fi
		sleep 1

		# Post process.
		${SCRIPT} delete force 9 > /dev/null 2>&1
		rm -rf ./${WORK_DIR_RELATIVE_PATH}
		sleep 1
	done
	sleep 1

### If creating client contaier will fail, it will return 1.
	# Prepare for the test.
	# Create existing client container that will conflict with the network ${SCRIPT} try to create.
	docker run -d --name ${RESOURCE_NAME}-client \
		--entrypoint tail \
		${IMAGE}:${VERSION} \
		-f /dev/null
	sleep 1

	INPUT="create"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

	# Post process.
	${SCRIPT} delete force 9 > /dev/null 2>&1
	rm -rf ./${WORK_DIR_RELATIVE_PATH}
	sleep 1

### If creating docker network will fail, it will return 1.
	# Prepare for the test.
	# Create existing docker network that will conflict with the network ${SCRIPT} try to create.
	docker network create ${RESOURCE_NAME}-net
	sleep 1

	INPUT="create"
	OUTPUT=1
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1

	# Post process.
	${SCRIPT} delete force 9 > /dev/null 2>&1
	rm -rf ./${WORK_DIR_RELATIVE_PATH}
	sleep 1

##############
### Misc test.
##############

echo -e "\n\n\n\n###### Misc test ######"

### "help" will return 0.
	INPUT="help"
	OUTPUT=0
	TEST_NO=$(expr ${TEST_NO} + 1)
	echo -e "\nTest No. ${TEST_NO}."

	${SCRIPT} ${INPUT}
	if [ $? = ${OUTPUT} ]; then
		SUCCESS_COUNT=$(expr ${SUCCESS_COUNT} + 1)
	else
		FAIL_COUNT=$(expr ${FAIL_COUUNT} + 1)
		echo -e "\n###### Test No. ${TEST_NO} failed." 1>&2
		echo -e "Failed test's INPUT is ${INPUT}." 1>&2
		echo -e "Expected OUTPUT is ${OUTPUT}." 1>&2
	fi
	sleep 1


# Show the result of tests.
echo -e "\n${SUCCESS_COUNT} / ${TEST_NO} test succeeded."
echo -e "${FAIL_COUNT} / ${TEST_NO} test failed."

# If some test failed, return 1.
if [ ${FAIL_COUNT} -ne 0 ]; then
	echo -e "\nSome test failed.\n"
	exit 1
else
	echo -e "\nAll tests succeeded.\n"
	exit 0
fi

exit 0
