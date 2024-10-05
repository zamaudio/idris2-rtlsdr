module AM

import Data.Buffer
import Data.Bits
import Data.List

import Bindings.RtlSdr


demodAM : List IQ -> Int -> List Int16
demodAM xs r =
  let
    -- Calculate the magnitude of the IQ vector and scale it,
    -- scale is defined as S16_MAX_SZ/(128*downsample_rate)
    mag : Int -> IQ -> Int16
    mag r (MkIQ i q) =
      let
        ii : Double
        ii = cast i * cast i

        qq : Double
        qq = cast q * cast q

        s : Double
        -- 256.0 which equals cast $ (1 `shiftL` 15) `div` 128
        s = cast $ 256 `div` r
      in
        cast $ sqrt ( ii + qq ) * s
  in
    map (mag r) xs

firFilter : Int -> List IQ -> List IQ
firFilter w [] = []
firFilter w (x :: xs) =
  let
    sumIQChunk : List IQ -> IQ
    sumIQChunk xs = foldr (+) (fromInteger 0) xs

    convolveBy : Nat -> IQ -> List IQ -> List IQ
    convolveBy l _ [] = []
    convolveBy l x xs with (splitAt l xs)
      _ | (chunk, rest) = (sumIQChunk (x :: chunk)) :: convolveBy l (sumIQChunk chunk) rest
  in
    convolveBy (cast (w-1)) x xs

thresholdFilter : Int -> List Int16 -> List Int16
thresholdFilter t xs =
  let
    -- t is specified in dBFS without a minus sign, so we negate the value here
    thresh_dBFS : Double
    thresh_dBFS = cast (-t)

    thresh_raw : Int16
    thresh_raw = cast $ (32767.0 * exp(0.05 * thresh_dBFS * log(10.0)))
  in
    map (\v => if abs(v) < thresh_raw then 0 else v) xs

export
demodAMStream : List IQ -> Int -> Int -> List Int16
demodAMStream l dsr t =
  let
    dsample : List IQ
    dsample = firFilter dsr l
    demod   : List Int16
    demod   = demodAM dsample dsr
  in
    thresholdFilter t demod
