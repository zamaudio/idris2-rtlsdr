#include <stdint.h>

#include <rtl-sdr.h>

#include "idris_rtlsdr.h"

int idris_rtlsdr_open(void *p, uint32_t index)
{
	rtlsdr_dev_t *dev;
	const int ret = rtlsdr_open(&dev, index);
	p = dev;
	return ret;
}


