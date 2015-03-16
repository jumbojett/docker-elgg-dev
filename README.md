# docker-elgg-dev
Elgg development environment on docker.

# Quick start
1. Download or clone the Elgg version you want to work with.
2. Run the docker image mounting Elgg as the volume /app. If you're on Windows or OS X
   and use boot2docker, remember it mounts your C:\Users or /Users directory in the 
   dev VM, so adjust paths accordingly.
3. There are a number of environment variables that affect how the the container is built.
   See run.sh for a list.
4. After the container is built, the credentials for Elgg and MySQL if not supplied are printed
   if they weren't supplied via enviroment variables.
5. Depending on how you're running docker, you may need to expose ports. You can easily
   expose all ports by using `docker run -P ...`.
