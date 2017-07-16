##Docker MongoDB Setup
docker run --name mongo -p 31564:27017 -v /coding/mongodb/db:/data/db -d mongo:latest --storageEngine wiredTiger
