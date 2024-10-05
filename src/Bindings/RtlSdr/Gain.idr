module Bindings.RtlSdr.Gain

import Bindings.RtlSdr.Device
import Bindings.RtlSdr.Error
import Bindings.RtlSdr.Raw.Gain
import Bindings.RtlSdr.Raw.Support

import System.FFI

%default total

||| Get a list of gains supported by the tuner.
|||
||| Each gain values is in tenths of a dB, 115 means 11.5 dB.
|||
||| @h is the device handle
export
getTunerGains : Ptr RtlSdrHandle -> IO (Either RTLSDR_ERROR (List Int))
getTunerGains h = do
  n <- fromPrim $ get_tuner_gains h (prim__castPtr prim__getNullAnyPtr)
  if n < 0 then do
             io_pure $ Left RtlSdrError
           else do
             v <- prim__castPtr <$> malloc (n*8)
             _ <- fromPrim $ get_tuner_gains h v
             g <- readBufPtr v n
             free $ prim__forgetPtr v
             io_pure $ Right g

||| Set the gain for the device.
|||
||| Manual gain mode must be enabled for this to work.
|||
||| Valid gain values (in tenths of a dB) for the E4000 tuner:
||| -10, 15, 40, 65, 90, 115, 140, 165, 190,
||| 215, 240, 290, 340, 420, 430, 450, 470, 490
|||
||| Valid gain values may be queried with `getTunerGains`.
|||
||| @h is the device handle
||| @g is in tenths of a dB, 115 means 11.5 dB.
export
setTunerGain : Ptr RtlSdrHandle -> Int -> IO (Either RTLSDR_ERROR ())
setTunerGain h g = do
  r <- fromPrim $ set_tuner_gain h g
  io_pure $ if r == 0 then Right () else Left RtlSdrError

||| Set the bandwidth for the device.
|||
||| @h is the device handle
||| @bw is the bandwidth in Hz. Zero means automatic BW selection.
export
setTunerBandwidth : Ptr RtlSdrHandle -> Int -> IO (Either RTLSDR_ERROR ())
setTunerBandwidth h bw = do
  r <- fromPrim $ set_tuner_bandwidth h bw
  io_pure $ if r == 0 then Right () else Left RtlSdrError

||| Get actual gain the device is configured to.
|||
||| Returned gain is in tenths of a dB, 115 means 11.5 dB.
|||
||| @h is the device handle
export
getTunerGain : Ptr RtlSdrHandle -> IO (Either RTLSDR_ERROR Int)
getTunerGain h = do
  r <- fromPrim $ get_tuner_gain h
  io_pure $ if r == 0 then Left RtlSdrError else Right r

||| Set the intermediate frequency gain for the device.
|||
||| @h is the device handle
||| @s is the stage intermediate frequency gain stage number (1 to 6 for E4000)
||| @g is the gain in tenths of a dB, -30 means -3.0 dB.
export
setTunerIFGain : Ptr RtlSdrHandle -> Int -> Int -> IO (Either RTLSDR_ERROR ())
setTunerIFGain h s g = do
  r <- fromPrim $ set_tuner_if_gain h s g
  io_pure $ if r == 0 then Right () else Left RtlSdrError

||| Set the gain mode (automatic/manual) for the device.
|||
||| Manual gain mode must be enabled for the gain setter function to work.
|||
||| @h is the device handle
||| @t is the manual gain mode, `True` means manual gain mode shall be enabled.
export
setTunerGainMode : Ptr RtlSdrHandle -> Bool -> IO (Either RTLSDR_ERROR ())
setTunerGainMode h t = do
  r <- fromPrim $ set_tuner_gain_mode h (if t then 1 else 0)
  io_pure $ if r == 0 then Right () else Left RtlSdrError
