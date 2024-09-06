#ifndef __IDRIS_RTLSDR
#define __IDRIS_RTLSDR

void * idris_rtlsdr_open(uint32_t index);
int idris_rtlsdr_read_refint(const int *p);

#endif /* __IDRIS_RTLSDR */
