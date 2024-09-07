module Bindings.RtlSdr.Raw.Misc

import Bindings.RtlSdr.Device

%default total

-- RTLSDR_API enum rtlsdr_tuner rtlsdr_get_tuner_type(rtlsdr_dev_t *dev);
export
%foreign (librtlsdr "get_tuner_type")
get_tuner_type: Ptr RtlSdrHandle -> Int

-- RTLSDR_API int rtlsdr_set_offset_tuning(rtlsdr_dev_t *dev, int on);
export
%foreign (librtlsdr "set_offset_tuning")
set_offset_tuning: Ptr RtlSdrHandle -> Int -> PrimIO Int

-- RTLSDR_API int rtlsdr_get_offset_tuning(rtlsdr_dev_t *dev);
export
%foreign (librtlsdr "get_offset_tuning")
get_offset_tuning: Ptr RtlSdrHandle -> PrimIO Int


-- RTLSDR_API int rtlsdr_set_bias_tee(rtlsdr_dev_t *dev, int on);
export
%foreign (librtlsdr "set_bias_tee")
set_bias_tee: Ptr RtlSdrHandle -> Int -> Int

-- RTLSDR_API int rtlsdr_set_bias_tee_gpio(rtlsdr_dev_t *dev, int gpio, int on);
export
%foreign (librtlsdr "set_bias_tee_gpio")
set_bias_tee_gpio: Ptr RtlSdrHandle -> Int -> Int -> Int
