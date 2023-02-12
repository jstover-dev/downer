
default:
	@echo "Try make start"

update:
	docker-compose down
	docker-compose pull
	docker-compose build

start:
	docker-compose up -d
	docker-compose logs --tail 200 -f
