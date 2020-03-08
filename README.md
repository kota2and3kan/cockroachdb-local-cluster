# cockroachdb-local-cluster
Bash script that creates or deletes CockroachDB Local Cluster by using Docker.  
This script deploys the swarm of cockroaches on your local environment with Docker.

## Note
For test at your local or development environment.  
Not for production.

## Prerequirement
This script uses Docker.  
You need to install Docker in your environment before run this script.

## Resources
This script will create (use) the following resources.  

Docker containers (Container names):
```
cockroach-1, cockroach-2, cockroach-3
cockroach-4, cockroach-5, cockroach-6
cockroach-7, cockroach-8, cockroach-9
cockroach-client
```

Docker network (Network name):
```
cockroach-net
```

Ports of docker host (localhost):
```
SQL access  : 26257
HTTP access : 8081, 8082, 8083, 8084, 8085, 8086, 8087, 8088, 8089
```

## Usage

### Clone this repository
```sh
$ git clone https://github.com/kota2and3kan/cockroachdb-local-cluster.git
$ cd cockroachdb-local-cluster
```

### Synopsis
```sh
$ sudo ./cockroachdb-local-cluster.sh create [insecure] [number_of_cockroaches]
$ sudo ./cockroachdb-local-cluster.sh delete [force number_of_cockroaches]
```
Note: The max number of cockroaches of this script (number_of_cockroaches) is 9.

### Create Secure Cluster
By default (Not specify the number of cockroaches), this script creates 3 node secure cluster:
```sh
$ sudo ./cockroachdb-local-cluster.sh create
```

Create 5 node secure cluster:
```sh
$ sudo ./cockroachdb-local-cluster.sh create 5
```

Create 9 node secure cluster:
```sh
$ sudo ./cockroachdb-local-cluster.sh create 9
```


After create Secure Cluster, you can access to the CockroachDB by using built-in SQL shell.  

Access DB as a root user:
```sh
$ sudo docker exec -it cockroach-client ./cockroach sql --user=root --certs-dir=certs --host=cockroach-1:26257
```

Access DB as a non-root user (user name: cockroach / password: cockroach):
```sh
$ sudo docker exec -it cockroach-client ./cockroach sql --user=cockroach --certs-dir=certs --host=cockroach-1:26257
```

Access Adim UI (Web UI) as a non-root user (user name: cockroach / password: cockroach):
```sh
https://127.0.0.1:8081/
```

### Create Insecure Cluster
By default (Not specify the number of cockroaches), this script creates 3 node insecure cluster:
```sh
$ sudo ./cockroachdb-local-cluster.sh create insecure
```

Create 5 node insecure cluster:
```sh
$ sudo ./cockroachdb-local-cluster.sh create insecure 5
```

Create 9 node insecure cluster:
```sh
$ sudo ./cockroachdb-local-cluster.sh create insecure 9
```

After create Insecure Cluster, you can access to the CockroachDB by using built-in SQL shell.  

Access DB as a root user:
```sh
$ sudo docker exec -it cockroach-client ./cockroach sql --user=root --insecure --host=cockroach-1:26257
```

Access DB as a non-root user (user name: cockroach):
```sh
$ sudo docker exec -it cockroach-client ./cockroach sql --user=cockroach --insecure --host=cockroach-1:26257
```

Access Web UI as a root user:
```sh
http://127.0.0.1:8081/
```

### Delete Cluster
```sh
$ sudo ./cockroachdb-local-cluster.sh delete
```
Note: Basically, you don't need to specify the number of cockroaches, because this script will get it from status file. If some failure occur and you want to force the delete processes, specify the "force" and "the number of cockroaches" option.

### Delete DB data
If you don't need the DB DATA of deleted cluster, remove the ./cockroach-cluster/ dir manually.
```sh
$ sudo rm -rf ./cockroach-cluster/
```

### Re-create Cluster
You can re-create the cluster with DB DATA of deleted cluster (you can re-use deleted cluster's DATA), if you want re-use old DATA, re-run this script with create option.
```sh
$ sudo ./cockroachdb-local-cluster.sh create
```
Note: You need to specify the same number of cockroaches as the deleted cluster.

### Force Delete Cluster
If there is some failure in the normal delete process (./cockroachdb-local-cluster.sh delete), you can ignore all errors and force run all delete commands (docker kill, docker rm, docker network rm) except "rm -rf ./cockroach-cluster/", by using "delete force" option.
```sh
$ sudo ./cockroachdb-local-cluster.sh delete force 9
```
Note: "delete force" will kill and remove the following containers and docker network. Please check the each resources after "delete force" processes by using the following commands.

Docker containers (you can check them by "docker container ls -a" command). There is a possibility that the following containers exist.
```
cockroach-1, cockroach-2, cockroach-3
cockroach-4, cockroach-5, cockroach-6
cockroach-7, cockroach-8, cockroach-9
cockroach-client
```

Docker network (you can check it by "docker network ls" command). There is a possibility that the following docker network exists.
```
cockroach-net
```

## License
Please refer the [LICENSE](https://github.com/kota2and3kan/cockroachdb-local-cluster/blob/master/LICENSE) for the license of the files in this repository.
