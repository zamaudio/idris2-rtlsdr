module Bindings.RtlSdr.Misc

import Bindings.RtlSdr.Device
import Bindings.RtlSdr.Error
import Bindings.RtlSdr.Raw.Misc

%default total

data TunerType = RTLSDR_TUNER_UNKNOWN | RTLSDR_TUNER_E4000 | RTLSDR_TUNER_FC0012 | RTLSDR_TUNER_FC0013 | RTLSDR_TUNER_FC2580 | RTLSDR_TUNER_R820T | RTLSDR_TUNER_R828D

export
Show TunerType where
  show RTLSDR_TUNER_UNKNOWN = "Unknown"
  show RTLSDR_TUNER_E4000   = "E4000"
  show RTLSDR_TUNER_FC0012  = "FC0012"
  show RTLSDR_TUNER_FC0013  = "FC0013"
  show RTLSDR_TUNER_FC2580  = "FC2580"
  show RTLSDR_TUNER_R820T   = "R820T"
  show RTLSDR_TUNER_R828D   = "R828D"

toTunerType : Int -> TunerType
toTunerType 1 = RTLSDR_TUNER_E4000
toTunerType 2 = RTLSDR_TUNER_FC0012
toTunerType 3 = RTLSDR_TUNER_FC0013
toTunerType 4 = RTLSDR_TUNER_FC2580
toTunerType 5 = RTLSDR_TUNER_R820T
toTunerType 6 = RTLSDR_TUNER_R828D
toTunerType _ = RTLSDR_TUNER_UNKNOWN

||| Get the tuner type.
|||
||| @h is the device handle
export
getTunerType : Ptr RtlSdrHandle -> TunerType
getTunerType h = toTunerType $ get_tuner_type h

||| Enable or disable offset tuning for zero-IF tuners, which allows to avoid
||| problems caused by the DC offset of the ADCs and 1/f noise.
|||
||| @h is the device handle
||| @t toggles where False means disabled and True means enabled
export
setOffsetTuning : Ptr RtlSdrHandle -> Bool -> IO (Either RTLSDR_ERROR ())
setOffsetTuning h t = do
  r <- fromPrim $ set_offset_tuning h (if t == False then 0 else 1)
  io_pure $ if r == 0 then Right () else Left RtlSdrError

||| Get state of the offset tuning mode
|||
||| @h is the device handle
export
getOffsetTuning : Ptr RtlSdrHandle -> IO (Either RTLSDR_ERROR Bool)
getOffsetTuning h = do
  r <- fromPrim $ get_offset_tuning h
  io_pure $ if r < 0 then Left RtlSdrError else Right (if r == 0 then False else True)
