module Bindings.RtlSdr.Error

%default total

public export
data RTLSDR_ERROR = RtlSdrError

export
Show RTLSDR_ERROR where
  show RtlSdrError = "librtlsdr returned an internal error"
