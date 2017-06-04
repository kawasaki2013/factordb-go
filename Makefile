GOFILES    := $(shell find . -name '*.go' -not -path './vendor/*')
GOPACKAGES := $(shell go list ./... | grep -v /vendor/)
NAME       := factordb
DIST_DIRS  := find * - type d -exec


.DEFAULT_GOAL := bin/$(NAME)
bin/$(NAME): $(GOFILES)
	go build -o bin/$(NAME)

.PHONY: clean
clean:
	rm -rf vendor
	rm -rf bin/*
	rm -rf dist/*

.PHONY: cross-build
cross-build:
	for os in darwin linux windows; do \
		for arch in amd64 i386; do \
			GOOS=$$os GOARCH=$$arch CGO_ENABLED=0 go build -a dist/$$os-$$arch/$(NAME); \
    done; \
  done

.PHONY: deps
deps: glide
	glide install

.PHONY: dist
dist:
	cd dist && \
	$(DIST_DIRS) cp ../LICENSE {} \; && \
	$(DIST_DIRS) cp ../README.md {} \; && \
	$(DIST_DIRS) tar -zcf $(NAME)-$(VERSION)-{}.tar.gz {} \; && \
	$(DIST_DIRS) zip -r $(NAME)-$(VERSION)-{}.zip {} \; && \
	cd ..

.PHONY: build
build:
	go build $(LDFLAGS) -o bin/$(NAME)

.PHONY: glide
glide:
ifeq ($(shell command -v glide 2> /dev/null),)
	curl https://glide.sh/get | sh
endif

.PHONY: install
install:
	go install $(LDFLAGS)

test:
	go test -v $(GOPACKAGES)
