module Bindings.RtlSdr.Gain

import Bindings.RtlSdr.Device
import Bindings.RtlSdr.Error
import Bindings.RtlSdr.Raw.Gain

import System.FFI

%default total

export
getTunerGains : Ptr RtlSdrHandle -> IO (Either RTLSDR_ERROR Int)
getTunerGains h = do
  v <- prim__castPtr <$> malloc 4 -- gains
  r <- fromPrim $ get_tuner_gains h v
  let g = idris_rtlsdr_read_refint v
  free $ prim__forgetPtr v
  io_pure $ if r == 0 then Right g else Left RtlSdrError

export
setTunerGain : Ptr RtlSdrHandle -> Int -> IO (Either RTLSDR_ERROR ())
setTunerGain h g = do
  r <- fromPrim $ set_tuner_gain h g
  io_pure $ if r == 0 then Right () else Left RtlSdrError

export
setTunerBandwidth : Ptr RtlSdrHandle -> Int -> IO (Either RTLSDR_ERROR ())
setTunerBandwidth h bw = do
  r <- fromPrim $ set_tuner_bandwidth h bw
  io_pure $ if r == 0 then Right () else Left RtlSdrError

export
getTunerGain : Ptr RtlSdrHandle -> IO (Either RTLSDR_ERROR Int)
getTunerGain h = do
  r <- fromPrim $ get_tuner_gain h
  io_pure $ if r == 0 then Left RtlSdrError else Right r

export
setTunerIFGain : Ptr RtlSdrHandle -> Int -> Int -> IO (Either RTLSDR_ERROR ())
setTunerIFGain h s g = do
  r <- fromPrim $ set_tuner_if_gain h s g
  io_pure $ if r == 0 then Right () else Left RtlSdrError

export
setTunerGainMode : Ptr RtlSdrHandle -> Bool -> IO (Either RTLSDR_ERROR ())
setTunerGainMode h t = do
  r <- fromPrim $ set_tuner_gain_mode h (if t then 1 else 0)
  io_pure $ if r == 0 then Right () else Left RtlSdrError
