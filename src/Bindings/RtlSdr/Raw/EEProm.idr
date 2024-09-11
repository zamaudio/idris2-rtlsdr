module Bindings.RtlSdr.Raw.EEProm

import Bindings.RtlSdr.Device

%default total

-- RTLSDR_API int rtlsdr_write_eeprom(rtlsdr_dev_t *dev, uint8_t *data,
-- 				  uint8_t offset, uint16_t len);
export
%foreign (librtlsdr "write_eeprom")
write_eeprom: Ptr RtlSdrHandle -> Ptr Int -> Int -> Int -> Int

-- RTLSDR_API int rtlsdr_read_eeprom(rtlsdr_dev_t *dev, uint8_t *data,
-- 				  uint8_t offset, uint16_t len);
export
%foreign (librtlsdr "read_eeprom")
read_eeprom: Ptr RtlSdrHandle -> Ptr Int -> Int -> Int -> Int
