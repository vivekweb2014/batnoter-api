.PHONY: network postgres createdb dropdb migrateup migratedown addmigration test

network:
	docker network create gn-network

postgres:
	docker run --name postgres12 --network gn-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:12-alpine

createdb:
	docker exec -it postgres12 createdb --username=root --owner=root bn_db
	docker exec -it postgres12 sh -c "psql -U root -d bn_db -c \"CREATE SCHEMA IF NOT EXISTS batnoter;\" "

dropdb:
	docker exec -it postgres12 dropdb bn_db

# `up` migration is supported by application with cobra command
migrateup:
	go run main.go migrateup

migratedown:
	migrate -path migrations -database "postgresql://root:secret@localhost:5432/bn_db?search_path=batnoter&sslmode=disable" -verbose down

addmigration:
	migrate create -ext sql -dir migrations ${file}

test:
	go test -v -cover ./...
