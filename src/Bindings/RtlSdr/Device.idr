module Bindings.RtlSdr.Device

import System.FFI

%default total

-- Device handle data type.
export
data RtlSdrHandle = MkDevice AnyPtr

-- librtlsdr binding helper.
public export
librtlsdr : String -> String
librtlsdr fn = "C:" ++ "rtlsdr_" ++ fn ++ ",librtlsdr"


-- RTLSDR_API uint32_t rtlsdr_get_device_count(void);
export
%foreign (librtlsdr "get_device_count")
get_device_count: Int

-- RTLSDR_API const char* rtlsdr_get_device_name(uint32_t index);
export
%foreign (librtlsdr "get_device_name")
get_device_name: Int -> String


-- wrapper C func helper.
idris_rtlsdr : String -> String
idris_rtlsdr fn = "C:" ++ "idris_rtlsdr_" ++ fn ++ ",rtlsdr-idris"

-- RTLSDR_API int rtlsdr_open(rtlsdr_dev_t **dev, uint32_t index);
-- XXX support/ runtime wraps
%foreign (idris_rtlsdr "open")
idris_rtlsdr_open : AnyPtr -> Int -> PrimIO Int

export
rtlsdr_open : Int -> IO (Maybe RtlSdrHandle)
rtlsdr_open idx = do
  let p : AnyPtr -- underlying C library will allocate device handle resource
  res <- fromPrim $ idris_rtlsdr_open p idx -- mkForeign (FFun "idris_rtlsdr_open" [FInt] FPtr) idx
  io_pure $ if res == 0 then Just (MkDevice p) else Nothing


-- RTLSDR_API int rtlsdr_close(rtlsdr_dev_t *dev);
%foreign (librtlsdr "close")
close: AnyPtr -> PrimIO Int

export
rtlsdr_close: RtlSdrHandle -> IO ()
rtlsdr_close (MkDevice h) = do
  _ <- fromPrim $ close h
  io_pure ()
