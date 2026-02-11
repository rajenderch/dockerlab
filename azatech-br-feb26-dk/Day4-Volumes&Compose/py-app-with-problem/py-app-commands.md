problem statemnt 

docker run -d -p 9010:8000 --name pyflask01 pyflask:v1

docker run -d -p 6379:6379 --name redis redis:alpine

with the above commands, python container is not able to talk to redis container , even though thehost name is redis

============================
using link we can kind of solve the problem 

docker rm pyflask01 -f

docker run -d -p 9010:8000 --link redis:redis --name pyflask01 pyflask:v1