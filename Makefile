VERSION_FILE := version
VERSION := $(shell cat ${VERSION_FILE})
ACR_NAME := ghactionskvacr
REPO_NAME := upgrade-test
IMAGE_REPO := $(ACR_NAME).azurecr.io/$(REPO_NAME)
KV := ghactionsavkv


.PHONY: build
build:
	docker build -t $(IMAGE_REPO):$(VERSION) .

.PHONY: registry-login
registry-login:
	@az login \
		--service-principal \
		--username $(SERVICE_PRINCIPAL_APP_ID) \
		--password $(SERVICE_PRINCIPAL_SECRET) \
		--tenant $(SERVICE_PRINCIPAL_TENANT)
	@az acr login --name ghactionskvacr

.PHONY: push
push:
	docker push $(IMAGE_REPO):$(VERSION)

.PHONY: verify
verify:
	./verify.sh $(ACR_NAME) $(REPO_NAME) $(KV)
.PHONY: deploy
deploy:
	sed 's|IMAGE_REPO|$(IMAGE_REPO)|g; s/VERSION/$(VERSION)/g' ./deployment.yaml | \
		kubectl apply -f -