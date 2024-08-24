module Main

import Bindings.RtlSdr

testOpenClose : IO ()
testOpenClose = do
  putStrLn "opening RTL SDR idx 0"
  h <- rtlsdr_open 0
  case h of
       Nothing => putStrLn "Failed to open"
       Just h_ok => do
--         _ <- close h_ok
         putStrLn "Done"

main : IO ()
main = do
  testOpenClose
