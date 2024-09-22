module Main

import Bindings.RtlSdr
import Data.Bits
import Data.Buffer
import Data.List
import Data.String
import System
import System.FFI
import System.File
import System.File.Buffer

import AM
import EEPromRead

writeBufToFile : String -> List Int16 -> IO ()
writeBufToFile fpath bytes = do
  let len : Int = cast (length bytes)
  Just buf <- newBuffer len
    | Nothing => putStrLn "could not allocate buffer"

  for_ (zip [0 .. len-1] bytes) $ \(i, w) =>
    setBits16 buf i (cast w)

  result <- withFile fpath Append printLn $ \f => do
    Right () <- writeBufferData f buf 0 len
      | Left (err, len) => do
          printLn ("could not writeBufferData", err, len)
          pure $ Left ()

    pure $ Right ()

  case result of
    Left err => printLn err
    Right () => pure ()

readAsyncCallback : String -> Int -> ReadAsyncFn
readAsyncCallback fpath thres ctx buf = writeBufToFile fpath (demodAMStream buf 100 thres)

testAM : Maybe Int -> Maybe Int -> Maybe String -> IO ()
testAM freq thres' fpath' = do
  putStrLn "opening RTL SDR idx 0"
  h <- rtlsdr_open 0
  case h of
    Nothing => putStrLn "Failed to open device handle"
    Just h => do
      --let fq_default = 133_250_000 -- YBTH AWIS
      let fq_default = 127_350_000 -- YBTH CTAF
      let fq = fromMaybe fq_default freq

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

      let fpath = fromMaybe "/dev/stdout" fpath'
      putStrLn $ "File to write out to '" ++ (show fpath) ++ "'."

      let thres = fromMaybe 15 thres' -- default threshold of >15
      _ <- readAsync h (readAsyncCallback fpath thres) prim__getNullAnyPtr 0 0

      _ <- rtlsdr_close h
      putStrLn "Done, closing.."


testDeviceFound : IO ()
testDeviceFound = do
  let n = get_device_count
  putStrLn $ "Device Count: " ++ show n
  for_ [0..n-1] $ \k => putStrLn $ "Device Name: " ++ get_device_name k

record Args where
  constructor MkArgs
  fPath : Maybe String
  freq  : Maybe Int
  thres : Maybe Int

parseArgs : List String -> Args -> Either String Args
parseArgs [] = Right
parseArgs ("--file" :: f :: rest) = parseArgs rest . {fPath := Just f}
parseArgs ("--freq" :: f :: rest) =
  case parsePositive f of
    Nothing => \args => Left $ "--freq: could not parse: " ++ f
    Just f' => parseArgs rest . {freq  := Just f'}
parseArgs ("--threshold" :: t :: rest) =
  case parsePositive t of
    Nothing => \args => Left $ "--threshold: could not parse: " ++ t
    Just t' => parseArgs rest . {thres  := Just t'}
parseArgs (arg :: rest) =
  \args => Left $ "unknown argument: " ++ arg

main : IO ()
main = do
  exeName :: args' <- getArgs
    | [] => putStrLn "impossible: empty args"
  case parseArgs args' (MkArgs Nothing Nothing Nothing) of
    Left err => putStrLn err
    Right args => do
      testDeviceFound
      testDumpEEProm
      testAM args.freq args.thres args.fPath
