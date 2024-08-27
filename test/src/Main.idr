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
      let o = get_offset_tuning h
      putStrLn $ "Tuner offset: " ++ (show o)
      let g = get_tuner_gain h
      putStrLn $ "Gain: " ++ (show g)
      let f = get_center_freq h
      putStrLn $ "Freq: " ++ (show f)
      putStrLn "Done, closing.."
      rtlsdr_close h

testAM : IO ()
testAM = do
  putStrLn "opening RTL SDR idx 0"
  h <- rtlsdr_open 0
  case h of
    Nothing => putStrLn "Failed to open device handle"
    Just h => do
      let fq = 97700000
      let sr = 500000

      let _ = set_tuner_gain_mode h 0
      let _ = set_agc_mode h 0
      let _ = set_sample_rate h sr
      let _ = set_center_freq h fq

      let f = get_center_freq h
      putStrLn $ "Freq set to: " ++ (show f)

      -- flush buffer
      _ <- fromPrim $ reset_buffer h

      -- read_sync(device, buffer, buffer_len, &len);

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
  testAM
