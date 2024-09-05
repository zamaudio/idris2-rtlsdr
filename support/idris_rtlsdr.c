#include <stdint.h>

#include <rtl-sdr.h>

#include "idris_rtlsdr.h"

void * idris_rtlsdr_open(uint32_t index)
{
	rtlsdr_dev_t *dev;
	const int ret = rtlsdr_open(&dev, index);
	return dev;
}


