# cbioportal-docker

Download and install Docker from www.docker.com.

[Notes for non-Linux systems](notes-for-non-linux.md)


#### Step 1 - Setup network
Create a network in order for the cBioPortal container and mysql database to communicate.
```
docker network create cbio-net
```

#### Step 2 - Run mysql with seed database
Download the seed database from [datahub seedDB space]( https://github.com/cBioPortal/datahub/blob/master/seedDB/README.md)

The command below imports the downloaded seed database files in
`/<path_to_seed_database>/` into a database stored in
`/<path_to_save_mysql_db>/db_files/` (these should be absolute
paths), before starting the MySQL server.

:warning: This process can take about 45 minutes. For much faster
loading, we can choose to not load the PDB data, by removing the
line that loads `cbioportal-seed_only-pdb.sql.gz`. Please note that
your instance will be missing the 3D structure view feature (in the
mutations view) if you chose to leave this out.

```
docker run -d --name "cbioDB" \
  --restart=always \
  --net=cbio-net \
  -p 8306:3306 \
  -e MYSQL_ROOT_PASSWORD=P@ssword1 \
  -e MYSQL_USER=cbio \
  -e MYSQL_PASSWORD=P@ssword1 \
  -e MYSQL_DATABASE=cbioportal \
  -v /<path_to_save_mysql_db>/db_files/:/var/lib/mysql/ \
  -v /<path_to_seed_database>/cgds.sql:/docker-entrypoint-initdb.d/cgds.sql:ro \
  -v /<path_to_seed_database>/seed-cbioportal_no-pdb_hg19.sql.gz:/docker-entrypoint-initdb.d/seed_part1.sql.gz:ro \
  -v /<path_to_seed_database>/seed-cbioportal_only-pdb.sql.gz:/docker-entrypoint-initdb.d/seed_part2.sql.gz:ro \
  mysql
```

Make sure to follow the logs of this step to ensure no errors occur. Run this command:
```
sudo docker logs -f cbioDB
``` 
If any error occurs, make sure to check it. A common cause is pointing the `-v` parameters above to folders or files that do not exist.

#### Step 3 - Build the Docker image containing cBioPortal
Checkout the repository, enter the directory and run build the image.

```
git clone https://github.com/thehyve/cbioportal-docker.git
cd cbioportal-docker
docker build -t cbioportal-image .
```

Alternatively, if you do not wish to change anything in the Dockerfile or the properties, you can run:

```
docker build -t cbioportal-image https://github.com/thehyve/cbioportal-docker.git
```

#### Step 4 - Update the database schema
Update the seeded database schema to match the cBioPortal version
in the image, by running the following command. Note that this will
most likely make your database irreversibly incompatible with older
versions of the portal code.

```
docker run --rm -it --net cbio-net \
    cbioportal-image \
    migrate_db.py -p /cbioportal/src/main/resources/portal.properties -s /cbioportal/db-scripts/src/main/resources/db/migration.sql
```

#### Step 5 - Run the cBioPortal web server
```
docker run -d --name="cbioportal-container" \
  --restart=always \
  --net=cbio-net \
  -p 8081:8080 \
  cbioportal-image
```

cBioPortal can now be reached at http://localhost:8081/cbioportal/

Activity of Docker containers can be seen with:
```
docker ps -a
```

## Uninstalling cBioPortal
First we stop the Docker containers.
```
docker stop cbioDB
docker stop cbioportal-container
```

Then we remove the Docker containers.
```
docker rm cbioDB
docker rm cbioportal-container
```

Cached Docker images can be seen with:
```
docker images
```

Finally we remove the cached Docker images.
```
docker rmi mysql
docker rmi cbioportal-image
```

## Data Loading & More commands

For more uses of the cBioPortal image, see [example_commands.md](example_commands.md)
