||| RtlSdr turns your Realtek RTL2832 based DVB dongle into a SDR receiver.
|||
||| Idris2 bindings to librtl-sdr allows for both low-level thin-bindings
||| as well as high-level fat-bindings.
module Bindings.RtlSdr

import public Bindings.RtlSdr.Buffer as Buffer
import public Bindings.RtlSdr.Device as Device
import public Bindings.RtlSdr.EEProm as EEProm
import public Bindings.RtlSdr.Error as Error
import public Bindings.RtlSdr.Frequency as Frequency
import public Bindings.RtlSdr.Gain as Gain
import public Bindings.RtlSdr.Sampling as Sampling
import public Bindings.RtlSdr.Misc as Misc
