module Bindings.RtlSdr.EEProm

import Bindings.RtlSdr.Device
import Bindings.RtlSdr.Error
import Bindings.RtlSdr.Raw.EEProm
import Bindings.RtlSdr.Raw.Support

import Data.Bits
import Data.Buffer
import Data.List
import System.FFI

%default total

decodeRetError : Int -> RTLSDR_ERROR
decodeRetError e = case e of
                        -1 => RtlSdrHandleInvalid
                        -2 => RtlSdrEEPromSizeExceeded
                        -3 => RtlSdrEEPromNotFound
                        _ =>  RtlSdrError -- unknonwn

||| Read EEPROM connected to RTL device
|||
||| @h is the device handle
||| @o is the offset address where the data should be read from
||| @l is the length of the data to read
export
readEEProm : Ptr RtlSdrHandle -> Int -> Int -> IO (Either RTLSDR_ERROR Buffer)
readEEProm h o l = do
  b <- prim__castPtr <$> malloc l -- length in bytes
  r <- fromPrim $ read_eeprom h b o l

  b' <- readBufPtr' b l
  free $ prim__forgetPtr b

  Just buf <- newBuffer l
    | Nothing => io_pure $ Left RtlSdrError
  for_ (zip [0 .. l-1] b') $ \(i, w) =>
    setBits8 buf i (cast w)
  io_pure $ if r < 0 then Left (decodeRetError r) else Right buf


||| Write EEPROM connected to RTL device
|||
||| @h is the device handle
||| @b is the buffer of data to be written
||| @o is the offset address where the data should be written to
export
writeEEProm : Ptr RtlSdrHandle -> Buffer -> Int -> IO (Either RTLSDR_ERROR ())
writeEEProm h b o = do
  len <- rawSize b
  r <- fromPrim $ write_eeprom h b o len
  io_pure $ if r < 0 then Left (decodeRetError r) else Right ()
