FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /src
COPY pom.xml ./
RUN mvn -q -B dependency:go-offline
COPY src ./src
RUN mvn -q -B package -DskipTests

FROM eclipse-temurin:21-jre
RUN apt-get update && apt-get install -y --no-install-recommends wget && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /src/target/*.jar app.jar
EXPOSE 8081
HEALTHCHECK --interval=5s --timeout=3s --start-period=20s --retries=10 \
  CMD wget -q -O- http://localhost:8081/healthz || exit 1
ENTRYPOINT ["java", "-jar", "app.jar"]
