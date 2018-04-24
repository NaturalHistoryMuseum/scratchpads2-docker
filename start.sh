# This script is an alternative to creating a stack

# Make sure webserver container is built & network is created
docker build -t sp2 .
docker network create sp_drupal

# Start & connect web server & mysql containers
echo ""
echo Starting webserver on http://localhost:8080 ...
echo ""

docker run --network=sp_drupal -p8080:80 --name=sp_apache -e MYSQL_PASSWORD=platypodes -e MYSQL_USER=root -e MYSQL_HOST=sp_db -e MYSQL_DATABASE=sp2 sp2 &
docker run --network=sp_drupal -e MYSQL_ROOT_PASSWORD=platypodes -e MYSQL_DATABASE=sp2 --name=sp_db -v "$(pwd)"/data:/var/lib/mysql mysql:5.6 &

# Shut down on interrupt
trap_stop () {
    echo ""
    echo "Stopping..."
    docker stop sp_apache
    docker rm sp_apache
    docker stop sp_db
    docker rm sp_db
}

trap trap_stop INT TERM

# Prevent exit until services have stopped
wait