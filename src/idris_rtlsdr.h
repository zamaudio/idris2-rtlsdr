#ifndef __IDRIS_RTLSDR
#define __IDRIS_RTLSDR

int idris_rtlsdr_get_errno(void);
bool idris_is_null(void *p);

void *idris_rtlsdr_open(uint32_t index);

#endif /* __IDRIS_RTLSDR */
