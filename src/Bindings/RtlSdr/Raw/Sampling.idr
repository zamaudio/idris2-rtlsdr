module Bindings.RtlSdr.Raw.Sampling

import Bindings.RtlSdr.Device

%default total

-- RTLSDR_API int rtlsdr_set_sample_rate(rtlsdr_dev_t *dev, uint32_t rate);
export
%foreign (librtlsdr "set_sample_rate")
set_sample_rate: Ptr RtlSdrHandle -> Int -> PrimIO Int

-- RTLSDR_API uint32_t rtlsdr_get_sample_rate(rtlsdr_dev_t *dev);
export
%foreign (librtlsdr "get_sample_rate")
get_sample_rate: Ptr RtlSdrHandle -> PrimIO Int

-- RTLSDR_API int rtlsdr_set_agc_mode(rtlsdr_dev_t *dev, int on);
export
%foreign (librtlsdr "set_agc_mode")
set_agc_mode: Ptr RtlSdrHandle -> Int -> PrimIO Int

-- RTLSDR_API int rtlsdr_set_direct_sampling(rtlsdr_dev_t *dev, int on);
export
%foreign (librtlsdr "set_direct_sampling")
set_direct_sampling: Ptr RtlSdrHandle -> Int -> PrimIO Int

-- RTLSDR_API int rtlsdr_get_direct_sampling(rtlsdr_dev_t *dev);
export
%foreign (librtlsdr "get_direct_sampling")
get_direct_sampling: Ptr RtlSdrHandle -> PrimIO Int
