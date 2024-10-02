module AM

import Data.Buffer
import Data.Bits
import Data.List

import Bindings.RtlSdr

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

demodAM : List IQ -> Int -> List Int16
demodAM xs r = map (mag r) xs

firFilter : Int -> List IQ -> List IQ
firFilter w xs =
  let
    sumIQChunk : List IQ -> IQ
    sumIQChunk xs = foldr (+) (fromInteger 0) xs

    convolveBy : Int -> (List IQ -> IQ) -> List IQ -> IQ -> List IQ
    convolveBy chunkLen _ [] _ = []
    convolveBy chunkLen f xs p with (splitAt (cast chunkLen) xs)
      _ | (chunk, rest) = (f (p :: chunk)) :: (convolveBy chunkLen f rest (f chunk))
  in
    convolveBy w sumIQChunk xs (fromInteger 0)

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
