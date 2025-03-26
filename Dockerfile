FROM openjdk:12-alpine

WORKDIR /app

COPY app/ .

RUN ./gradlew build # recompile l'application

EXPOSE 5000

ENTRYPOINT [ "java", "-jar", "./build/libs/theme-park-ride-gradle.jar"]
#HEALTHCHECK --interval=5m --timeout=3s --retries=3 \
#CMD curl -f http://localhost:5000/ || exit 1
