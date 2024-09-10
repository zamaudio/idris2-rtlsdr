module Bindings.RtlSdr.Raw.Support

import System.FFI

%default total

-- wrapper C func helper.
idris_rtlsdr : String -> String
idris_rtlsdr fn = "C:" ++ "idris_rtlsdr_" ++ fn ++ ",rtlsdr-idris"

-- XXX support/ runtime wraps
export
%foreign (idris_rtlsdr "open")
idris_rtlsdr_open : Int -> Ptr Int -> PrimIO AnyPtr

-- XXX support/.. int read_ptr_ref(int *p, int off);
export
%foreign (idris_rtlsdr "read_ptr_ref")
idris_rtlsdr_read_ptr_ref : Ptr Int -> Int -> Int
