module Bindings.RtlSdr.Frequency

import Bindings.RtlSdr.Device

%default total

-- RTLSDR_API int rtlsdr_set_xtal_freq(rtlsdr_dev_t *dev, uint32_t rtl_freq, uint32_t tuner_freq);
export
%foreign (librtlsdr "set_xtal_freq")
set_xtal_freq: Ptr RtlSdrHandle -> Int -> Int -> Int

-- RTLSDR_API int rtlsdr_get_xtal_freq(rtlsdr_dev_t *dev, uint32_t *rtl_freq, uint32_t *tuner_freq);
export
%foreign (librtlsdr "get_xtal_freq")
get_xtal_freq: Ptr RtlSdrHandle -> Int -> Ptr Int -> Int


-- RTLSDR_API int rtlsdr_set_center_freq(rtlsdr_dev_t *dev, uint32_t freq);
export
%foreign (librtlsdr "set_center_freq")
set_center_freq: Ptr RtlSdrHandle -> Int -> PrimIO Int

-- RTLSDR_API uint32_t rtlsdr_get_center_freq(rtlsdr_dev_t *dev);
export
%foreign (librtlsdr "get_center_freq")
get_center_freq: Ptr RtlSdrHandle -> PrimIO Int

-- RTLSDR_API int rtlsdr_set_freq_correction(rtlsdr_dev_t *dev, int ppm);
export
%foreign (librtlsdr "set_freq_correction")
set_freq_correction: Ptr RtlSdrHandle -> Int -> Int

-- RTLSDR_API int rtlsdr_get_freq_correction(rtlsdr_dev_t *dev);
export
%foreign (librtlsdr "get_freq_correction")
get_freq_correction: Ptr RtlSdrHandle -> Int
