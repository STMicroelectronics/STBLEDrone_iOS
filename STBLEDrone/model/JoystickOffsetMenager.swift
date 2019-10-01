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


/// Object containing the offset to be added to each joystick axis, the default value is 0 for each axis
class JoystickOffsetMenager {

    private static let POWER_OFFSET_FACTOR_KEY = "JoystickOffsetMenager.POWER_OFFSET_FACTOR_KEY"
    private static let YAW_OFFSET_FACTOR_KEY = "JoystickOffsetMenager.YAW_OFFSET_FACTOR_KEY"
    private static let ROLL_OFFSET_FACTOR_KEY = "JoystickOffsetMenager.ROLL_OFFSET_FACTOR_KEY"
    private static let PITCH_OFFSET_FACTOR_KEY = "JoystickOffsetMenager.PITCH_OFFSET_FACTOR_KEY"

    var powerOffset: Float
    var yawOffset: Float
    var rollOffset: Float
    var pitchOffset: Float

    init(powerOffset: Float=0.0, yawOffset: Float=0.0, rollOffset: Float=0.0,
         pitchOffset: Float=0.0) {
        self.powerOffset = powerOffset
        self.yawOffset = yawOffset
        self.rollOffset = rollOffset
        self.pitchOffset = pitchOffset
    }

    
    /// apply the offset to a joystick position
    ///
    /// - Parameter position: current joystick position
    /// - Returns: joystick position with the applaed offset
    func applayOffset(to position: JoystickPosition) -> JoystickPosition {
        return JoystickPosition(power: position.power+powerOffset,
                                yawRotation: position.yawRotation+yawOffset,
                                rollRotation: position.rollRotation+rollOffset,
                                pitchRotation: position.pitchRotation+pitchOffset)
    }

    
    /// save the current parameters into the user settings
    ///
    /// - Parameter container: object where store the current values
    func save(on container: UserDefaults) {

        container.set(powerOffset, forKey: JoystickOffsetMenager.POWER_OFFSET_FACTOR_KEY)
        container.set(yawOffset, forKey: JoystickOffsetMenager.YAW_OFFSET_FACTOR_KEY)
        container.set(rollOffset, forKey: JoystickOffsetMenager.ROLL_OFFSET_FACTOR_KEY)
        container.set(pitchOffset, forKey: JoystickOffsetMenager.PITCH_OFFSET_FACTOR_KEY)

    }

    
    /// load the offset from the user settings
    ///
    /// - Parameter container: object where the settings are stored
    /// - Returns: stored offset or the default value
    static func load(from container: UserDefaults) -> JoystickOffsetMenager {

        let powerOffset = container.float(forKey: JoystickOffsetMenager.POWER_OFFSET_FACTOR_KEY)
        let yawOffset = container.float(forKey: JoystickOffsetMenager.YAW_OFFSET_FACTOR_KEY)
        let rollOffset = container.float(forKey: JoystickOffsetMenager.ROLL_OFFSET_FACTOR_KEY)
        let pitchOffset = container.float(forKey: JoystickOffsetMenager.PITCH_OFFSET_FACTOR_KEY)

        return JoystickOffsetMenager(powerOffset: powerOffset,
                                     yawOffset: yawOffset,
                                     rollOffset: rollOffset,
                                     pitchOffset: pitchOffset)
    }
}
