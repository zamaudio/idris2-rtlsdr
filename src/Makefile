LDFLAGS = `pkg-config --libs librtlsdr`

IDRIS := idris2
INSTALLDIR = `${IDRIS} --libdir`/rtlsdr-0.1.0/

TARGET = idris_rtlsdr

SRCS = $(wildcard *.c)
OBJS = $(SRCS:.c=.o)

all: $(TARGET).so

$(TARGET).so: $(OBJS)
	$(CC) -fPIC -shared $(LDFLAGS) -o $@ $^

clean: .PHONY
	rm -f $(OBJS) $(TARGET).so

install:
	install $(TARGET).so $(INSTALLDIR)

