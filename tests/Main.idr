module Main

import Bindings.RtlSdr

testOpenClose : IO ()
testOpenClose = do
  putStrLn "opening RTL SDR idx 0"
  _ <- rtlsdr_open 0
  --if (Just h) then close h else putStrLn "Failed to open"
  putStrLn "Done"

main : IO ()
main = do
  testOpenClose
