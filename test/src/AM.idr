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
demodAM [] = []
demodAM [_] = []
demodAM (iq :: rest) =
  let w = mag iq
    in w :: demodAM rest

average : List Int16 -> Int16
average xs = cast {to = Int16} $
  foldr ((+) . cast {to = Int}) 0 xs `div` cast (length xs)

downSample : Int -> (List Int16 -> Int16) -> List Int16 -> List Int16
downSample chunkLen _ [] = []
downSample chunkLen f xs with (splitAt (cast chunkLen) xs)
  _ | (chunk, rest) = f chunk :: downSample chunkLen f rest

thresholdFilter : Int -> List Int16 -> List Int16
thresholdFilter t xs = map (\v => if abs(v) > (cast t) then v else 0) xs

export
demodAMStream : List IQ -> Int -> Int -> List Int16
demodAMStream l dsr t =
  let
    demod   : List Int16
    demod   = demodAM l
    dsample : List Int16
    dsample = downSample dsr average demod
  in
    thresholdFilter t dsample
