--# selene: allow(unused_variable)
---@diagnostic disable: unused-local

-- MIDI Extension for Hammerspoon.
--
-- This extension supports listening, transmitting and synthesizing MIDI commands.
--
-- This extension was thrown together by [Chris Hocking](http://latenitefilms.com) for [CommandPost](http://commandpost.io).
--
-- This extension uses [MIKMIDI](https://github.com/mixedinkey-opensource/MIKMIDI), an easy-to-use Objective-C MIDI library created by Andrew Madsen and developed by him and Chris Flesner of [Mixed In Key](http://www.mixedinkey.com/).
--
-- MIKMIDI LICENSE:
-- Copyright (c) 2013 Mixed In Key, LLC.
-- Original author: [Andrew R. Madsen](https://github.com/armadsen) (andrew@mixedinkey.com)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
---@class hs.midi
local M = {}
hs.midi = M

-- Sets or removes a callback function for the `hs.midi` object.
--
-- Parameters:
--  * `callbackFn` - a function to set as the callback for this `hs.midi` object.  If the value provided is `nil`, any currently existing callback function is removed.
--
-- Returns:
--  * The `hs.midi` object
--
-- Notes:
--  * Most MIDI keyboards produce a `noteOn` when you press a key, then `noteOff` when you release. However, some MIDI keyboards will return a `noteOn` with 0 `velocity` instead of `noteOff`, so you will receive two `noteOn` commands for every key press/release.
--  * The callback function should expect 5 arguments and should not return anything:
--    * `object`       - The `hs.midi` object.
--    * `deviceName`   - The device name as a string.
--    * `commandType`  - Type of MIDI message as defined as a string. See `hs.midi.commandTypes[]` for a list of possibilities.
--    * `description`  - Description of the event as a string. This is only really useful for debugging.
--    * `metadata`     - A table of data for the MIDI command (see below).
--
--  * The `metadata` table will return the following, depending on the `commandType` for the callback:
--
--    * `noteOff` - Note off command:
--      * note                - The note number for the command. Must be between 0 and 127.
--      * velocity            - The velocity for the command. Must be between 0 and 127.
--      * channel             - The channel for the command. Must be a number between 15.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `noteOn` - Note on command:
--      * note                - The note number for the command. Must be between 0 and 127.
--      * velocity            - The velocity for the command. Must be between 0 and 127.
--      * channel             - The channel for the command. Must be a number between 15.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `polyphonicKeyPressure` - Polyphonic key pressure command:
--      * note                - The note number for the command. Must be between 0 and 127.
--      * pressure            - Key pressure of the polyphonic key pressure message. In the range 0-127.
--      * channel             - The channel for the command. Must be a number between 15.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `controlChange` - Control change command. This is the most common command sent by MIDI controllers:
--      * controllerNumber    - The MIDI control number for the command.
--      * controllerValue     - The controllerValue of the command. Only the lower 7-bits of this are used.
--      * channel             - The channel for the command. Must be a number between 15.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * fourteenBitValue    - The 14-bit value of the command.
--      * fourteenBitCommand  - `true` if the command contains 14-bit value data otherwise, `false`.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `programChange` - Program change command:
--      * programNumber       - The program (aka patch) number. From 0-127.
--      * channel             - The channel for the command. Must be a number between 15.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `channelPressure` - Channel pressure command:
--      * pressure            - Key pressure of the channel pressure message. In the range 0-127.
--      * channel             - The channel for the command. Must be a number between 15.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `pitchWheelChange` - Pitch wheel change command:
--      * pitchChange         -  A 14-bit value indicating the pitch bend. Center is 0x2000 (8192). Valid range is from 0-16383.
--      * channel             - The channel for the command. Must be a number between 15.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `systemMessage` - System message command:
--      * dataByte1           - Data Byte 1 as integer.
--      * dataByte2           - Data Byte 2 as integer.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `systemExclusive` - System message command:
--      * manufacturerID      - The manufacturer ID for the command. This is used by devices to determine if the message is one they support.
--      * sysexChannel        - The channel of the message. Only valid for universal exclusive messages, will always be 0 for non-universal messages.
--      * sysexData           - The system exclusive data for the message. For universal messages subID's are included in sysexData, for non-universal messages, any device specific information (such as modelID, versionID or whatever manufactures decide to include) will be included in sysexData.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `systemTimecodeQuarterFrame` - System exclusive (SysEx) command:
--      * dataByte1           - Data Byte 1 as integer.
--      * dataByte2           - Data Byte 2 as integer.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `systemSongPositionPointer` - System song position pointer command:
--      * dataByte1           - Data Byte 1 as integer.
--      * dataByte2           - Data Byte 2 as integer.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `systemSongSelect` - System song select command:
--      * dataByte1           - Data Byte 1 as integer.
--      * dataByte2           - Data Byte 2 as integer.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `systemTuneRequest` - System tune request command:
--      * dataByte1           - Data Byte 1 as integer.
--      * dataByte2           - Data Byte 2 as integer.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `systemTimingClock` - System timing clock command:
--      * dataByte1           - Data Byte 1 as integer.
--      * dataByte2           - Data Byte 2 as integer.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `systemStartSequence` - System timing clock command:
--      * dataByte1           - Data Byte 1 as integer.
--      * dataByte2           - Data Byte 2 as integer.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `systemContinueSequence` - System start sequence command:
--      * dataByte1           - Data Byte 1 as integer.
--      * dataByte2           - Data Byte 2 as integer.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `systemStopSequence` -  System continue sequence command:
--      * dataByte1           - Data Byte 1 as integer.
--      * dataByte2           - Data Byte 2 as integer.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--    * `systemKeepAlive` - System keep alive message:
--      * dataByte1           - Data Byte 1 as integer.
--      * dataByte2           - Data Byte 2 as integer.
--      * timestamp           - The timestamp for the command as a string.
--      * data                - Raw MIDI Data as Hex String.
--      * isVirtual           - `true` if Virtual MIDI Source otherwise `false`.
--
--  * Example Usage:
--    ```lua
--    midiDevice = hs.midi.new(hs.midi.devices()[3])
--    midiDevice:callback(function(object, deviceName, commandType, description, metadata)
--               print("object: " .. tostring(object))
--               print("deviceName: " .. deviceName)
--               print("commandType: " .. commandType)
--               print("description: " .. description)
--               print("metadata: " .. hs.inspect(metadata))
--               end)```
function M:callback(callbackFn, ...) end

-- A table containing the numeric value for the possible flags returned by the `commandType` parameter of the callback function.
--
-- Defined keys are:
--   * noteOff                       - Note off command.
--   * noteOn                        - Note on command.
--   * polyphonicKeyPressure         - Polyphonic key pressure command.
--   * controlChange                 - Control change command. This is the most common command sent by MIDI controllers.
--   * programChange                 - Program change command.
--   * channelPressure               - Channel pressure command.
--   * pitchWheelChange              - Pitch wheel change command.
--   * systemMessage                 - System message command.
--   * systemExclusive               - System message command.
--   * SystemTimecodeQuarterFrame    - System exclusive (SysEx) command.
--   * systemSongPositionPointer     - System song position pointer command.
--   * systemSongSelect              - System song select command.
--   * systemTuneRequest             - System tune request command.
--   * systemTimingClock             - System timing clock command.
--   * systemStartSequence           - System timing clock command.
--   * systemContinueSequence        - System start sequence command.
--   * systemStopSequence            - System continue sequence command.
--   * systemKeepAlive               - System keep alive message.
---@type table
M.commandTypes = {}

-- A callback that's triggered when a physical or virtual MIDI device is added or removed from the system.
--
-- Parameters:
--  * callbackFn - the callback function to trigger.
--
-- Returns:
--  * None
--
-- Notes:
--  * The callback function should expect 2 argument and should not return anything:
--    * `devices` - A table containing the names of any physically connected MIDI devices as strings.
--    * `virtualDevices` - A table containing the names of any virtual MIDI devices as strings.
--  * Example Usage:
--    ```lua
--    hs.midi.deviceCallback(function(devices, virtualDevices)
--         print(hs.inspect(devices))
--         print(hs.inspect(virtualDevices))
--    end)```
function M.deviceCallback(callbackFn, ...) end

-- Returns a table of currently connected physical MIDI devices.
--
-- Parameters:
--  * None
--
-- Returns:
--  * A table containing the names of any physically connected MIDI devices as strings.
function M.devices() end

-- Returns the display name of a `hs.midi` object.
--
-- Parameters:
--  * None
--
-- Returns:
--  * The name as a string.
---@return string
function M:displayName() end

-- Sends an Identity Request message to the `hs.midi` device. You can use `hs.midi:callback()` to receive the `systemExclusive` response.
--
-- Parameters:
--  * None
--
-- Returns:
--  * None
--
-- Notes:
--  * Example Usage:
--   ```lua
--   midiDevice = hs.midi.new(hs.midi.devices()[3])
--   midiDevice:callback(function(object, deviceName, commandType, description, metadata)
--                         print("object: " .. tostring(object))
--                         print("deviceName: " .. deviceName)
--                         print("commandType: " .. commandType)
--                         print("description: " .. description)
--                         print("metadata: " .. hs.inspect(metadata))
--                       end)
--   midiDevice:identityRequest()```
function M:identityRequest() end

-- Returns the online status of a `hs.midi` object.
--
-- Parameters:
--  * None
--
-- Returns:
--  * `true` if online, otherwise `false`
---@return boolean
function M:isOnline() end

-- Returns `true` if an `hs.midi` object is virtual, otherwise `false`.
--
-- Parameters:
--  * None
--
-- Returns:
--  * `true` if virtual, otherwise `false`
---@return boolean
function M:isVirtual() end

-- Returns the manufacturer name of a `hs.midi` object.
--
-- Parameters:
--  * None
--
-- Returns:
--  * The manufacturer name as a string.
---@return string
function M:manufacturer() end

-- Returns the model name of a `hs.midi` object.
--
-- Parameters:
--  * None
--
-- Returns:
--  * The model name as a string.
---@return string
function M:model() end

-- Returns the name of a `hs.midi` object.
--
-- Parameters:
--  * None
--
-- Returns:
--  * The name as a string.
---@return string
function M:name() end

-- Creates a new `hs.midi` object.
--
-- Parameters:
--  * deviceName - A string containing the device name of the MIDI device. A valid device name can be found by checking `hs.midi.devices()` and/or `hs.midi.virtualSources()`.
--
-- Returns:
--  * An `hs.midi` object or `nil` if an error occurred.
--
-- Notes:
--  * Example Usage:
--    `hs.midi.new(hs.midi.devices()[1])`
function M.new(deviceName, ...) end

-- Creates a new `hs.midi` object.
--
-- Parameters:
--  * virtualSource - A string containing the virtual source name of the MIDI device. A valid virtual source name can be found by checking `hs.midi.virtualSources()`.
--
-- Returns:
--  * An `hs.midi` object or `nil` if an error occurred.
--
-- Notes:
--  * Example Usage:
--    `hs.midi.newVirtualSource(hs.midi.virtualSources()[1])`
function M.newVirtualSource(virtualSource, ...) end

-- Sends a command to the `hs.midi` object.
--
-- Parameters:
--  * `commandType`    - The type of command you want to send as a string. See `hs.midi.commandTypes[]`.
--  * `metadata`       - A table of data for the MIDI command (see notes below).
--
-- Returns:
--  * `true` if successful, otherwise `false`
--
-- Notes:
--  * The `metadata` table can accept following, depending on the `commandType` supplied:
--
--    * `noteOff` - Note off command:
--      * note                - The note number for the command. Must be between 0 and 127. Defaults to 0.
--      * velocity            - The velocity for the command. Must be between 0 and 127. Defaults to 0.
--      * channel             - The channel for the command. Must be a number between 0 and 16. Defaults to 0, which sends the command to All Channels.
--
--    * `noteOn` - Note on command:
--      * note                - The note number for the command. Must be between 0 and 127. Defaults to 0.
--      * velocity            - The velocity for the command. Must be between 0 and 127. Defaults to 0.
--      * channel             - The channel for the command. Must be a number between 0 and 16. Defaults to 0, which sends the command to All Channels.
--
--    * `polyphonicKeyPressure` - Polyphonic key pressure command:
--      * note                - The note number for the command. Must be between 0 and 127. Defaults to 0.
--      * pressure            - Key pressure of the polyphonic key pressure message. In the range 0-127. Defaults to 0.
--      * channel             - The channel for the command. Must be a number between 0 and 16. Defaults to 0, which sends the command to All Channels.
--
--    * `controlChange` - Control change command. This is the most common command sent by MIDI controllers:
--      * controllerNumber    - The MIDI control number for the command. Defaults to 0.
--      * controllerValue     - The controllerValue of the command. Only the lower 7-bits of this are used. Defaults to 0.
--      * channel             - The channel for the command. Must be a number between 0 and 16. Defaults to 0, which sends the command to All Channels.
--      * fourteenBitValue    - The 14-bit value of the command. Must be between 0 and 16383. Defaults to 0. `fourteenBitCommand` must be `true`.
--      * fourteenBitCommand  - `true` if the command contains 14-bit value data otherwise, `false`. `controllerValue` will be ignored if this is set to `true`.
--
--    * `programChange` - Program change command:
--      * programNumber       - The program (aka patch) number. From 0-127. Defaults to 0.
--      * channel             - The channel for the command. Must be a number between 0 and 16. Defaults to 0, which sends the command to All Channels.
--
--    * `channelPressure` - Channel pressure command:
--      * pressure            - Key pressure of the channel pressure message. In the range 0-127. Defaults to 0.
--      * channel             - The channel for the command. Must be a number between 0 and 16. Defaults to 0, which sends the command to All Channels.
--
--    * `pitchWheelChange` - Pitch wheel change command:
--      * pitchChange         -  A 14-bit value indicating the pitch bend. Center is 0x2000 (8192). Valid range is from 0-16383. Defaults to 0.
--      * channel             - The channel for the command. Must be a number between 0 and 16. Defaults to 0, which sends the command to All Channels.
--
--  * Example Usage:
--     ```lua
--     midiDevice = hs.midi.new(hs.midi.devices()[1])
--     midiDevice:sendCommand("noteOn", {
--         ["note"] = 72,
--         ["velocity"] = 50,
--         ["channel"] = 0,
--     })
--     hs.timer.usleep(500000)
--     midiDevice:sendCommand("noteOn", {
--         ["note"] = 74,
--         ["velocity"] = 50,
--         ["channel"] = 0,
--     })
--     hs.timer.usleep(500000)
--     midiDevice:sendCommand("noteOn", {
--         ["note"] = 76,
--         ["velocity"] = 50,
--         ["channel"] = 0,
--     })
--     midiDevice:sendCommand("pitchWheelChange", {
--         ["pitchChange"] = 1000,
--         ["channel"] = 0,
--     })
--     hs.timer.usleep(100000)
--     midiDevice:sendCommand("pitchWheelChange", {
--         ["pitchChange"] = 2000,
--         ["channel"] = 0,
--     })
--     hs.timer.usleep(100000)
--     midiDevice:sendCommand("pitchWheelChange", {
--         ["pitchChange"] = 3000,
--         ["channel"] = 0,
--     })```
---@return boolean
function M:sendCommand(commandType, metadata, ...) end

-- Sends a System Exclusive Command to the `hs.midi` object.
--
-- Parameters:
--  * `command` - The system exclusive command you wish to send as a string. White spaces in the string will be ignored.
--
-- Returns:
--  * None
--
-- Notes:
--  * Example Usage:
--    ```lua
--    midiDevice:sendSysex("f07e7f06 01f7")```
function M:sendSysex(command, ...) end

-- Set or display whether or not the MIDI device should synthesize audio on your computer.
--
-- Parameters:
--  * [value] - `true` if you want to synthesize audio, otherwise `false`.
--
-- Returns:
--  * `true` if enabled otherwise `false`
---@return boolean
function M:synthesize(value, ...) end

-- Returns a table of currently available Virtual MIDI sources. This includes devices, such as Native Instruments controllers which present as virtual endpoints rather than physical devices.
--
-- Parameters:
--  * None
--
-- Returns:
--  * A table containing the names of any virtual MIDI sources as strings.
function M.virtualSources() end

