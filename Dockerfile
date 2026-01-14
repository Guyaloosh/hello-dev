# ---- Build stage ----
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /workspace

# Copy only pom first to leverage layer caching
COPY myapp/pom.xml myapp/pom.xml
RUN mvn -f myapp/pom.xml -B -q dependency:go-offline

# Copy sources and build
COPY myapp/src myapp/src
RUN mvn -f myapp/pom.xml -B clean package

# ---- Runtime stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app

# Create non-root user
RUN useradd -r -u 10001 appuser
USER appuser

# Copy the built jar from the build stage
COPY --from=build /workspace/myapp/target/*.jar /app/app.jar

ENTRYPOINT ["java","-jar","/app/app.jar"]