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
docker run -d --restart=always \
  --name='cbioDB' \
  --net=cbio-net \
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
docker logs -f cbioDB
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

If you want to change any variable defined in portal.properties,
have a look [here](adjusting_portal.properties_configuration.md).
If you want to build an image based on a different branch, you can
read [this](adjusting_Dockerfile_configuration.md).

#### Step 4 - Update the database schema
Update the seeded database schema to match the cBioPortal version
in the image, by running the following command. Note that this will
most likely make your database irreversibly incompatible with older
versions of the portal code.

```
docker run --rm -it --net cbio-net \
    cbioportal-image \
    migrate_db.py -p /cbioportal/src/main/resources/portal.properties -s /cbioportal/db-scripts/src/main/resources/migration.sql
```

#### Step 5 - Run the cBioPortal web server
```
docker run -d --restart=always \
    --name=cbioportal-container \
    --net=cbio-net \
    -e CATALINA_OPTS='-Xms2g -Xmx4g' \
    -p 8081:8080 \
    cbioportal-image
```

On server systems that can easily spare 4 GiB or more of memory,
set the `-Xms` and `-Xmx` options to the same number. This should
increase performance of certain memory-intensive web services such
as computing the data for the co-expression tab. If you are using
MacOS or Windows, make sure to take a look at [these
notes](notes-for-non-linux.md) to allocate more memory for the
virtual machine in which all Docker processes are running.

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


##### https://hub.docker.com/r/thehyve/cbioportal/
##### https://github.com/thehyve/cbioportal-docker
```
sudo docker network create cbio-net
docker run -d --restart=always \
  --name=cbioDB \
  --net=cbio-net \
  -e MYSQL_ROOT_PASSWORD='P@ssword1' \
  -e MYSQL_USER=cbio \
  -e MYSQL_PASSWORD='P@ssword1' \
  -e MYSQL_DATABASE=cbioportal \
  mysql:5.7
```
#### use version 5.7
```
docker run \
  --name=load-seeddb \
  --net=cbio-net \
  -e MYSQL_USER=cbio \
  -e MYSQL_PASSWORD='P@ssword1' \
  -v /your/directory/path/cgds.sql:/mnt/cgds.sql:ro \
  -v /your/directory/path/seed-cbioportal_no-pdb_hg19.sql.gz:/mnt/seed.sql.gz:ro \
  mysql:5.7 \
  sh -c 'cat /mnt/cgds.sql | mysql -hcbioDB -ucbio -pP@ssword1 cbioportal \
      && zcat /mnt/seed.sql.gz |  mysql -hcbioDB -ucbio -pP@ssword1 cbioportal'
```
### Build docker image cbioportal 
#### https://github.com/thehyve/cbioportal-docker/blob/master/docs/adjusting_configuration.md
#### Fork github https://github.com/thehyve/cbioportal-docker 
#### Edit portal.properties file in local instance /home/cbioportal-docker
#### Change cbioDB user, password, etc.
#### Edit docker.file 
#### Change portal.properties file and log4.properties file location

#### Build docker images with below command
```
docker build -t cbioportal-image .
```
#### Migration is neccessory
```
docker run --rm -it --net cbio-net \
    cbioportal-image \
    migrate_db.py -p /cbioportal/src/main/resources/portal.properties -s /cbioportal/db-scripts/src/main/resources/migration.sql
```
```
docker run -d --restart=always \
    --name=cbioportal-container \
    --net=cbio-net \
    -e CATALINA_OPTS='-Xms2g -Xmx4g' \
    -p 8081:8080 \
    cbioportal-image
```

#### Import study 

##### VEP install
##### genome reference (16g) download from Ensembl takes long time (3days)

```
docker run --rm --net cbio-net \
    -v "$PWD/portalinfo:/portalinfo" \
    -w /cbioportal/core/src/main/scripts \
    cbioportal-image \
    ./dumpPortalInfo.pl /portalinfo
```
```
docker run -it --rm --net cbio-net \
    -v "$PWD:/study:ro" \
    -v "$HOME/Desktop:/outdir" \
    -v "$PWD/portalinfo:/portalinfo:ro" \
    cbioportal-image \
    metaImport.py -p /portalinfo -s /study -v -o
```
```
docker restart cbioportal-container
```

```
docker run -d --restart=always \
    --name=kcdb \
    --net=kcnet \
    -e MYSQL_DATABASE=keycloak \
    -e MYSQL_USER=keycloak \
    -e MYSQL_PASSWORD='P@ssword1' \
    -e MYSQL_ROOT_PASSWORD='P@ssword1' \
    mysql:5.7
```
```
docker run -d --restart=always \
    --name=cbiokc \
    --net=kcnet \
    -p 8180:8080 \
    -e MYSQL_PORT_3306_TCP_ADDR=kcdb \
    -e MYSQL_PORT_3306_TCP_PORT=3306 \
    -e KEYCLOAK_USER=admin \
    -e KEYCLOAK_PASSWORD='P@ssword1' \
    jboss/keycloak
```
```
docker restart cbiokc
```
```
keytool -genkey -alias secure-key -keyalg RSA -keystore samlKeystore.jks
```

This will create a Java keystore for a key called: secure-key and place the keystore in a file named samlKeystore.jks. You will be prompted for:
keystore password (required, for example: apollo1)
your name, organization and location (optional)
key password for secure-key (required, for example apollo2)
valid redirect URIs http://10.***.***:8081/cbioportal/*
clients → cbioportal → mappers → create → name (roles) mapper type (role list)

