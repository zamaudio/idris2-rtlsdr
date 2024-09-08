module Bindings.RtlSdr.Buffer

import public Bindings.RtlSdr.Raw.Buffer
import Bindings.RtlSdr.Device
import Bindings.RtlSdr.Error

import System.FFI

%default total

export
resetBuffer : Ptr RtlSdrHandle -> IO (Either RTLSDR_ERROR ())
resetBuffer h = do
  r <- fromPrim $ reset_buffer h
  io_pure $ if r == 0 then Right () else Left RtlSdrError

export
readSync : Ptr RtlSdrHandle -> AnyPtr -> Int -> IO (Either RTLSDR_ERROR Int)
readSync h b l = do
  v <- prim__castPtr <$> malloc 4 -- n_read
  r <- fromPrim $ read_sync h b l v
  let nr = idris_rtlsdr_read_refint v
  free $ prim__forgetPtr v
  io_pure $ if r == 0 then Right nr else Left RtlSdrError

export
readAsync : Ptr RtlSdrHandle -> ReadAsyncFn -> AnyPtr -> Int -> Int -> IO (Either RTLSDR_ERROR ())
readAsync h cb ctx bn bl = do
  r <- fromPrim $ read_async h cb ctx bn bl
  io_pure $ if r == 0 then Right () else Left RtlSdrError

export
cancelAsync : Ptr RtlSdrHandle -> IO (Either RTLSDR_ERROR ())
cancelAsync h = do
  r <- fromPrim $ cancel_async h
  io_pure $ if r == 0 then Right () else Left RtlSdrError
