module Bindings.RtlSdr.Error

%default total

public export
data RTLSDR_ERROR = RtlSdrError
                  | RtlSdrHandleInvalid
                  | RtlSdrEEPromSizeExceeded
                  | RtlSdrEEPromNotFound
                  | RtlSdrInvalidRate

export
Show RTLSDR_ERROR where
  show RtlSdrError = "librtlsdr returned an internal error"
  show RtlSdrHandleInvalid      = "device handle is invalid"
  show RtlSdrEEPromSizeExceeded = "EEPROM size is exceeded"
  show RtlSdrEEPromNotFound     = "no EEPROM was found"
  show RtlSdrInvalidRate        = "invalid sample rate"
