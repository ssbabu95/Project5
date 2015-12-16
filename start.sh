#!/bin/sh
PWD=${PWD}
git clone https://github.com/ssbabu95/cs4501-models.git
docker run -d --name models -p 8001:8000 -v $PWD/cs4501-models:/app --link mysql:db tp33/django:1.1 mod_wsgi-express start-server cs4501/wsgi.py
docker exec models python manage.py makemigrations
docker exec models python manage.py migrate
docker run -d --name kafka --env ADVERTISED_HOST=kafka --env ADVERTISED_PORT=9092 spotify/kafka
docker run -d -p 9200:9200 --name es elasticsearch:2.0 -Des.network.host=es
git clone https://github.com/ssbabu95/cs4501-exp.git
docker run -d --name exp -p 8002:8000 -v $PWD/cs4501-exp:/app --link models:models-api --link kafka:kafka --link es:es tp33/django:1.1 mod_wsgi-express start-server cs4501/wsgi.py
git clone https://github.com/ssbabu95/cs4501-web.git
docker run --name my-memcache -d memcached
docker run -d --name web -p 8000:8000 -v $PWD/cs4501-web:/app --link exp:exp-api --link mymemcache:memcache tp33/django:1.1 mod_wsgi-express start-server cs4501/wsgi.py
docker exec pip install python-memcached
git clone https://github.com/ssbabu95/batch.git
docker run -it --name batch -v $PWD/batch:/app --link kafka:kafka --link es:es tp33/django:1.1
