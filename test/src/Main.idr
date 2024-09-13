module Main

import Bindings.RtlSdr
import Data.Bits
import Data.Buffer
import Data.List
import System.FFI
import System.File
import System.File.Buffer

abs : (i, q : Int8) -> Int16
abs i q =
  let
    ii : Double
    ii = cast i * cast i

    qq : Double
    qq = cast q * cast q
  in
    cast $ sqrt ( ii + qq )

demodAM : List Int8 -> List Int16
demodAM [] = []
demodAM [_] = []
demodAM (i :: q :: rest) =
  let w = abs i q
    in w :: demodAM rest

downSample : Int -> List Int16 -> List Int16
downSample _ l = l

writeBufToFile : List Int16 -> IO ()
writeBufToFile bytes = do
  let len : Int = cast (length bytes)
  Just buf <- newBuffer len
    | Nothing => putStrLn "could not allocate buffer"

  for_ (zip [0 .. len-1] bytes) $ \(i, w) =>
    setBits16 buf i (cast w)

  result <- withFile "data.wav" Append printLn $ \f => do
    Right () <- writeBufferData f buf 0 len
      | Left (err, len) => do
          printLn ("could not writeBufferData", err, len)
          pure $ Left ()

    pure $ Right ()

  case result of
    Left err => printLn err
    Right () => pure ()

readAsyncCallback : ReadAsyncFn
readAsyncCallback ctx buf = writeBufToFile (downSample 0 $ demodAM buf)

testAM : IO ()
testAM = do
  putStrLn "opening RTL SDR idx 0"
  h <- rtlsdr_open 0
  case h of
    Nothing => putStrLn "Failed to open device handle"
    Just h => do
      --let fq = 133_250_000 -- YBTH AWIS
      let fq = 127_350_000 -- YBTH CTAF

      _ <- setTunerGainMode h False -- manual gain
      _ <- setTunerGain h 192 -- 19.2dB

      _ <- setAGCMode h True -- ON
      _ <- setCenterFreq h fq
      _ <- setTunerBandwidth h 0 -- auto
      -- _ <- setDirectSampling h (SAMPLING_I_ADC_ENABLED | SAMPLING_Q_ADC_ENABLED)
      _ <- setSampleRate h 250_000
      _ <- setFreqCorrection h (-15)

      f <- getCenterFreq h
      putStrLn $ "Freq set to: " ++ (show f)

      fc <- getFreqCorrection h
      putStrLn $ "Freq correction set to: " ++ (show fc)

      gs <- getTunerGains h
      putStrLn $ "Gains: " ++ (show gs)
      g <- getTunerGain h
      putStrLn $ "Gain: " ++ (show g)
      f <- getCenterFreq h
      putStrLn $ "Freq: " ++ (show f)
      o <- getOffsetTuning h
      putStrLn $ "Tuner offset: " ++ (show o)
      s <- getDirectSampling h
      putStrLn $ "Sampling mode: " ++ (show s)
      r <- getSampleRate h
      putStrLn $ "Sample rate: " ++ (show r)

      -- flush buffer
      _ <- resetBuffer h

      _ <- readAsync h readAsyncCallback prim__getNullAnyPtr 0 0

      _ <- rtlsdr_close h
      putStrLn "Done, closing.."


testDeviceFound : IO ()
testDeviceFound = do
  let n = get_device_count
  putStrLn $ "Device Count: " ++ show n
  for_ [0..n-1] $ \k => putStrLn $ "Device Name: " ++ get_device_name k

main : IO ()
main = do
  testDeviceFound
  testAM
