module Bindings.RtlSdr.Device

export
data RtlSdrHandle = MkDevice AnyPtr

public export
librtlsdr : String -> String
librtlsdr fn = "C:" ++ "rtlsdr_" ++ fn ++ ",librtlsdr"


idris_rtlsdr : String -> String
idris_rtlsdr fn = "C:" ++ "idris_" ++ fn ++ ",idris_rtlsdr"

%foreign (idris_rtlsdr "is_null")
idris_is_null : AnyPtr -> IO Bool

%foreign (idris_rtlsdr "rtlsdr_open")
idris_rtlsdr_open : Int -> IO AnyPtr

export
rtlsdr_open : Int -> IO (Maybe RtlSdrHandle)
rtlsdr_open idx = do
    res <- idris_rtlsdr_open idx -- mkForeign (FFun "idris_rtlsdr_open" [FInt] FPtr) idx
    is_null <- idris_is_null res -- nullPtr res
    io_pure $ if is_null then Nothing else Just (MkDevice res)


-- RTLSDR_API uint32_t rtlsdr_get_device_count(void);
export
%foreign (librtlsdr "get_device_count")
get_device_count: Int

-- RTLSDR_API const char* rtlsdr_get_device_name(uint32_t index);
export
%foreign (librtlsdr "get_device_name")
get_device_name: Int -> String

--  RtlSdrHandle = AnyPtr

-- RTLSDR_API int rtlsdr_open(rtlsdr_dev_t **dev, uint32_t index);
--  export
--  %foreign (librtlsdr "open")
--  openRtlSdr: Ptr RtlSdrHandle -> Int -> PrimIO Int

-- RTLSDR_API int rtlsdr_close(rtlsdr_dev_t *dev);
export
%foreign (librtlsdr "close")
close: RtlSdrHandle -> PrimIO Int
