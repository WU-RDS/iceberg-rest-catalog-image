#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
FROM azul/zulu-openjdk:17 as builder

COPY . /app/
WORKDIR /app/

RUN ["./gradlew", "build", "shadowJar"]

FROM azul/zulu-openjdk:17-jre-headless

RUN \
    set -xeu && \
    groupadd iceberg --gid 1000 && \
    useradd iceberg --uid 1000 --gid 1000 --create-home

COPY --from=builder --chown=iceberg:iceberg /app/build/libs/iceberg-rest-image-all.jar /usr/lib/iceberg-rest/iceberg-rest-image-all.jar

# env vars prefixed with CATALOG_ are forwarded to the catalog that is used 'under the hood' (e.g. JDBC catalog)
# the catalog implementation to use 'under the hood'
ENV CATALOG_CATALOG__IMPL=org.apache.iceberg.jdbc.JdbcCatalog
# the catalog IO implementation to use - need to set to org.apache.iceberg.aws.s3.S3FileIO if data should be stored in S3
ENV CATALOG_IO__IMPL=org.apache.iceberg.aws.s3.S3FileIO
# config specific to JDBC catalog
# use in-memory SQLite DB per default
ENV CATALOG_URI=jdbc:sqlite::memory:
ENV CATALOG_JDBC_USER=user
ENV CATALOG_JDBC_PASSWORD=password

# Port on which server should listen
ENV REST_PORT=8181
EXPOSE $REST_PORT

USER iceberg:iceberg
ENV LANG en_US.UTF-8
WORKDIR /usr/lib/iceberg-rest
CMD ["java", "-jar", "iceberg-rest-image-all.jar"]
