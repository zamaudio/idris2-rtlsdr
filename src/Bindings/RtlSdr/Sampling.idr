module Bindings.RtlSdr.Sampling

import Bindings.RtlSdr.Device
import Bindings.RtlSdr.Error
import Bindings.RtlSdr.Raw.Sampling

%default total

export
setSampleRate : Ptr RtlSdrHandle -> Int -> IO Int
setSampleRate h r = fromPrim $ set_sample_rate h r

export
getSampleRate : Ptr RtlSdrHandle -> IO Int
getSampleRate h = fromPrim $ get_sample_rate h

export
setAGCMode : Ptr RtlSdrHandle -> Bool -> IO (Either RTLSDR_ERROR ())
setAGCMode h t = do
  r <- fromPrim $ set_agc_mode h (if t then 1 else 0)
  io_pure $ if r == 0 then Right () else Left RtlSdrError

public export
data SamplingType = SAMPLING_DISABLED | SAMPLING_I_ADC_ENABLED | SAMPLING_Q_ADC_ENABLED

export
Show SamplingType where
  show SAMPLING_DISABLED      = "Disabled"
  show SAMPLING_I_ADC_ENABLED = "I-ADC Input Enabled"
  show SAMPLING_Q_ADC_ENABLED = "Q-ADC Input Enabled"

toSamplingType : Int -> Maybe SamplingType
toSamplingType 0 = Just SAMPLING_DISABLED
toSamplingType 1 = Just SAMPLING_I_ADC_ENABLED
toSamplingType 2 = Just SAMPLING_Q_ADC_ENABLED
toSamplingType _ = Nothing

fromSamplingType : SamplingType -> Int
fromSamplingType SAMPLING_DISABLED      = 0
fromSamplingType SAMPLING_I_ADC_ENABLED = 1
fromSamplingType SAMPLING_Q_ADC_ENABLED = 2

export
setDirectSampling : Ptr RtlSdrHandle -> SamplingType -> IO (Either RTLSDR_ERROR ())
setDirectSampling h t = do
  r <- fromPrim $ set_direct_sampling h (fromSamplingType t)
  io_pure $ if r < 0 then Left RtlSdrError else Right ()

export
getDirectSampling : Ptr RtlSdrHandle -> IO (Either RTLSDR_ERROR (Maybe SamplingType))
getDirectSampling h = do
  r <- fromPrim $ get_direct_sampling h
  io_pure $ if r < 0 then Left RtlSdrError else Right (toSamplingType r)
