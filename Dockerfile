# Use a base image with Maven to build the application
FROM maven:3.9.5 AS builder
ARG ENV=dev
ENV ENV=${ENV}
RUN echo ${ENV}
COPY . /usr/src/app
COPY pom.xml /usr/src/app/pom.xml
COPY conf/application-${ENV}.yml /usr/src/app/application.yml
WORKDIR /usr/src/app
RUN mvn clean install
FROM openjdk:21-jdk
WORKDIR /app
COPY --from=builder /usr/src/app/target/*.jar app.jar
COPY --from=builder /usr/src/app/application.yml application.yml
CMD ["java", "-jar", "app.jar","--spring.config.location=application.yml"]
