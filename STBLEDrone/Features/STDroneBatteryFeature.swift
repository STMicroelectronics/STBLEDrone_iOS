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


/// Feature that contains the current drone battery level
public class STDroneBatteryFeature: BlueSTSDKFeature {
    private static let FEATURE_NAME = "Battery"
    private static let FIELDS: [BlueSTSDKFeatureField] = [
        BlueSTSDKFeatureField(name: FEATURE_NAME,
                              unit: "%",
                              type: .float,
                              min: NSNumber(value: Float(0.0)),
                              max: NSNumber(value: Float(100.0)))
    ]

    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: STDroneBatteryFeature.FEATURE_NAME)
    }

    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return STDroneBatteryFeature.FIELDS
    }

    public override func extractData(_ timestamp: UInt64, data: Data, dataOffset offset: UInt32)
        -> BlueSTSDKExtractResult {

        if data.count - Int(offset) < 2 {
            NSException(name: NSExceptionName(rawValue: "Invalid Battery Data"),
                        reason: "No Bytes",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }

        let batteryValue = Float((data as NSData).extractLeInt16(fromOffset: UInt(offset)))/10.0
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp, data: [NSNumber(value: batteryValue)])
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 2)
    }

    public static func getBatteryValue(_ sample: BlueSTSDKFeatureSample) -> Float {
        guard sample.data.count > 0 else {
            return Float.nan
        }
        return sample.data[0].floatValue
    }
}
