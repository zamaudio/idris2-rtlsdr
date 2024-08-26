module Main

import Bindings.RtlSdr

testOpenClose : IO ()
testOpenClose = do
  putStrLn "opening RTL SDR idx 0"
  h <- rtlsdr_open 0
  case h of
    Nothing => putStrLn "Failed to open device handle"
    Just h => do
      putStrLn $ show $ rtlsdr_get_tuner_type h
      putStrLn "Done, closing.."
      rtlsdr_close h

testDeviceFound : IO ()
testDeviceFound = do
  let n = get_device_count
  putStrLn $ "Device Count: " ++ show n
  for_ [0..n] $ \k => putStrLn $ "Device Name: " ++ get_device_name k

main : IO ()
main = do
  testDeviceFound
  testOpenClose
