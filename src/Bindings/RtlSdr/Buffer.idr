module Bindings.RtlSdr.Buffer

import public Bindings.RtlSdr.Raw.Buffer
import Bindings.RtlSdr.Device
import Bindings.RtlSdr.Error
import Bindings.RtlSdr.Raw.Support

import System.FFI

%default total

export
resetBuffer : Ptr RtlSdrHandle -> IO (Either RTLSDR_ERROR ())
resetBuffer h = do
  r <- fromPrim $ reset_buffer h
  io_pure $ if r == 0 then Right () else Left RtlSdrError

public export
record IQ where
  constructor MkIQ
  iVal : Int16
  qVal : Int16

export
Eq IQ where
  a == b = (iVal a, qVal a) == (iVal b, qVal b)
  a /= b = not (a == b)

export
Num IQ where
  MkIQ a b + MkIQ a' b' = MkIQ (a+a') (b+b')
  MkIQ a b * MkIQ a' b' = MkIQ (a*a' + b*b') (a*b' + b*a')
  fromInteger x = MkIQ (cast x) 0

-- Turn [U8] into [S16] re-centred around zero.
scaleIQ : Bits8 -> Int16
scaleIQ v = (cast {to = Int16} v) - 128

toIQ : Bits8 -> Bits8 -> IQ
toIQ i q = MkIQ (scaleIQ i) (scaleIQ q)

toIQList : List Bits8 -> List IQ
toIQList [] = []
toIQList [_] = []
toIQList (xs::ys::rest) = (toIQ xs ys) :: toIQList rest

||| Read samples from the device synchronously.
|||
||| @h is the device handle
||| @b a pointer to a buffer to write samples to
||| @l the length of the buffer
export
readSync : Ptr RtlSdrHandle -> AnyPtr -> Int -> IO (Either RTLSDR_ERROR Int)
readSync h b l = do
  v <- prim__castPtr <$> malloc 4 -- n_read
  r <- fromPrim $ read_sync h b l v
  let nr = peekInt v
  free $ prim__forgetPtr v
  io_pure $ if r == 0 then Right nr else Left RtlSdrError

||| Call callback closure type signature
public export
ReadAsyncFn : Type
ReadAsyncFn = AnyPtr -> List IQ -> IO ()

||| Read samples from the device asynchronously. This will block until
||| it is being canceled using `cancelAsync`.
|||
||| @h is the device handle
||| @cbIO is the callback closure to received samples
||| @ctx  is a user defined context to pass to the callback closure
||| @bn   optional buffer count, buf_num * buf_len = overall buffer size
|||		    set to 0 for default buffer count (15)
||| @bl   optional buffer length, must be multiple of 512,
|||		    should be a multiple of 16384 (URB size), set to 0
|||		    for default buffer length (16 * 32 * 512)
export
readAsync : Ptr RtlSdrHandle -> ReadAsyncFn -> AnyPtr -> Int -> Int -> IO (Either RTLSDR_ERROR ())
readAsync h cbIO ctx bn bl = do
  let cbPrim = \bufPtr, bufLen, ctxPtr => toPrim $
        cbIO ctxPtr =<< ((io_pure . toIQList) =<< readBufPtr' bufPtr bufLen)
  r <- fromPrim $ read_async h cbPrim ctx bn bl
  io_pure $ if r == 0 then Right () else Left RtlSdrError

||| Cancel all pending asynchronous operations on the device.
|||
||| @h is the device handle
export
cancelAsync : Ptr RtlSdrHandle -> IO (Either RTLSDR_ERROR ())
cancelAsync h = do
  r <- fromPrim $ cancel_async h
  io_pure $ if r == 0 then Right () else Left RtlSdrError
