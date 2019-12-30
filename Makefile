BUILD_IMAGE := golang:1.13
OS := $(if $(GOOS),$(GOOS),$(shell go env GOOS))
ARCH := $(if $(GOARCH),$(GOARCH),$(shell go env GOARCH))
OUTDIR := bin
DISTDIR := dist
BUILD_COMMAND := docker run --rm  \
                 	-u $$(id -u):$$(id -g) \
                 	-v $$(pwd):/src \
                 	-v $$(pwd)/.go/bin:/go/bin                \
                    -v $$(pwd)/.go/cache:/.cache                       \
                     -w /src
DOCKER_BUILD_COMMAND := /bin/sh "./scripts/build.sh"
DOCKER_GENERATE_COMMAND := /bin/sh "./scripts/generate.sh"
LAMBDA_HANDLER_NAMES := $(notdir $(wildcard cmd/*))
ZIPS := $(addprefix $(DISTDIR)/, $(addsuffix .zip, $(LAMBDA_HANDLER_NAMES)))
INTERNAL_DIR := internal
MOCK_DIR := mocks
SOURCE_FILES := $(wildcard $(INTERNAL_DIR)/*/*.go)
MOCK_FILES := $(patsubst $(INTERNAL_DIR)%, $(MOCK_DIR)%, $(SOURCE_FILES))

.PHONY: clean build all dist generate-mocks

define ENV
@echo 'Docker image: ${BUILD_IMAGE}'
@echo 'OS          : ${OS}'
@echo 'ARCH        : ${ARCH}'
endef

clean:
	@rm -rf .go
	@rm -rf ${DISTDIR}
	@rm -rf ${OUTDIR}

build: clean
	@echo 'building project'
	$(ENV)
	$(BUILD_COMMAND) --env ARCH=${ARCH} --env OS=${OS} $(BUILD_IMAGE) $(DOCKER_BUILD_COMMAND)
	[[ -d $(OUTDIR) ]] || mkdir $(OUTDIR)
	cp -r ./.go/bin/ $(OUTDIR)
#Builds the executuable for createOrderLambda
build-lambda: OS := "linux"
build-lambda: clean
	@echo ${OS}
	$(BUILD_COMMAND) --env ARCH=${ARCH} --env OS=${OS} $(BUILD_IMAGE) $(DOCKER_BUILD_COMMAND)
	[[ -d $(OUTDIR) ]] || mkdir $(OUTDIR)
	cp -r ./.go/bin/ $(OUTDIR)

$(ZIPS) : build-lambda
	@echo  $@ $*
	[[ -d $(DISTDIR) ]] || mkdir $(DISTDIR)
	@zip -j -o $@ $(OUTDIR)/$(basename $(notdir $@))

dist: $(ZIPS)

deploy:
	terraform init deployments/terraform
	terraform apply deployments/terraform

destroy:
	terraform init deployments/terraform
	terraform destroy deployments/terraform

$(MOCK_FILES): $(SOURCE_FILES)
	[[ -d $(MOCK_DIR) ]] || mkdir $(MOCK_DIR)
	mockgen -source $(patsubst $(MOCK_DIR)%, $(INTERNAL_DIR)%, $@) --destination $@

generate-mocks:
	docker run --rm  -v $$(pwd):/src -w /src $(BUILD_IMAGE) $(DOCKER_GENERATE_COMMAND)

