module Bindings.RtlSdr.Device

import Bindings.RtlSdr.Raw.Device
import Bindings.RtlSdr.Raw.Support
import Bindings.RtlSdr.Error

import public Bindings.RtlSdr.Raw.Device
--import public Bindings.RtlSdr.Raw.Device.get_device_count
--import public Bindings.RtlSdr.Raw.Device.get_device_name

import System.FFI

%default total

export
rtlsdr_open : Int -> IO (Maybe (Ptr RtlSdrHandle))
rtlsdr_open idx = do
  v <- prim__castPtr <$> malloc 4 -- ret
  -- const void * idris_rtlsdr_open(uint32_t index, uint32_t *ret);
  p <- fromPrim $ idris_rtlsdr_open idx v
  let ret = peekInt v
  free $ prim__forgetPtr v
  io_pure $ if ret == 0 then Just (prim__castPtr p) else Nothing


export
rtlsdr_close : Ptr RtlSdrHandle -> IO (Either RTLSDR_ERROR ())
rtlsdr_close h = do
  r <- fromPrim $ close h
  io_pure $ if r == 0 then Right () else Left RtlSdrError


public export
record DeviceUSBStrings where
  constructor MkDeviceUSBStrings
  manufact : String
  product  : String
  serial   : String

export
Show DeviceUSBStrings where
  show ds = ds.manufact ++ ", " ++ ds.product ++ ", " ++ ds.serial ++ "."

||| Get USB device strings.
|||
||| @i is the the device index
export
getDeviceUSBStrings : Int -> IO (Either RTLSDR_ERROR DeviceUSBStrings)
getDeviceUSBStrings i = do
  -- NOTE: The string arguments must provide space for up to 256 bytes.
  m <- prim__castPtr <$> malloc 256
  p <- prim__castPtr <$> malloc 256
  s <- prim__castPtr <$> malloc 256
  let r = get_device_usb_strings i m p s
  let ds = MkDeviceUSBStrings (idris_rtlsdr_getstring m) (idris_rtlsdr_getstring p) (idris_rtlsdr_getstring s)
  -- NOTE: No use-after-free as getstring will incur a strcpy.
  free $ prim__forgetPtr m
  free $ prim__forgetPtr p
  free $ prim__forgetPtr s
  io_pure $ if r == 0 then Right ds else Left RtlSdrError
