module AM

import Data.Buffer
import Data.Bits
import Data.List

import Bindings.RtlSdr

-- Calculate the magnitude of the IQ vector and scale it,
-- scale is defined as S16_MAX_SZ/128.
mag : IQ -> Int16
mag (MkIQ i q) =
  let
    ii : Double
    ii = cast i * cast i

    qq : Double
    qq = cast q * cast q

    s : Double
    s = 256.0 -- which equals cast $ (1 `shiftL` 15) `div` 128
  in
    cast $ sqrt ( ii + qq ) * s

demodAM : List IQ -> List Int16
demodAM = map mag

averagedList : List IQ -> IQ
averagedList xs =
  let
    len : Int16
    len = cast $ length xs

    divIQ : IQ -> Int16 -> IQ
    divIQ (MkIQ i q) d = MkIQ (i `div` d) (q `div` d)

    sumIQs : List IQ -> IQ
    sumIQs xs = foldr (+) (fromInteger 0) xs

  in
    divIQ (sumIQs xs) len

downSample : Int -> (List IQ -> IQ) -> List IQ -> List IQ
downSample chunkLen _ [] = []
downSample chunkLen f xs with (splitAt (cast chunkLen) xs)
  _ | (chunk, rest) = (f chunk) :: (downSample chunkLen f rest)

firFilter : Int -> List IQ -> List IQ
firFilter w xs = downSample w averagedList xs

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
    demod   = demodAM dsample
  in
    thresholdFilter t demod
