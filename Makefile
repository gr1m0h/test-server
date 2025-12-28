# test:
# 	go test -v -cover -covermode=atmic ./...

docker-build:
	docker build -t test-server .

docker-run: docker-build
	docker-cli-plugin-docker-compose -f docker-compose.yaml up --build -d

docker-stop:
	docker-cli-plugin-docker-compose -f docker-compose.yaml down -v

replace-local-modules:
	go mod edit -replace github.com/gr1m0h/test-server/article/delivery/http=./article/delivery/http
	go mod edit -replace github.com/gr1m0h/test-server/article/delivery/http/middleware=./article/delivery/http/middleware
	go mod edit -replace github.com/gr1m0h/test-server/article/repository/mysql=./article/repository/mysql
	go mod edit -replace github.com/gr1m0h/test-server/article/usecase=./article/usecase
	go mod edit -replace github.com/gr1m0h/test-server/author/repository/mysql=./author/repository/mysql

gen-grpc-code:
	protoc --go_out=pb ./proto/test.proto
