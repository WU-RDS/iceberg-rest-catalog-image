# Iceberg REST Catalog Server
The Catalog Server to be used in our Iceberg setup. At this moment (4th December 2023), its implementation doesn't differ in any significant way from the template it was forked from.

Per default, a JDBC catalog is used (with SQLite as the DB).

## Run Java build locally
After executing `gradle build`, run `java -jar ./build/libs/iceberg-rest-image-all.jar`.

## Build Docker image
The docker image builds the Java project and puts the build in a docker container that can then be used to run the server.
```bash
docker build -t wu-rds/iceberg-rest-catalog .
```

## Configuration
Any env vars you want to pass to configure the catalog further need to be prefixed with `CATALOG_`.
When running this server locally

### Catalog implementation
By default, the JDBC catalog is used 'under the hood'. A different catalog implementation can be specified via `CATALOG__CATALOG_IMPLEMENTATION`. For instance, running
```bash
export CATALOG_CATALOG__IMPL=org.apache.iceberg.aws.glue.GlueCatalog
```
before starting the server means that a Glue catalog will be used.

### JDBC catalog
To use a different database with the JDBC catalog, simply specify a different JDBC connection string URI for the JDBC catalog (which is used by default), execute
```bash
export CATALOG_URI=jdbc:sqlite:file:/data/db.sqlite
```
The example above will use SQLite for the DB connection and write the catalog DB to a `db.sqlite` file in `data`.
Make sure the folder exists!

### S3
For a catalog that uses S3 storage to persist the data and metadata, the following variables need to added:
```env
AWS_ACCESS_KEY_ID=thekeyid
AWS_REGION=eu-central-2
AWS_SECRET_ACCESS_KEY=thesecret
CATALOG_IO__IMPL=org.apache.iceberg.aws.s3.S3FileIO
CATALOG_S3_ENDPOINT=https://s3.eu-central-2.wasabisys.com # if using Wasabi S3
CATALOG_WAREHOUSE=s3://bucketname/path/where/catalog/should/reside
```