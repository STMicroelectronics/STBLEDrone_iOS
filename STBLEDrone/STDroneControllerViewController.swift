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
import UIKit
import SceneKit
import SpriteKit
import BlueSTSDK
import BlueSTSDK_Gui

/// View Controller that is displaing the joystick to drive the drone
//swiftlint:disable type_body_length
class STDroneControllerViewController: UIViewController, BlueSTSDKDemoViewProtocol {

    private static let ERROR_TITLE: String = {
        let bundle = Bundle(for: STDroneControllerViewController.self)
        return NSLocalizedString("Error", tableName: nil,
                                 bundle: bundle,
                                 value: "Error",
                                 comment: "Error")
    }()

    private static let ERROR_INVALID_NODE: String = {
        let bundle = Bundle(for: STDroneControllerViewController.self)
        return NSLocalizedString("Invalid node", tableName: nil,
                                 bundle: bundle,
                                 value: "Invalid node",
                                 comment: "Invalid node")
    }()

    private static let WARNING_TITLE: String = {
        let bundle = Bundle(for: STDroneControllerViewController.self)
        return NSLocalizedString("Warning", tableName: nil,
                                 bundle: bundle,
                                 value: "Warning",
                                 comment: "Warning")
    }()

    private static let WARNING_DO_CALIBRATION: String = {
        let bundle = Bundle(for: STDroneControllerViewController.self)
        return NSLocalizedString("Do the calibration before", tableName: nil,
                                 bundle: bundle,
                                 value: "Do the calibration before",
                                 comment: "Do the calibration before")
    }()

    private static let OFFSET: String = {
        let bundle = Bundle(for: STDroneControllerViewController.self)
        return NSLocalizedString("Offset", tableName: nil,
                                 bundle: bundle,
                                 value: "Offset",
                                 comment: "Offset")
    }()

    private static let SETTINGS: String = {
        let bundle = Bundle(for: STDroneControllerViewController.self)
        return NSLocalizedString("Settings", tableName: nil,
                                 bundle: bundle,
                                 value: "Settings",
                                 comment: "Settings")
    }()

    private static let SHOW_DETAILS: String = {
        let bundle = Bundle(for: STDroneControllerViewController.self)
        return NSLocalizedString("Show details", tableName: nil,
                                 bundle: bundle,
                                 value: "Show details",
                                 comment: "Show details")
    }()

    private static let HIDE_DETAILS: String = {
        let bundle = Bundle(for: STDroneControllerViewController.self)
        return NSLocalizedString("Hide details", tableName: nil,
                                 bundle: bundle,
                                 value: "Hide details",
                                 comment: "Hide details")
    }()

    private static let ARM: String = {
        let bundle = Bundle(for: STDroneControllerViewController.self)
        return NSLocalizedString("Arm", tableName: nil,
                                 bundle: bundle,
                                 value: "Arm",
                                 comment: "Arm")
    }()

    private static let DISARM: String = {
        let bundle = Bundle(for: STDroneControllerViewController.self)
        return NSLocalizedString("Disarm", tableName: nil,
                                 bundle: bundle,
                                 value: "Disarm",
                                 comment: "Disarm")
    }()

    private static let STATUS_FORMAT: String = {
        let bundle = Bundle(for: STDroneControllerViewController.self)
        return NSLocalizedString("Status: %@", tableName: nil,
                                 bundle: bundle,
                                 value: "Status: %@",
                                 comment: "Status: %@")
    }()

    private static let LEFT_CONTROLLER_FORMAT: String = {
        let bundle = Bundle(for: STDroneControllerViewController.self)
        return NSLocalizedString("Power :%.0f Yaw: %.0f", tableName: nil,
                                 bundle: bundle,
                                 value: "Power :%.0f Yaw: %.0f",
                                 comment: "Power :%.0f Yaw: %.0f")
    }()

    private static let RIGHT_CONTROLLER_FORMAT: String = {
        let bundle = Bundle(for: STDroneControllerViewController.self)
        return NSLocalizedString("Roll: %.0f Pitch: %.0f", tableName: nil,
                                 bundle: bundle,
                                 value: "Roll: %.0f Pitch: %.0f",
                                 comment: "Roll: %.0f Pitch: %.0f")
    }()

    private static let DRONE_INTERVAL_UPDATE: TimeInterval = 1/20.0
    private static let DRONE_COORDINATE_RANGE = Float(256)
    private static let DEFAULT_JOYSTICK_SCALE_FACTOR = CGFloat(128)
    private static let POWER_INITIAL_POSITION = CGPoint(x: 0, y: -1)

    
    /// remote drone
    var node: BlueSTSDKNode!
    var menuDelegate: BlueSTSDKViewControllerMenuDelegate?

    
    /// acceleration data from the drone
    private var mAccelerationFeature: BlueSTSDKFeatureAcceleration?
    
    /// gyroscope data from the drone
    private var mGyroscopeFeature: BlueSTSDKFeatureGyroscope?
    
    /// battery data from the drone
    private var mBatteryFeature: STDroneBatteryFeature?
    
    /// signal power data from the done
    private var mRssiFeature: STDroneRSSIFeature?
    
    /// object where send the joystick position
    private var mJoystickFeature: STDroneJoystickFeature?

    /// visiblility status of the details label
    private var mIsDetailsHidden: Bool = true

    /// Drone status, uncalibrated ->calibrating -> calibrated -> armed
    private var mDroneStatus: DroneStatus = .uncalibrated {
        didSet { // update the label when the status change
            labelStatus.text = String(format: STDroneControllerViewController.STATUS_FORMAT, mDroneStatus.description)
        }
    }
    
    /// timer used to read the joystick position and send the data to the drone
    private var mUpdateTimer: Timer?

    @IBOutlet weak var rightOffsetView: UIView!
    @IBOutlet weak var leftOffsetView: UIView!
    @IBOutlet weak var rightOffsetLabel: UILabel!
    @IBOutlet weak var leftOffsetLabel: UILabel!

    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var labelBattery: UILabel!
    @IBOutlet weak var labelRSSI: UILabel!
    @IBOutlet weak var labelLeftAS: UILabel!
    @IBOutlet weak var labelRightAS: UILabel!
    @IBOutlet weak var leftAnalogStickSKView: SKView!
    @IBOutlet weak var rightAnalogStickSKView: SKView!

    @IBOutlet weak var accelerationDetails: UILabel!
    @IBOutlet weak var gyroscopeDetails: UILabel!

    private var mActionSettings: UIAlertAction!

    private var mLeftJoystick: JoystickScene!
    private var mRightJoystick: JoystickScene!

    /// object that stores the axis sensibility settings
    private var mSensitivyManager: JoystickSensitivityMenager!
    
    /// object that store the axis mode selected by the user
    private var mModeManager: JoystickModeMenager!
    
    /// object that store the axis offset
    private var mOffsetManager: JoystickOffsetMenager!

    override func viewDidLoad() {
        super.viewDidLoad()
        mSensitivyManager = JoystickSensitivityMenager.load(from: UserDefaults.standard)
        mModeManager = JoystickModeMenager.load(from: UserDefaults.standard)
        mOffsetManager = JoystickOffsetMenager.load(from: UserDefaults.standard)

        addSettingsMenuItem()

        mDroneStatus = .uncalibrated
    }

    /// build the left and right joystick view when the user select the mode 1:
    /// Left controller with Pitch, and Yaw
    /// Right controller with: Throttle and Roll
    private func buildMode1View() {
        mLeftJoystick = JoystickScene(size: leftAnalogStickSKView.frame.size,
                                      topImage: SKTexture(imageNamed: "pitch_down"),
                                      bottomImage: SKTexture(imageNamed: "pitch_up"),
                                      leftImage: SKTexture(imageNamed: "yaw_left"),
                                      rightImage: SKTexture(imageNamed: "yaw_right"))
        mLeftJoystick.resetDelegate = ResetToCenterPosition()
        mLeftJoystick.normalizedPosition = CGPoint(x: 0, y: 0)
        leftAnalogStickSKView.presentScene(mLeftJoystick)

        mRightJoystick = JoystickScene(size: rightAnalogStickSKView.frame.size,
                                         topImage: SKTexture(imageNamed: "power_up"),
                                         bottomImage: SKTexture(imageNamed: "power_up"),
                                         leftImage: SKTexture(imageNamed: "roll_left"),
                                         rightImage: SKTexture(imageNamed: "roll_left"))
        mRightJoystick.resetDelegate = ResetXPosition()
        mRightJoystick.normalizedPosition = STDroneControllerViewController.POWER_INITIAL_POSITION
        rightAnalogStickSKView.presentScene(mRightJoystick)

    }

    
    /// extract the joystick position assuming the axis configuration in mode 1
    ///
    /// - Returns: current position of all the joystick axis
    private func extractPositionFromMode1() -> JoystickPosition {
        // Left controller with Pitch, and Yaw
        // Right controller with: Throttle and Roll
        let leftPosition = mLeftJoystick.normalizedPosition
        let rightPosition = mRightJoystick.normalizedPosition
        return JoystickPosition(power: Float((rightPosition.y+1)/2),
                                yawRotation: Float(leftPosition.x/2),
                                rollRotation: Float(rightPosition.x/2),
                                pitchRotation: Float(leftPosition.y/2))
    }

    /// build the left and right joystick view when the user select the mode 1:
    /// Left controller with Throttle, and Yaw
    /// Right controller with: Pitch and Roll
    private func buildMode2View() {

        mLeftJoystick = JoystickScene(size: leftAnalogStickSKView.frame.size,
                                      topImage: SKTexture(imageNamed: "power_up"),
                                      bottomImage: SKTexture(imageNamed: "power_down"),
                                      leftImage: SKTexture(imageNamed: "yaw_left"),
                                      rightImage: SKTexture(imageNamed: "yaw_right"))
        mLeftJoystick.resetDelegate = ResetXPosition()
        mLeftJoystick.normalizedPosition = STDroneControllerViewController.POWER_INITIAL_POSITION
        leftAnalogStickSKView.presentScene(mLeftJoystick)

        mRightJoystick = JoystickScene(size: rightAnalogStickSKView.frame.size,
                                       topImage: SKTexture(imageNamed: "pitch_down"),
                                       bottomImage: SKTexture(imageNamed: "pitch_up"),
                                       leftImage: SKTexture(imageNamed: "roll_left"),
                                       rightImage: SKTexture(imageNamed: "roll_left"))
        mRightJoystick.resetDelegate = ResetToCenterPosition()
        mRightJoystick.normalizedPosition = CGPoint(x: 0, y: 0)
        rightAnalogStickSKView.presentScene(mRightJoystick)
    }

    /// extract the joystick position assuming the axis configuration in mode 1
    ///
    /// - Returns: current position of all the joystick axis
    private func extractPositionFromMode2() -> JoystickPosition {
        //Mode 2:
        //Left controller with Throttle, and Yaw
        //Right controller with: Pitch and Roll
        let leftPosition = mLeftJoystick.normalizedPosition
        let rightPosition = mRightJoystick.normalizedPosition
        return JoystickPosition(power: Float((leftPosition.y+1)/2),
                                yawRotation: Float(leftPosition.x/2),
                                rollRotation: Float(rightPosition.x/2),
                                pitchRotation: Float(rightPosition.y/2))
    }
    
    private func addSettingsMenuItem() {
        mActionSettings = UIAlertAction(title: STDroneControllerViewController.SETTINGS,
                                      style: .default) { _ in
                                        let vc = JoystickSettingsViewController.instantiate(
                                            modeManger: self.mModeManager,
                                            sensitivityManager: self.mSensitivyManager)
                                        self.changeViewController(vc)
        }
        menuDelegate?.addMenuAction(mActionSettings)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if mModeManager.currentMode == .mode1 {
            buildMode1View()
        } else {
            buildMode2View()
        }
        mJoystickFeature = self.node.getFeatureOfType(STDroneJoystickFeature.self) as? STDroneJoystickFeature
        enableBatteryNotification()
        enableRSSINotification()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mJoystickFeature = nil
        disableAccelerationNotification()
        disableGyroscopeNotification()
        disableBatteryNotification()
        disableRSSINotification()
        disableUpdateTimer()
    }

    
    /// function called by the timer, it read the current joystick position and send it to the drone
    /// the value are first scaled by the sensitivyt and then the offset is added
    @objc private func updateCoords() {
        let position = self.mModeManager.currentMode == .mode1 ?
                extractPositionFromMode1() : extractPositionFromMode2()
        
        let scalePosition = mSensitivyManager.applaySensitivity(to: position)
        let offsetPosition = mOffsetManager.applayOffset(to: scalePosition)
        
        let scaleRange = STDroneControllerViewController.DRONE_COORDINATE_RANGE
        let power = UInt8(clamping: UInt16((offsetPosition.power*scaleRange).rounded()))
        let yaw = Int8(clamping: Int16((offsetPosition.yawRotation*scaleRange).rounded()))
        let roll = Int8(clamping: Int16((offsetPosition.rollRotation*scaleRange).rounded()))
        let pitch = Int8(clamping: Int16((offsetPosition.pitchRotation*scaleRange).rounded()))
        updatePositionLabel(offsetPosition)
        mJoystickFeature?.move(power: power,
                              yawRot: yaw,
                              rollRot: roll,
                              pitchRot: pitch)

    }

    
    /// update the label to show the current joystick position
    ///
    /// - Parameter p: position to show
    private func updatePositionLabel(_ p: JoystickPosition) {
        let scaleRange = STDroneControllerViewController.DRONE_COORDINATE_RANGE
        labelLeftAS.text = String(format: STDroneControllerViewController.LEFT_CONTROLLER_FORMAT,
                                  p.power*scaleRange, p.yawRotation*scaleRange)
        labelRightAS.text = String(format: STDroneControllerViewController.RIGHT_CONTROLLER_FORMAT,
                                   p.rollRotation*scaleRange, p.pitchRotation*scaleRange)
    }

    private func startSendPositionToTheDrone() {
        if let myFeatureJoystick = mJoystickFeature {
            myFeatureJoystick.arm()
            enableUpdateTimer()
            mDroneStatus = .armed
        }
    }

    private func stopSendPositionToTheDrone() {
        if let myFeatureJoystick = mJoystickFeature {
            myFeatureJoystick.disarm()
            disableUpdateTimer()
            mDroneStatus = .calibrated
        }
    }

    
    /// move the drone from the calibrated state to the arm state and viceversa
    /// when in arm state it start sending the joystick position to the drone
    ///
    /// - Parameter sender: button pressed by the user
    @IBAction func onArmButtonPressed(_ sender: UIButton) {
        switch mDroneStatus {
        case .uncalibrated:
            showAllert(title: STDroneControllerViewController.WARNING_TITLE,
                       message: STDroneControllerViewController.WARNING_DO_CALIBRATION)
            return
        case .calibrating:
            return
        case .calibrated:
            startSendPositionToTheDrone()
            sender.setTitle(STDroneControllerViewController.DISARM, for: UIControl.State.normal)
            return
        case .armed, .takeof:
            stopSendPositionToTheDrone()
            sender.setTitle(STDroneControllerViewController.ARM, for: UIControl.State.normal)
            return
        }
    }

    @IBAction func onCalibrateButtonPressed(_ sender: UIButton) {
        guard let joytick = mJoystickFeature else {
            showAllert(title: STDroneControllerViewController.ERROR_TITLE,
                       message: STDroneControllerViewController.ERROR_INVALID_NODE)
            return
        }
        mDroneStatus = .calibrating
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            joytick.calibrate()
            self?.mDroneStatus = .calibrated
        }
    }

    @IBAction func detailsManagement(_ buttonDetails: UIButton) {
        mIsDetailsHidden = !mIsDetailsHidden

        labelLeftAS.isHidden = mIsDetailsHidden
        labelRightAS.isHidden = mIsDetailsHidden
        accelerationDetails.isHidden = mIsDetailsHidden
        gyroscopeDetails.isHidden = mIsDetailsHidden

        if mIsDetailsHidden {
            disableGyroscopeNotification()
            disableAccelerationNotification()
            buttonDetails.setTitle(STDroneControllerViewController.SHOW_DETAILS, for: UIControl.State.normal)
        } else {
            enableGyroscopeNotification()
            enableAccelerationNotification()
            buttonDetails.setTitle(STDroneControllerViewController.HIDE_DETAILS, for: UIControl.State.normal)
        }

    }

    private func enableAccelerationNotification() {
        mAccelerationFeature = self.node.getFeatureOfType(BlueSTSDKFeatureAcceleration.self)
            as? BlueSTSDKFeatureAcceleration
        if let feature = mAccelerationFeature {
            feature.add(self)
            feature.enableNotification()
        }
    }

    private func disableAccelerationNotification() {
        if let feature = mAccelerationFeature {
            feature.remove(self)
            feature.disableNotification()
            mAccelerationFeature = nil
        }
    }

    private func enableGyroscopeNotification() {
        mGyroscopeFeature = self.node.getFeatureOfType(BlueSTSDKFeatureGyroscope.self)
            as? BlueSTSDKFeatureGyroscope
        if let feature = mGyroscopeFeature {
            feature.add(self)
            feature.enableNotification()
        }
    }

    private func disableGyroscopeNotification() {
        if let feature = mGyroscopeFeature {
            feature.remove(self)
            feature.disableNotification()
            mGyroscopeFeature = nil
        }
    }

    private func enableBatteryNotification() {
        mBatteryFeature = self.node.getFeatureOfType(STDroneBatteryFeature.self) as? STDroneBatteryFeature
        if let feature = mBatteryFeature {
            feature.add(self)
            feature.enableNotification()
        }
    }

    private func disableBatteryNotification() {
        if let feature = mBatteryFeature {
            feature.remove(self)
            feature.disableNotification()
            mBatteryFeature = nil
        }
    }

    private func enableRSSINotification() {
        mRssiFeature = self.node.getFeatureOfType(STDroneRSSIFeature.self) as? STDroneRSSIFeature
        if let feature = mRssiFeature {
            feature.add(self)
            feature.enableNotification()
        }
    }

    private func disableRSSINotification() {
        if let feature = mRssiFeature {
            feature.remove(self)
            feature.disableNotification()
            mRssiFeature = nil
        }
    }

    private func enableUpdateTimer() {
        mUpdateTimer = Timer.scheduledTimer(timeInterval: STDroneControllerViewController.DRONE_INTERVAL_UPDATE,
                                           target: self,
                                           selector: #selector(updateCoords),
                                           userInfo: nil,
                                           repeats: true)
    }

    private func disableUpdateTimer() {
        mUpdateTimer = nil
    }

    @IBAction func pitchIncreasePressed(_ sender: UIButton) {
        mOffsetManager.pitchOffset += Float(1/STDroneControllerViewController.DRONE_COORDINATE_RANGE)
        updateRightOffsetLabel()
    }
    @IBAction func pitchDecrasePressed(_ sender: UIButton) {
        mOffsetManager.pitchOffset -= Float(1/STDroneControllerViewController.DRONE_COORDINATE_RANGE)
        updateRightOffsetLabel()
    }
    @IBAction func rollRightIncreasePressed(_ sender: UIButton) {
        mOffsetManager.rollOffset += Float(1/STDroneControllerViewController.DRONE_COORDINATE_RANGE)
        updateRightOffsetLabel()
    }
    @IBAction func rollLeftIncresePressed(_ sender: UIButton) {
        mOffsetManager.rollOffset -= Float(1/STDroneControllerViewController.DRONE_COORDINATE_RANGE)
        updateRightOffsetLabel()
    }

    @IBAction func powerIncresePressed(_ sender: UIButton) {
        mOffsetManager.powerOffset += Float(1/STDroneControllerViewController.DRONE_COORDINATE_RANGE)
        updateLeftOffsetLabel()
    }

    @IBAction func powerDecresePressed(_ sender: UIButton) {
        mOffsetManager.powerOffset -= Float(1/STDroneControllerViewController.DRONE_COORDINATE_RANGE)
        updateLeftOffsetLabel()
    }

    @IBAction func yawLeftIncresePressed(_ sender: UIButton) {
        mOffsetManager.yawOffset -= Float(1/STDroneControllerViewController.DRONE_COORDINATE_RANGE)
        updateLeftOffsetLabel()
    }

    @IBAction func yawRightIncreasePressed(_ sender: UIButton) {
        mOffsetManager.yawOffset += Float(1/STDroneControllerViewController.DRONE_COORDINATE_RANGE)
        updateLeftOffsetLabel()
    }

    @IBAction func onShowOffsetPressed(_ sender: UIButton) {
        leftOffsetView.isHidden = !leftOffsetView.isHidden
        leftAnalogStickSKView.isHidden = !leftAnalogStickSKView.isHidden
        rightOffsetView.isHidden = !rightOffsetView.isHidden
        rightAnalogStickSKView.isHidden = !rightAnalogStickSKView.isHidden
        updateRightOffsetLabel()
        updateLeftOffsetLabel()
    }

    private func updateLeftOffsetLabel() {
        leftOffsetLabel.text = String(format: STDroneControllerViewController.LEFT_CONTROLLER_FORMAT,
                        mOffsetManager.powerOffset*STDroneControllerViewController.DRONE_COORDINATE_RANGE,
                        mOffsetManager.yawOffset*STDroneControllerViewController.DRONE_COORDINATE_RANGE)
    }

    private func updateRightOffsetLabel() {
        rightOffsetLabel.text = String(format: STDroneControllerViewController.RIGHT_CONTROLLER_FORMAT,
                        mOffsetManager.rollOffset*STDroneControllerViewController.DRONE_COORDINATE_RANGE,
                        mOffsetManager.pitchOffset*STDroneControllerViewController.DRONE_COORDINATE_RANGE)
    }
}


// MARK: - BlueSTSDKFeatureDelegate update the details label with the data coming from the drone
extension STDroneControllerViewController: BlueSTSDKFeatureDelegate {

    private static let ACC_DETAILS_FORMAT: String = {
        let bundle = Bundle(for: BlueSTSDKDemoViewController.self)
        return NSLocalizedString("Acceleration: (x: %.0f y: %.0f z: %.0f) mg", tableName: nil,
                                 bundle: bundle,
                                 value: "Acceleration: (x: %.0f y: %.0f z: %.0f) mg",
                                 comment: "Acceleration: (x: %.0f y: %.0f z: %.0f) mg")
    }()

    private static let GYRO_DETAILS_FORMAT: String = {
        let bundle = Bundle(for: BlueSTSDKDemoViewController.self)
        return NSLocalizedString("Gyroscope: (x: %.2f y: %.2f z: %.2f) mdps", tableName: nil,
                                 bundle: bundle,
                                 value: "Gyroscope: (x: %.2f y: %.2f z: %.2f)  mdps",
                                 comment: "Gyroscope: (x: %.2f y: %.2f z: %.2f)  mdps")
    }()

    private static let BATTERY_FORMAT: String = {
        let bundle = Bundle(for: BlueSTSDKDemoViewController.self)
        return NSLocalizedString("Battery: %3.1f", tableName: nil,
                                 bundle: bundle,
                                 value: "Battery: %3.1f",
                                 comment: "Battery: %3.1f")
    }()

    private static let RSSI_FORMAT: String = {
        let bundle = Bundle(for: BlueSTSDKDemoViewController.self)
        return NSLocalizedString("Rssi: %3d mdb", tableName: nil,
                                 bundle: bundle,
                                 value: "Rssi: %3d mdb",
                                 comment: "Rssi: %3d mdb")
    }()

    private func didAccelerationUpdate(_ sample: BlueSTSDKFeatureSample) {
        let accX = BlueSTSDKFeatureAcceleration.getAccX(sample)
        let accY = BlueSTSDKFeatureAcceleration.getAccY(sample)
        let accZ = BlueSTSDKFeatureAcceleration.getAccZ(sample)

        let accStr = String(format: STDroneControllerViewController.ACC_DETAILS_FORMAT, accX, accY, accZ)

        DispatchQueue.main.async { [weak self] in
            self?.accelerationDetails.text = accStr
        }
    }

    private func didGyroscopeUpdate(_ sample: BlueSTSDKFeatureSample) {
        let gyroX = BlueSTSDKFeatureGyroscope.getGyroX(sample)
        let gyroY = BlueSTSDKFeatureGyroscope.getGyroY(sample)
        let gyroZ = BlueSTSDKFeatureGyroscope.getGyroZ(sample)

        let gyroStr = String(format: STDroneControllerViewController.GYRO_DETAILS_FORMAT, gyroX, gyroY, gyroZ)

        DispatchQueue.main.async { [weak self] in
            self?.gyroscopeDetails.text = gyroStr
        }
    }

    private func didBatteryUpdate(_ sample: BlueSTSDKFeatureSample) {
        let batteryValue = STDroneBatteryFeature.getBatteryValue(sample)
        let batteryStr = String(format: STDroneControllerViewController.BATTERY_FORMAT, batteryValue)
        DispatchQueue.main.async { [weak self] in
            self?.labelBattery.text = batteryStr
        }
    }

    private func didRSSIUpdate(_ sample: BlueSTSDKFeatureSample) {
        let RSSIValue = STDroneRSSIFeature.getRSSIValue(sample)
        let rssiStr = String(format: STDroneControllerViewController.RSSI_FORMAT, RSSIValue)
        DispatchQueue.main.async { [weak self] in
            self?.labelRSSI.text = rssiStr
        }
    }

    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        if feature.isKind(of: BlueSTSDKFeatureAcceleration.self) {
            didAccelerationUpdate(sample)
        } else if feature.isKind(of: BlueSTSDKFeatureGyroscope.self) {
            didGyroscopeUpdate(sample)
        } else if feature.isKind(of: STDroneBatteryFeature.self) {
            didBatteryUpdate(sample)
        } else if feature.isKind(of: STDroneRSSIFeature.self) {
            didRSSIUpdate(sample)
        }
    }

}


/// reset only the x position when the user stop moving the joystick
private struct ResetXPosition: JoystickResetPositionDelegate {
    func resetPositionFrom(current: CGPoint) -> CGPoint {
        return CGPoint(x: 0, y: current.y)
    }
}


/// move the joystick position to the center when the user stop moving it
private struct ResetToCenterPosition: JoystickResetPositionDelegate {
    func resetPositionFrom(current: CGPoint) -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
}


// MARK: - GPoint
fileprivate extension CGPoint {
    
    /// define the difference operator, compute the difference between 2 points compiuting the difference for each component
    ///
    /// - Parameters:
    ///   - left: first point
    ///   - right: second point
    /// - Returns: difference of the points components
    static func - (left: CGPoint, right: CGPoint ) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

}
