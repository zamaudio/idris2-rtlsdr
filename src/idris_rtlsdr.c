#include <stdlib.h>
#include <stdio.h>

#include <rtl-sdr.h>

#include "idris_rtlsdr.h"

/* obviously not thread safe */
static int idris_rtlsdr_errno = 0;

int idris_rtlsdr_get_errno(void)
{
	return idris_rtlsdr_errno;
}

void *idris_rtlsdr_open(uint32_t index)
{
	rtlsdr_dev_t *dev;
	idris_rtlsdr_errno = rtlsdr_open(&dev, index);
	return dev;
}


