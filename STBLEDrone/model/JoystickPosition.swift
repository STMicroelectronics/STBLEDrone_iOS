/*
 * Copyright (c) 2019  STMicroelectronics – All rights reserved
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

/// struct containg the position of all the 4 joystick axis
struct JoystickPosition {

    static let ROTATION_RANGE = Float(-0.5)...Float(0.5)
    static let POWER_RANGE = Float(-1.0)...Float(1.0)

    /// Motor power between 0 and 1
    let power: Float
    /// yaw axis rotation between -0.5 and 0.5
    let yawRotation: Float
    /// roll axis rotation between -0.5 and 0.5
    let rollRotation: Float
    /// pitch axis rotation between -0.5 and 0.5
    let pitchRotation: Float

    
    /// build the position, if a value is out of range is clamped to the nearest correct value
    ///
    /// - Parameters:
    ///   - power: motor power, value between [0,1]
    ///   - yawRotation: yaw rotation, value between [-0.5,0.5]
    ///   - rollRotation: roll rotation, value between [-0.5,0.5]
    ///   - pitchRotation: pitch rotation, value between [-0.5,0.5]
    init(power: Float, yawRotation: Float, rollRotation: Float, pitchRotation: Float) {
        self.power = power.clamp(to: JoystickPosition.POWER_RANGE)
        self.yawRotation = yawRotation.clamp(to: JoystickPosition.ROTATION_RANGE)
        self.rollRotation = rollRotation.clamp(to: JoystickPosition.ROTATION_RANGE)
        self.pitchRotation = pitchRotation.clamp(to: JoystickPosition.ROTATION_RANGE)
    }

}

fileprivate extension Float {
    
    /// clamp the value inside a range
    ///
    /// - Parameter limits: valid range
    /// - Returns: current value or closest range extreme if the value is outside the rage
    func clamp(to limits: ClosedRange<Float>) -> Float {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }

}


/// Possible joystick configuration
///
/// - mode1: Left controller with Throttle, and Yaw, Right controller with: Pitch and Roll
/// - mode2: Left controller with Throttle, and Yaw, Right controller with: Pitch and Roll
enum JoystickMode: UInt8 {
    case mode1
    case mode2
}
