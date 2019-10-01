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


/// Scale the axis value by a sensitivity factor, applay a non linear scale to the power axis
/// - Note: for the power axis the non linear scale is done before applaying the sensitivity scale
/// - Note: the non linerar scale is y = x*exp(-factor*(x-1))
class JoystickSensitivityMenager {

    private static let POWER_NON_LINEAR_FACTOR_KEY = "JoystickSensitivityMenager.POWER_NON_LINEAR_FACTOR_KEY"
    private static let NOT_FIRST_LOAD_KEY = "JoystickSensitivityMenager.NOT_FIRST_LOAD_KEY"
    private static let POWER_SCALE_FACTOR_KEY = "JoystickSensitivityMenager.POWER_SCALE_FACTOR_KEY"
    private static let YAW_ROTATION_FACTOR_KEY = "JoystickSensitivityMenager.YAW_ROTATION_FACTOR_KEY"
    private static let ROLL_ROTATION_FACTOR_KEY = "JoystickSensitivityMenager.ROLL_ROTATION_FACTOR_KEY"
    private static let PITCH_ROTATION_FACTOR_KEY = "JoystickSensitivityMenager.PITCH_ROTATION_FACTOR_KEY"

    var powerScale: Float
    var powerNonLinearFactor: Float
    var yawRotationScale: Float
    var rollRotationScale: Float
    var pitchRotationScale: Float

    init(powerNonLinearFactor: Float=0.7, powerScale: Float=0.5, yawRotationScale: Float=0.5,
         rollRotationScale: Float=0.5, pitchRotationScale: Float=0.5) {
        self.powerScale = powerScale
        self.powerNonLinearFactor = powerNonLinearFactor
        self.yawRotationScale = yawRotationScale
        self.rollRotationScale = rollRotationScale
        self.pitchRotationScale = pitchRotationScale
    }

    private func applyNonLinerarScale(to value: Float) -> Float {
        return value*exp(-powerNonLinearFactor*(value-1))
    }

    
    /// create a new position where all the value are scaled by its sensitivity values
    ///
    /// - Parameter position: origianl position
    /// - Returns: new position with the scaled value
    func applaySensitivity(to position: JoystickPosition) -> JoystickPosition {
        return JoystickPosition(power: powerScale*applyNonLinerarScale(to: position.power),
                                yawRotation: position.yawRotation*yawRotationScale,
                                rollRotation: position.rollRotation*rollRotationScale,
                                pitchRotation: position.pitchRotation*pitchRotationScale)
    }

    
    /// store the current settings into a user profile db
    ///
    /// - Parameter container: place where store the current settings
    func save(on container: UserDefaults) {
        container.set(true, forKey: JoystickSensitivityMenager.NOT_FIRST_LOAD_KEY)
        container.set(powerScale, forKey: JoystickSensitivityMenager.POWER_SCALE_FACTOR_KEY)
        container.set(powerNonLinearFactor, forKey: JoystickSensitivityMenager.POWER_NON_LINEAR_FACTOR_KEY)
        container.set(yawRotationScale, forKey: JoystickSensitivityMenager.YAW_ROTATION_FACTOR_KEY)
        container.set(rollRotationScale, forKey: JoystickSensitivityMenager.ROLL_ROTATION_FACTOR_KEY)
        container.set(pitchRotationScale, forKey: JoystickSensitivityMenager.PITCH_ROTATION_FACTOR_KEY)

    }

    
    /// Load the settings from the user profile, or create a default object
    ///
    /// - Parameter container: place where serach the stored values
    /// - Returns: last user configuration or the default one
    static func load(from container: UserDefaults) -> JoystickSensitivityMenager {
        guard container.bool(forKey: JoystickSensitivityMenager.NOT_FIRST_LOAD_KEY) else {
            return JoystickSensitivityMenager()
        }
        let powerNonLinear = container.float(forKey: JoystickSensitivityMenager.POWER_NON_LINEAR_FACTOR_KEY)
        let powerScale = container.float(forKey: JoystickSensitivityMenager.POWER_SCALE_FACTOR_KEY)
        let x = container.float(forKey: JoystickSensitivityMenager.YAW_ROTATION_FACTOR_KEY)
        let y = container.float(forKey: JoystickSensitivityMenager.ROLL_ROTATION_FACTOR_KEY)
        let z = container.float(forKey: JoystickSensitivityMenager.PITCH_ROTATION_FACTOR_KEY)

        return JoystickSensitivityMenager(powerNonLinearFactor: powerNonLinear,
                                         powerScale: powerScale,
                                         yawRotationScale: x,
                                         rollRotationScale: y,
                                         pitchRotationScale: z)
    }
}
