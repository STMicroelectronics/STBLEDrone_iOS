/*
 * Copyright (c) 2018  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */

import Foundation
import BlueSTSDK


/// feature where transmit the joystick user action
public class STDroneJoystickFeature: BlueSTSDKFeature {
    private static let FEATURE_NAME = "Joystick"
    private static let FIELDS: [BlueSTSDKFeatureField] = []

    private var mLastCommand: UInt8 = 0

    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: STDroneJoystickFeature.FEATURE_NAME)
    }

    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return STDroneJoystickFeature.FIELDS
    }

    public override func extractData(_ timestamp: UInt64, data: Data, dataOffset offset: UInt32)
        -> BlueSTSDKExtractResult {
        return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
    }

    private func write(command: UInt8) {
        write(Data([0, 0, 0, 0, 0, 0, command]))
    }

    /// send the arm command
    public func arm() {
        mLastCommand = 0x04
        write(command: mLastCommand)
    }

    /// send the disarm command
    public func disarm() {
        mLastCommand = 0x00
        write(command: mLastCommand)
    }

    /// send the calibrate command
    public func calibrate() {
        write(command: 0x02)
    }

    public func incYOffset() {
        write(Data([0x01, 0, 0, 0, 0, 0, 0x08]))
    }

    public func decYOffset() {
        write(Data([0x02, 0, 0, 0, 0, 0, 0x08]))
    }

    public func incYRotRightOffset() {
        write(Data([0x03, 0, 0, 0, 0, 0, 0x08]))
    }

    public func incYRotLeftOffset() {
        write(Data([0x04, 0, 0, 0, 0, 0, 0x08]))
    }

    public func incZRotUpOffset() {
        write(Data([0x06, 0, 0, 0, 0, 0, 0x10]))
    }

    public func incZRotDownOffset() {
        write(Data([0x05, 0, 0, 0, 0, 0, 0x10]))
    }

    public func incXRotRightOffset() {
        write(Data([0x07, 0, 0, 0, 0, 0, 0x10]))
    }

    public func incXRotLeftOffset() {
        write(Data([0x08, 0, 0, 0, 0, 0, 0x10]))
    }

    /// move the drone in the specific position
    ///
    /// - Parameters:
    ///   - power: drone motor power 0 = floor, 255 = max power
    ///   - yawRot: rotation in the floor plane, -127 = left, 128 right
    ///   - rollRot: left/right rotation  -127 = left, 128 right
    ///   - pitchRot: up/down rotation, -127 = down, 128 = top
    public func move(power: UInt8, yawRot: Int8, rollRot: Int8, pitchRot: Int8) {
        let normRollRot = UInt8(clamping: Int16(rollRot)+128)
        let normYawRot = UInt8(clamping: Int16(yawRot)+128)
        let normPitchRot = UInt8(clamping: Int16(pitchRot)+128)
        //print("send: \(normYawRot), \(power), \(normRollRot), \(normPitchRot)")
        write(Data([0, normYawRot, power, normRollRot, normPitchRot, 0, mLastCommand]))
    }
}
