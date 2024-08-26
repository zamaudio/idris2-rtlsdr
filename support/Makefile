TARGET = rtlsdr-idris
TARGET_VERSION ?= 0.1.0

INSTALLDIR = ../lib

LDFLAGS = `pkg-config --libs librtlsdr`

SRCS = $(wildcard *.c)
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) -fPIC -shared $(LDFLAGS) -o $@ $^

DYLIB_WORKAROUND = cp $(TARGET) $(TARGET).so

.PHONY: clean
clean:
	rm -f $(OBJS) $(TARGET) $(TARGET).so
	rm -rf $(INSTALLDIR)

.PHONY: install
install:
	mkdir -p $(INSTALLDIR)
	$(DYLIB_WORKAROUND)
	install $(TARGET).so $(wildcard *.h) $(INSTALLDIR)

