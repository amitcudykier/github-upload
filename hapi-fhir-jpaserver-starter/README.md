# HAPI-FHIR JPA Payer Test Environment

This repository used the [hapi-fhir-jpaserver-starter](https://github.com/hapifhir/hapi-fhir-jpaserver-starter) project to create a docker image of a FHIR server with loaded with test data.

For more infromation about JPA server see:
- Github: https://github.com/hapifhir/hapi-fhir-jpaserver-starter
- Documention: https://hapifhir.io/hapi-fhir/docs/server_jpa/introduction.html
- Help: https://github.com/jamesagnew/hapi-fhir/wiki/Getting-Help

## Prerequisites

In order to run this environment on your local machine, you should have [Docker](https://www.docker.com/products/docker-desktop) installed.



## Running via [Docker Hub](https://hub.docker.com/repository/docker/hapiproject/hapi)

Each tagged/released version of `hapi-fhir-jpaserver` is built as a Docker image and published to Docker hub. To run the published Docker image from DockerHub:

```
docker pull hapiproject/hapi:latest
docker run -p 8080:8080 hapiproject/hapi:latest
```

This will run the docker image with the default configuration, mapping port 8080 from the container to port 8080 in the host. Once running, you can access `http://localhost:8080/` in the browser to access the HAPI FHIR server's UI or use `http://localhost:8080/fhir/` as the base URL for your REST requests.

If you change the mapped port, you need to change the configuration used by HAPI to have the correct `hapi.fhir.tester` property/value.

### build
  Docker, as the entire project can be built using multistage docker (with both JDK and maven wrapped in docker) or used directly from [Docker Hub](https://hub.docker.com/repository/docker/hapiproject/hapi)
### Configuration via environment variables

You can customize HAPI directly from the `run` command using environment variables. For example:

```
docker run -p 8080:8080 -e hapi.fhir.default_encoding=xml hapiproject/hapi:latest
```

HAPI looks in the environment variables for properties in the [application.yaml](https://github.com/hapifhir/hapi-fhir-jpaserver-starter/blob/master/src/main/resources/application.yaml) file for defaults.

### Configuration via overridden application.yaml file and using Docker

You can customize HAPI by telling HAPI to look for the configuration file in a different location, eg.:

```
docker run -p 8090:8080 -v $(pwd)/yourLocalFolder:/configs -e "--spring.config.location=file:///configs/another.application.yaml" hapiproject/hapi:latest
```
Here, the configuration file (*another.application.yaml*) is placed locally in the folder *yourLocalFolder*.



```
docker run -p 8090:8080 -e "--spring.config.location=classpath:/another.application.yaml" hapiproject/hapi:latest
```
Here, the configuration file (*another.application.yaml*) is part of the compiled set of resources.

### Example using docker-compose.yml for docker-compose

```
version: '3.7'
services:
  web:
    image: "hapiproject/hapi:latest"
    ports:
      - "8090:8080"
    configs:
      - source: hapi
        target: /data/hapi/application.yaml
    volumes:
      - hapi-data:/data/hapi
    environment:
      SPRING_CONFIG_LOCATION: 'file:///data/hapi/application.yaml'
configs:
  hapi:
     external: true
volumes:
    hapi-data:
        external: true
```


### Using the Dockerfile and multistage build
```bash
./build-docker-image.sh && docker run -p 8080:8080 hapi-fhir/hapi-fhir-jpaserver-starter:latest
```
Server will then be accessible at http://localhost:8080/ and eg. http://localhost:8080/fhir/metadata. Remember to adjust you overlay configuration in the application.yaml to eg.

```yaml
    tester:
      -
          id: home
          name: Local Tester
          server_address: 'http://localhost:8080/fhir'
          refuse_to_fetch_third_party_urls: false
          fhir_version: R4
```

## Configurations

Much of this HAPI starter project can be configured using the yaml file in _src/main/resources/application.yaml_. By default, this starter project is configured to use H2 as the database.

### MySql configuration

To configure the starter app to use MySQL, instead of the default H2, update the application.yaml file to have the following:

```yaml
spring:
  datasource:
    url: 'jdbc:mysql://localhost:3306/hapi_dstu3'
    username: admin
    password: admin
    driverClassName: com.mysql.jdbc.Driver
```
On some systems, it might be necessary to override hibernate's default naming strategy. The naming strategy must be set using spring.jpa.hibernate.physical_naming_strategy. 

```yaml
spring:
  jpa:
    hibernate.physical_naming_strategy: NAME_OF_PREFERRED_STRATEGY
```
On linux systems or when using docker mysql containers, it will be necessary to review the case-sensitive setup for
mysql schema identifiers. See  https://dev.mysql.com/doc/refman/8.0/en/identifier-case-sensitivity.html. We suggest you
set `lower_case_table_names=1` during mysql startup.

### PostgreSQL configuration

To configure the starter app to use PostgreSQL, instead of the default H2, update the application.yaml file to have the following:

```yaml
spring:
  datasource:
    url: 'jdbc:postgresql://localhost:5432/hapi_dstu3'
    username: admin
    password: admin
    driverClassName: org.postgresql.Driver
```

Because the integration tests within the project rely on the default H2 database configuration, it is important to either explicity skip the integration tests during the build process, i.e., `mvn install -DskipTests`, or delete the tests altogether. Failure to skip or delete the tests once you've configured PostgreSQL for the datasource.driver, datasource.url, and hibernate.dialect as outlined above will result in build errors and compilation failure.

## Customizing The Web Testpage UI

The UI that comes with this server is an exact clone of the server available at [http://hapi.fhir.org](http://hapi.fhir.org). You may skin this UI if you'd like. For example, you might change the introductory text or replace the logo with your own.

The UI is customized using [Thymeleaf](https://www.thymeleaf.org/) template files. You might want to learn more about Thymeleaf, but you don't necessarily need to: they are quite easy to figure out.

Several template files that can be customized are found in the following directory: [https://github.com/hapifhir/hapi-fhir-jpaserver-starter/tree/master/src/main/webapp/WEB-INF/templates](https://github.com/hapifhir/hapi-fhir-jpaserver-starter/tree/master/src/main/webapp/WEB-INF/templates)


## Deploy with docker compose

Docker compose is a simple option to build and deploy container. To deploy with docker compose, you should build the project
with `mvn clean install` and then bring up the containers with `docker-compose up -d --build`. The server can be
reached at http://localhost:8080/.

In order to use another port, change the `ports` parameter
inside `docker-compose.yml` to `8888:8080`, where 8888 is a port of your choice.

The docker compose set also includes my MySQL database, if you choose to use MySQL instead of H2, change the following
properties in application.yaml:

```yaml
spring:
  datasource:
    url: 'jdbc:mysql://hapi-fhir-mysql:3306/hapi'
    username: admin
    password: admin
    driverClassName: com.mysql.jdbc.Driver
```

## Build the distroless variant of the image (for lower footprint and improved security)

The default Dockerfile contains a `release-distroless` stage to build a variant of the image
using the `gcr.io/distroless/java-debian10:11` base image:

```sh
docker build --target=release-distroless -t hapi-fhir:distroless .
```

Note that distroless images are also automatically build and pushed to the container registry,
see the `-distroless` suffix in the image tags.

