module Bindings.RtlSdr.Misc

import Bindings.RtlSdr.Device

%default total

data TunerType = RTLSDR_TUNER_UNKNOWN | RTLSDR_TUNER_E4000 | RTLSDR_TUNER_FC0012 | RTLSDR_TUNER_FC0013| RTLSDR_TUNER_FC2580 | RTLSDR_TUNER_R820T | RTLSDR_TUNER_R828D

-- RTLSDR_API enum rtlsdr_tuner rtlsdr_get_tuner_type(rtlsdr_dev_t *dev);
export
%foreign (librtlsdr "get_tuner_type")
get_tuner_type: RtlSdrHandle -> TunerType



-- RTLSDR_API int rtlsdr_set_offset_tuning(rtlsdr_dev_t *dev, int on);
export
%foreign (librtlsdr "set_offset_tuning")
set_offset_tuning: RtlSdrHandle -> Int -> Int

-- RTLSDR_API int rtlsdr_get_offset_tuning(rtlsdr_dev_t *dev);
export
%foreign (librtlsdr "get_offset_tuning")
get_offset_tuning: RtlSdrHandle -> Int


-- RTLSDR_API int rtlsdr_set_bias_tee(rtlsdr_dev_t *dev, int on);
export
%foreign (librtlsdr "set_bias_tee")
set_bias_tee: RtlSdrHandle -> Int -> Int

-- RTLSDR_API int rtlsdr_set_bias_tee_gpio(rtlsdr_dev_t *dev, int gpio, int on);
export
%foreign (librtlsdr "set_bias_tee_gpio")
set_bias_tee_gpio: RtlSdrHandle -> Int -> Int -> Int
