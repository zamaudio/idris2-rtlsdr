module AM

import Data.Buffer
import Data.Bits
import Data.List

-- Calculate the magnitude of the IQ vector and scale it,
-- scale is defined as S16_MAX_SZ/128.
mag : (i, q : Int16) -> Int16
mag i q =
  let
    ii : Double
    ii = cast i * cast i

    qq : Double
    qq = cast q * cast q

    s : Double
    s = cast $ (1 `shiftL` 15) `div` 128
  in
    cast $ sqrt ( ii + qq ) * s

demodAM : List Int16 -> List Int16
demodAM [] = []
demodAM [_] = []
demodAM (i :: q :: rest) =
  let w = mag i q
    in w :: demodAM rest

average : List Int16 -> Int16
average xs = cast {to = Int16} $
  foldr ((+) . cast {to = Int}) 0 xs `div` cast (length xs)

downSample : Int -> List Int16 -> List Int16
downSample chunkLen [] = []
downSample chunkLen xs with (splitAt (cast chunkLen) xs)
  _ | (chunk, rest) = average chunk :: downSample chunkLen rest

thresholdFilter : Int -> List Int16 -> List Int16
thresholdFilter t xs = map (\v => if abs(v) > (cast t) then v else 0) xs

-- Turn [U8] into [S16] re-centred around zero.
scaleStream : List Bits8 -> List Int16
scaleStream l = map (\i => cast {to = Int16} i - 127) l

export
demodAMStream : List Bits8 -> Int -> Int -> List Int16
demodAMStream l dsr t =
  let
    demod   : List Int16
    demod   = demodAM $ scaleStream l
    dsample : List Int16
    dsample = downSample dsr demod
  in
    thresholdFilter t dsample
