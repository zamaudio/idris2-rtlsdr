module Main

import Bindings.RtlSdr
import Data.Bits
import Data.Buffer
import Data.Either
import Data.List
import Data.String
import System
import System.Concurrency
import System.FFI
import System.File
import System.File.Buffer

import AM
import EEPromRead


-- Package up a List of S16 words of PCM into a Buffer.
getWAV16Buffer : List Int16 -> IO (Maybe (Buffer, Int))
getWAV16Buffer bytes = do
  let len : Int = cast (length bytes)
  Just buf <- newBuffer (2*len)
    | Nothing => io_pure Nothing

  for_ (zip [0 .. len-1] bytes) $ \(i, w) =>
    setBits16 buf (2*i) (cast w)

  io_pure $ Just (buf, 2*len)

writeBufToFile : String -> Buffer -> Int -> IO ()
writeBufToFile fpath buf len = do
  result <- withFile fpath Append printLn $ \f => do
    Right () <- writeBufferData f buf 0 len
      | Left (err, len) => do
          printLn ("could not writeBufferData", err, len)
          pure $ Left ()

    pure $ Right ()

  case result of
    Left err => printLn err
    Right () => pure ()

data RWStream : Type where
  Stream : (stream : List IQ) -> RWStream
  Done : RWStream

reader : (rch : Channel RWStream) -> List IQ -> IO ()
reader rch stream = channelPut rch (Stream stream)

writer : (wch : Channel RWStream) -> String -> Int -> Int -> IO ()
writer wch fpath dsr thres =
  do
    (Stream wstream) <- channelGet wch
      | Done => pure ()
    Just (buf, len) <- getWAV16Buffer (demodAMStream wstream dsr thres)
      | Nothing => putStrLn "getWAV16Buffer could not allocate buffer"
    writeBufToFile fpath buf len
    writer wch fpath dsr thres

run : (rch : Channel RWStream) -> (wch : Channel RWStream) -> IO ()
run rch wch =
  do
    (Stream rstream) <- channelGet rch
      | Done => channelPut wch Done
    wstream <- pure rstream
    channelPut wch (Stream wstream)
    run rch wch

readAsyncCallback : Channel RWStream -> ReadAsyncFn
readAsyncCallback rch ctx iqlist = reader rch iqlist

record Args where
  constructor MkArgs
  dpath : Maybe String
  fpath : Maybe String
  freq  : Maybe Int
  thres : Maybe Int
  ppm   : Maybe Int
  rate  : Maybe Int

cfgRTL : Ptr RtlSdrHandle -> Int -> Int -> Int -> IO ()
cfgRTL h fq ppm r = do
      _ <- setTunerGainMode h False -- manual gain
      _ <- setTunerGain h (-100) -- auto
      _ <- setAGCMode h True -- ON
      _ <- setCenterFreq h fq
      _ <- setTunerBandwidth h 0 -- auto
      -- _ <- setDirectSampling h (SAMPLING_I_ADC_ENABLED | SAMPLING_Q_ADC_ENABLED)
      _ <- setSampleRate h r
      _ <- setFreqCorrection h ppm

      f <- getCenterFreq h
      putStrLn $ "Freq set to: " ++ (show f)

      fc <- getFreqCorrection h
      putStrLn $ "Freq correction set to: " ++ (show fc)

      gs <- getTunerGains h
      putStrLn $ "Gains: " ++ (show gs)
      g <- getTunerGain h
      putStrLn $ "Gain: " ++ (fromMaybe "<unknown>" $ map show $ getRight g)
      f <- getCenterFreq h
      putStrLn $ "Freq: " ++ (fromMaybe "<unknown>" $ map show $ getRight f)
      o <- getOffsetTuning h
      putStrLn $ "Tuner offset: " ++ (fromMaybe "<unknown>" $ map show $ getRight o)
      s <- getDirectSampling h
      putStrLn $ "Sampling mode: " ++ (fromMaybe "<unknown>" $ map show $ getRight s)
      r <- getSampleRate h
      putStrLn $ "Sample rate: " ++ (show r)

      io_pure ()

testAM : Args -> IO ()
testAM args = do
  putStrLn "opening RTL SDR idx 0"
  h <- rtlsdr_open 0
  case h of
    Nothing => putStrLn "Failed to open device handle"
    Just h => do
      --let fq_default = 133_250_000 -- YBTH AWIS
      let fq_default = 127_350_000 -- YBTH CTAF
      let fq = fromMaybe fq_default args.freq

      let rate_in_default = 24_000
      let rate_in = fromMaybe rate_in_default args.rate

      putStrLn $ "Using a in rate of: " ++ (show $ rate_in `div` 1_000) ++ " kHz."
      let rate_iq = 1_008_000
      putStrLn $ "Sampling IQ stream at: " ++ (show $ rate_iq `div` 1_000) ++ "kHz."
      let rate_downsample = (500_000 `div` rate_in) + 1
      putStrLn $ "Calculated downsampling of: " ++ (show rate_downsample) ++ "x."

      let ppm = fromMaybe 0 args.ppm -- default ppm of zero.
      cfgRTL h fq ppm rate_iq

      -- flush buffer
      _ <- resetBuffer h

      let fpath = fromMaybe "/dev/stderr" args.fpath
      putStrLn $ "File to write out to '" ++ (show fpath) ++ "'."

      let thres = fromMaybe 15 args.thres -- default threshold of >15

      readCh <- makeChannel
      writeCh <- makeChannel

      _ <- fork (run readCh writeCh)
      _ <- fork $ writer writeCh fpath rate_downsample thres
      _ <- readAsync h (readAsyncCallback readCh) prim__getNullAnyPtr 0 0

      _ <- rtlsdr_close h
      putStrLn "Done, closing.."


testDeviceFound : IO ()
testDeviceFound = do
  let n = get_device_count
  putStrLn $ "Device Count: " ++ show n
  for_ [0..n-1] $ \k => putStrLn $ "Device Name: " ++ get_device_name k

parseArgs : List String -> Args -> Either String Args
parseArgs [] = Right
parseArgs ("--dump" :: f :: rest) = parseArgs rest . {dpath := Just f}
parseArgs ("--file" :: f :: rest) = parseArgs rest . {fpath := Just f}
parseArgs ("--freq" :: f :: rest) =
  case parsePositive f of
    Nothing => \args => Left $ "--freq: could not parse: " ++ f
    Just f' => parseArgs rest . {freq  := Just f'}
parseArgs ("--threshold" :: t :: rest) =
  case parsePositive t of
    Nothing => \args => Left $ "--threshold: could not parse: " ++ t
    Just t' => parseArgs rest . {thres  := Just t'}
parseArgs ("--ppm" :: p :: rest) =
  case parsePositive p of
    Nothing => \args => Left $ "--ppm: could not parse: " ++ p
    Just p' => parseArgs rest . {ppm := Just p'}
parseArgs ("--rate" :: r :: rest) =
  case parsePositive r of
    Nothing => \args => Left $ "--rate: could not parse: " ++ r
    Just r' => parseArgs rest . {rate := Just r'}
parseArgs (arg :: rest) =
  \args => Left $ "unknown argument: " ++ arg

defaultArgs : Args
defaultArgs = MkArgs Nothing Nothing Nothing Nothing Nothing Nothing

main : IO ()
main = do
  exeName :: args' <- getArgs
    | [] => putStrLn "impossible: empty args"
  case parseArgs args' defaultArgs of
    Left err => putStrLn err
    Right args => do
      testDeviceFound
      testDumpEEProm args.dpath
      testAM args
