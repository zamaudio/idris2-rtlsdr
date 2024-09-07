module Bindings.RtlSdr.Device

import Bindings.RtlSdr.Raw.Device
import Bindings.RtlSdr.Error

import public Bindings.RtlSdr.Raw.Device
--import public Bindings.RtlSdr.Raw.Device.get_device_count
--import public Bindings.RtlSdr.Raw.Device.get_device_name

import System.FFI

%default total


-- wrapper C func helper.
idris_rtlsdr : String -> String
idris_rtlsdr fn = "C:" ++ "idris_rtlsdr_" ++ fn ++ ",rtlsdr-idris"

-- XXX support/ runtime wraps
%foreign (idris_rtlsdr "open")
idris_rtlsdr_open : Int -> PrimIO AnyPtr

-- XXX support/.. int read_refint(int *p);
export
%foreign (idris_rtlsdr "read_refint")
idris_rtlsdr_read_refint : Ptr Int -> Int

export
rtlsdr_open : Int -> IO (Maybe (Ptr RtlSdrHandle))
rtlsdr_open idx = do
  -- let p = prim__getNullAnyPtr -- underlying C library will allocate device handle resource
  -- res <- fromPrim $ open_prim (prim__castPtr p) idx -- mkForeign (FFun "idris_rtlsdr_open" [FInt] FPtr) idx
  -- io_pure $ if res == 0 then Just (prim__castPtr p) else Nothing
  p <- fromPrim $ idris_rtlsdr_open idx
  io_pure $ Just $ prim__castPtr p


export
rtlsdr_close : Ptr RtlSdrHandle -> IO (Either RTLSDR_ERROR ())
rtlsdr_close h = do
  r <- fromPrim $ close h
  io_pure $ if r == 0 then Right () else Left RtlSdrError
