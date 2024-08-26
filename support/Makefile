TARGET = rtlsdr-idris
TARGET_VERSION ?= 0.1.0

INSTALLDIR = ../lib

LDFLAGS = `pkg-config --libs librtlsdr`

SRCS = $(wildcard *.c)
OBJS = $(SRCS:.c=.o)

CC_VERSION = $(shell $(CC) --version)

ifeq ($(findstring clang,$(CC_VERSION)),clang)
 DYLIB_WORKAROUND = cp "${INSTALLDIR}/${TARGET}" "${INSTALLDIR}/${TARGET}.dylib"
else
 DYLIB_WORKAROUND = cp "${INSTALLDIR}/${TARGET}" "${INSTALLDIR}/${TARGET}.so"
 LDFLAGS += -fuse-ld=gold
endif

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) -shared $(LDFLAGS) -o $@ $^

.PHONY: clean
clean:
	rm -f $(OBJS) $(TARGET) $(TARGET)
	rm -rf $(INSTALLDIR)

.PHONY: install
install:
	mkdir -p $(INSTALLDIR)
	install $(TARGET) $(wildcard *.h) $(INSTALLDIR)
	$(DYLIB_WORKAROUND)

