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
import UIKit

/// View controller that manage the axis sensitivity and joystick mode
class JoystickSettingsViewController: UITableViewController {

    public static func instantiate(modeManger: JoystickModeMenager,
                                   sensitivityManager: JoystickSensitivityMenager) -> UIViewController {
        let bundle = Bundle(for: JoystickSettingsViewController.self)
        let storyBoard = UIStoryboard(name: "STDroneBLE", bundle: bundle)

        //swiftlint:disable force_cast
        let vc = storyBoard.instantiateViewController(withIdentifier: "JoystickSettingsViewController")
            as! JoystickSettingsViewController
        vc.mSensitivityManager = sensitivityManager
        vc.mModeManager = modeManger

        return vc
    }

    @IBOutlet weak var powerScaleLabel: UILabel!
    @IBOutlet weak var powerNonLinearLabel: UILabel!
    @IBOutlet weak var yawLabel: UILabel!
    @IBOutlet weak var rollLabel: UILabel!
    @IBOutlet weak var pitchLabel: UILabel!

    @IBOutlet weak var pitchSelector: UISlider!
    @IBOutlet weak var rollSelector: UISlider!
    @IBOutlet weak var yawSelector: UISlider!
    @IBOutlet weak var powerScaleSelector: UISlider!
    @IBOutlet weak var powerNonLinearSelector: UISlider!

    @IBOutlet weak var modeSelector: UISegmentedControl!

    private var mSensitivityManager: JoystickSensitivityMenager!
    private var mModeManager: JoystickModeMenager!

    @IBAction func onSelectedModeChange(_ sender: UISegmentedControl) {
        mModeManager.currentMode = sender.selectedMode
    }

    override func viewWillAppear(_ animated: Bool) {
        modeSelector.selectedMode = mModeManager.currentMode
        powerNonLinearSelector.value = mSensitivityManager.powerNonLinearFactor
        powerScaleSelector.value = mSensitivityManager.powerScale
        yawSelector.value = mSensitivityManager.yawRotationScale
        rollSelector.value = mSensitivityManager.rollRotationScale
        pitchSelector.value = mSensitivityManager.pitchRotationScale
        updatePowerLablel()
        updateScaleValue(powerScaleLabel, value: mSensitivityManager.powerScale)
        updateScaleValue(yawLabel, value: mSensitivityManager.yawRotationScale)
        updateScaleValue(rollLabel, value: mSensitivityManager.rollRotationScale)
        updateScaleValue(pitchLabel, value: mSensitivityManager.pitchRotationScale)
    }

    override func viewWillDisappear(_ animated: Bool) {
        mSensitivityManager.save(on: UserDefaults.standard)
        mModeManager.save(on: UserDefaults.standard)
    }

    @IBAction func onNonLinearPowerChange(_ sender: UISlider) {
        mSensitivityManager.powerNonLinearFactor = sender.value
        updatePowerLablel()
    }

    @IBAction func onPowerScaleChange(_ sender: UISlider) {
        mSensitivityManager.powerScale = sender.value
        updatePowerLablel()
        updateScaleValue(powerScaleLabel, value: sender.value)
    }

    @IBAction func onRollRotationChange(_ sender: UISlider) {
        mSensitivityManager.rollRotationScale = sender.value
        updateScaleValue(rollLabel, value: sender.value)
    }

    @IBAction func onYawRotationChange(_ sender: UISlider) {
        mSensitivityManager.yawRotationScale = sender.value
        updateScaleValue(yawLabel, value: sender.value)
    }

    @IBAction func onPitchRotationChange(_ sender: UISlider) {
        mSensitivityManager.pitchRotationScale = sender.value
        updateScaleValue(pitchLabel, value: sender.value)
    }

    private func updatePowerLablel() {
        powerNonLinearLabel.text = String(format: "%.2f", mSensitivityManager.powerNonLinearFactor)
    }

    private func updateScaleValue( _ label: UILabel, value: Float) {
        label.text = String(format: "%.2f %", value)
    }

}

fileprivate extension UISegmentedControl {

    var selectedMode: JoystickMode {
        get {
            return self.selectedSegmentIndex == 0 ? .mode1 : .mode2
        }
        set(newValue) {
            switch newValue {
            case .mode1:
                self.selectedSegmentIndex=0
            case .mode2:
                self.selectedSegmentIndex=1
            @unknown default:
                self.selectedSegmentIndex=0
            }
        }
    }

}
