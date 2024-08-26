TARGET = rtlsdr-idris
TARGET_VERSION ?= 0.1.0

IDRIS := idris2
INSTALLDIR = `${IDRIS} --libdir`/rtlsdr-0.1.0/

LDFLAGS = `pkg-config --libs librtlsdr`

SRCS = $(wildcard *.c)
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) -fPIC -shared $(LDFLAGS) -o $@ $^

.PHONY: clean
clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: install
install:
	cp $(TARGET) $(TARGET).so
	install $(TARGET).so $(wildcard *.h) $(INSTALLDIR)

