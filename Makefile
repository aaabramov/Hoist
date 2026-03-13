SKYLIGHT_AVAILABLE := $(shell test -d /System/Library/PrivateFrameworks/SkyLight.framework && echo 1 || echo 0)
override CXXFLAGS += -O2 -Wall -fobjc-arc -D"NS_FORMAT_ARGUMENT(A)=" -D"SKYLIGHT_AVAILABLE=$(SKYLIGHT_AVAILABLE)"

APP_NAME ?= AutoRaise
BUNDLE_ID ?= com.iamandrii.autoraise

SRCS = AutoRaiseGlobals.mm AutoRaiseHelpers.mm AutoRaiseConfig.mm AutoRaiseUI.mm AutoRaiseWatcher.mm AutoRaiseMain.mm
OBJS = $(SRCS:.mm=.o)

FRAMEWORKS = -framework AppKit -framework ServiceManagement
ifeq ($(SKYLIGHT_AVAILABLE), 1)
    FRAMEWORKS += -F /System/Library/PrivateFrameworks -framework SkyLight
endif

.PHONY: all clean install build dev run debug update

all: AutoRaise AutoRaise.app

clean:
	rm -f AutoRaise AutoRaiseDev *.o
	rm -rf AutoRaise.app AutoRaiseDev.app

install: AutoRaise.app
	rm -rf /Applications/AutoRaise.app
	cp -r AutoRaise.app /Applications/

%.o: %.mm AutoRaise.h
	g++ $(CXXFLAGS) -c -o $@ $<

AutoRaise: $(OBJS)
	g++ $(CXXFLAGS) -o $@ $^ $(FRAMEWORKS)

AutoRaise.app: AutoRaise Info.plist AutoRaise.icns
	./create-app-bundle.sh $(APP_NAME) $(BUNDLE_ID)

build: clean
	make CXXFLAGS="-DOLD_ACTIVATION_METHOD -DEXPERIMENTAL_FOCUS_FIRST"

dev: clean
	make APP_NAME=AutoRaiseDev BUNDLE_ID=com.iamandrii.autoraise.dev CXXFLAGS="-DOLD_ACTIVATION_METHOD -DEXPERIMENTAL_FOCUS_FIRST"
	cp AutoRaise AutoRaiseDev

run: dev
	./AutoRaiseDev

debug: dev
	./AutoRaiseDev -verbose 1

update: build install
