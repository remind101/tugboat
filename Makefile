.PHONY: cmd

cmd:
	godep go build -o build/tugboat ./cmd/tugboat
