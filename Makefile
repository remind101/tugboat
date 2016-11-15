.PHONY: cmd docker

cmd:
	go build -o build/tugboat ./cmd/tugboat
	go build -o build/fake ./cmd/fake

docker:
	docker build --no-cache -t remind101/tugboat .

test:
	go test -race $(shell go list ./... | grep -v /vendor/)
