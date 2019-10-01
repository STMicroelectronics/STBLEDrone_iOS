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
import BlueSTSDK
import BlueSTSDK_Gui

public class MainViewController: UINavigationController {

    /// register the class that will parse the data from the drone
    private func registerSTDroneCharacteristics() {
        let charMap = [
            UInt32(0x00080000): STDroneBatteryFeature.self,
            UInt32(0x00010000): STDroneRSSIFeature.self,
            UInt32(0x00008000): STDroneJoystickFeature.self
        ]

        //swiftlint:disable force_try
        try! BlueSTSDKManager.sharedInstance.addFeatureForNode(nodeId: 0x80, features: charMap)

    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        registerSTDroneCharacteristics()

        let storyBoard = UIStoryboard(name: "BlueSTSDKMainView", bundle: Bundle(for: BlueSTSDKMainViewController.self))

        if let mainView = storyBoard.instantiateInitialViewController() as? BlueSTSDKMainViewController {
            mainView.delegateMain = nil
            mainView.delegateAbout = self
            mainView.delegateNodeList = self
            pushViewController(mainView, animated: true)
        }
    }

}


// MARK: - BlueSTSDKAboutViewControllerDelegate: configure the about page aspect
extension MainViewController : BlueSTSDKAboutViewControllerDelegate {
    
    public func abaoutHtmlPagePath() -> String? {
        return Bundle.main.path(forResource: "AboutPage", ofType: "html")
    }
    
    public func headImage() -> UIImage? {
        return nil
    }
    
    public func privacyInfoUrl() -> URL? {
        return nil
    }
    
    public func libLicenseInfo() -> [BlueSTSDKLibLicense]? {
        let bundle = Bundle.main
        return [
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "MBProgressHUD", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "BlueSTSDK", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "BlueSTSDK_Gui", ofType: "txt")!)
        ]
    }
}


// MARK: - BlueSTSDKNodeListViewControllerDelegate configure the list node page
extension MainViewController : BlueSTSDKNodeListViewControllerDelegate {
    
    /// display only the nucleo boards
    ///
    /// - Parameter node: node to display
    /// - Returns: true if the node is a nucleo board
    public func display(node: BlueSTSDKNode) -> Bool {
        return node.type == .nucleo
    }
    
    public func prepareToConnect(node: BlueSTSDKNode) {
        
    }
    
    
    /// once the node is connected show the STDroneControllerViewController controller
    ///
    /// - Parameters:
    ///   - node: node selected by the user
    ///   - menuManager: object used to add menu option
    /// - Returns: STDroneControllerViewController constoller to show
    public func demoViewController(with node: BlueSTSDKNode,
                                   menuManager: BlueSTSDKViewControllerMenuDelegate) -> UIViewController {
        let storyBoard = UIStoryboard(name: "STDroneBLE", bundle: nil)
        let demoView = storyBoard.instantiateInitialViewController() as? STDroneControllerViewController
        demoView?.node = node
        demoView?.menuDelegate = menuManager
        return demoView!
    }
}
