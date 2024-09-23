module AM

import Data.Buffer
import Data.List

mag : Int -> (i, q : Int16) -> Int16
mag s i q =
  let
    ii : Double
    ii = cast i * cast i

    qq : Double
    qq = cast q * cast q
  in
    cast $ sqrt ( ii + qq ) * (cast s)

demodAM : Int -> List Int16 -> List Int16
demodAM _ [] = []
demodAM s [_] = []
demodAM s (i :: q :: rest) =
  let w = mag s i q
    in w :: demodAM s rest

average : List Int16 -> Int16
average xs = cast {to = Int16} $
  foldr ((+) . cast {to = Int}) 0 xs `div` cast (length xs)

downSample : Int -> List Int16 -> List Int16
downSample chunkLen [] = []
downSample chunkLen xs with (splitAt (cast chunkLen) xs)
  _ | (chunk, rest) = average chunk :: downSample chunkLen rest

thresholdFilter : Int -> List Int16 -> List Int16
thresholdFilter t xs = map (\v => if v > (cast t) then v else 0) xs

scaleStream : List Int8 -> List Int16
scaleStream l = map (\i => cast {to = Int16} i - 127) l

export
demodAMStream : List Int8 -> Int -> Int -> Int -> List Int16
demodAMStream s ds scale thres = thresholdFilter thres ( downSample ds $ demodAM scale $ scaleStream s )
