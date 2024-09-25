module EEPromRead

import Bindings.RtlSdr

import Data.Bits
import Data.Buffer
import System.File.Buffer

-- USB encodes strings as UTF16 in BE.
getString16 : Buffer -> Int -> Int -> IO String
getString16 b o l = do
  ca <- for [(o `div` 2)..((o + l) `div` 2) - 2] $ \i => do
    b <- getBits16 b (2*i)
    let b' : Bits8 = cast $ (b `shiftR` 8) .&. 0xff
    io_pure $ chr (cast b')
  io_pure $ pack ca

export
testDumpEEProm : Maybe String -> IO ()
testDumpEEProm dpath' = do
  let dpath = fromMaybe "eeprom.bin" dpath'
  putStrLn "opening RTL SDR idx 0"
  h <- rtlsdr_open 0
  case h of
    Nothing => putStrLn "Failed to open device handle"
    Just h => do
      let len = 256
      r <- readEEProm h 0 len
      case r of
           Right b => do
             putStrLn "Dumping EEProm content to eeprom.bin"
             slen <- getByte b 0x09 -- str length.
             schk <- getByte b 0x0A -- must be 0x03.
             if schk /= 0x03 then putStrLn ("invalid string descriptor " ++ (show schk)) else do
               vendor <- getString16 b 0x0B slen
               putStrLn $ "EEPRom contains vendor: '" ++ vendor ++ "'."

             _ <- writeBufferToFile dpath b len
             io_pure ()
           Left e => putStrLn $ "could not read EEProm" ++ show e
      _ <- rtlsdr_close h
      putStrLn "Done, closing.."
  io_pure ()
