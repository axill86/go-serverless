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
LAMBDA_HANDLER_NAMES := $(notdir $(wildcard cmd/*))
ZIPS := $(addprefix $(DISTDIR)/, $(addsuffix .zip, $(LAMBDA_HANDLER_NAMES)))


.PHONY: clean build all

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
#Builds the executuable for lambda
build-lambda: OS := "linux"
build-lambda: clean
	@echo ${OS}
	$(BUILD_COMMAND) --env ARCH=${ARCH} --env OS=${OS} $(BUILD_IMAGE) $(DOCKER_BUILD_COMMAND)
	[[ -d $(OUTDIR) ]] || mkdir $(OUTDIR)
	cp -r ./.go/bin/ $(OUTDIR)

$(ZIPS) : build-lambda
	@echo  $@ $*
	[[ -d $(DISTDIR) ]] || mkdir $(DISTDIR)
	zip -o $@ $(OUTDIR)/$(basename $(notdir $@))

dist: $(ZIPS)

echo:
	@echo $(ZIPS)


