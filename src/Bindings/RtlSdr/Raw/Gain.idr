module Bindings.RtlSdr.Raw.Gain

import Bindings.RtlSdr.Device

%default total

-- RTLSDR_API int rtlsdr_get_tuner_gains(rtlsdr_dev_t *dev, int *gains);
export
%foreign (librtlsdr "get_tuner_gains")
get_tuner_gains: Ptr RtlSdrHandle -> Ptr Int -> PrimIO Int

-- RTLSDR_API int rtlsdr_set_tuner_gain(rtlsdr_dev_t *dev, int gain);
export
%foreign (librtlsdr "set_tuner_gain")
set_tuner_gain: Ptr RtlSdrHandle -> Int -> PrimIO Int

-- RTLSDR_API int rtlsdr_set_tuner_bandwidth(rtlsdr_dev_t *dev, uint32_t bw);
export
%foreign (librtlsdr "set_tuner_bandwidth")
set_tuner_bandwidth: Ptr RtlSdrHandle -> Int -> PrimIO Int

-- RTLSDR_API int rtlsdr_get_tuner_gain(rtlsdr_dev_t *dev);
export
%foreign (librtlsdr "get_tuner_gain")
get_tuner_gain: Ptr RtlSdrHandle -> PrimIO Int

-- RTLSDR_API int rtlsdr_set_tuner_if_gain(rtlsdr_dev_t *dev, int stage, int gain);
export
%foreign (librtlsdr "set_tuner_if_gain")
set_tuner_if_gain: Ptr RtlSdrHandle -> Int -> Int -> PrimIO Int

-- RTLSDR_API int rtlsdr_set_tuner_gain_mode(rtlsdr_dev_t *dev, int manual);
export
%foreign (librtlsdr "set_tuner_gain_mode")
set_tuner_gain_mode: Ptr RtlSdrHandle -> Int -> PrimIO Int
