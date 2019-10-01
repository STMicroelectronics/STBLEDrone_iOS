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

import STTheme
import Foundation

import SpriteKit



/// Delegate called when the view receive a touch ended event
// disable the lint since this protocol it should be stateless, so the creator should not have a reference of it
//swiftlint:disable class_delegate_protocol
protocol JoystickResetPositionDelegate {
    
    /// build the reset marker position from the last user position, this method is called when the user rise the finger
    ///
    /// - Parameter current: current market position
    /// - Returns: next marker position to
    func resetPositionFrom(current: CGPoint) -> CGPoint
}

class JoystickScene: SKScene {
    
    /// coordinate range used by the normalize coordinate
    public static let COORDINATE_RANGE = CGRect(x: -1, y: -1, width: 2, height: 2)

    private static let BACKGROUND_SQUARE_Z = CGFloat(0.0)
    private static let BACKGROUND_CIRCLE_Z = BACKGROUND_SQUARE_Z + 0.1
    private static let DIRECTION_Z = CGFloat(0.5)
    private static let FOURGROUND_Z = CGFloat(1.0)

    private static func buildBackgroundView(radius: CGFloat) -> SKShapeNode {
        let square = SKShapeNode(rectOf: CGSize(width: 2*radius, height: 2*radius),
                                 cornerRadius: radius/20)
        square.fillColor = ThemeService.shared.currentTheme.color.primary.light
            .withAlphaComponent(0.3)
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = ThemeService.shared.currentTheme.color.secondary.light
        circle.strokeColor = UIColor.clear
        circle.zPosition = BACKGROUND_CIRCLE_Z

        square.addChild(circle)
        square.zPosition = BACKGROUND_SQUARE_Z
        return square
    }

    private static func buildFourgroundCircle(radius: CGFloat) -> SKShapeNode {
        let circle = SKShapeNode(rectOf: CGSize(width: 2*radius, height: 2*radius))
        circle.fillColor = UIColor.white
        circle.strokeColor = UIColor.clear
        circle.zPosition = FOURGROUND_Z
        circle.fillTexture = SKTexture(imageNamed: "joistickInternalTexture")
        return circle
    }

    private static func buildDirectionImage(size: CGSize, texture: SKTexture?) -> SKSpriteNode {
        let node = SKSpriteNode(texture: texture)
        node.scale(to: size)
        node.zPosition = DIRECTION_Z
        return node
    }

    private let fourgroundCircle: SKNode!
    private let backgroundController: SKNode!

    private let topImageNode: SKSpriteNode!
    private let leftImageNode: SKSpriteNode!
    private let bottomImageNode: SKSpriteNode!
    private let rightImageNode: SKSpriteNode!

    //swiftlint:disable weak_delegate
    var resetDelegate: JoystickResetPositionDelegate?

    
    /// return the marker position normalized between -1 and 1
    var normalizedPosition: CGPoint {
        get {
            let scaleW = backgroundController.frame.size.width
            let x =  -(backgroundController.position.x - fourgroundCircle.position.x)*2 / scaleW
            let scaleH = backgroundController.frame.size.height
            let y = -(backgroundController.position.y - fourgroundCircle.position.y)*2 / scaleH
            return CGPoint(x: x, y: y)
        }
        set(newValue) {
            let scaleW = backgroundController.frame.size.width
            let scaleH = backgroundController.frame.size.height
            let x = (2 * backgroundController.position.x - newValue.x * scaleW)/2
            let y = (2 * backgroundController.position.y + newValue.y * scaleH)/2
            return fourgroundCircle.position = CGPoint(x: x, y: y)
        }
    }

    /// build a joystick view
    ///
    /// - Parameters:
    ///   - size: size of the scene that will contain this view
    ///   - topImage: image to use on the top direction
    ///   - bottomImage: image to use on the bottom direction
    ///   - leftImage: image to use on the left direction
    ///   - rightImage: image to use on the rigth direction
    init(size: CGSize, topImage: SKTexture?, bottomImage: SKTexture?, leftImage: SKTexture?, rightImage: SKTexture?) {
        let maxRadious = min(size.width, size.height)/2
        let sceneCenter = CGPoint(x: size.width/2, y: size.height/2)

        // fourgroudRadious = 0.2 * backgroundRadious, backgroundRadious = maxRadious - forugroundRadious
        let fourgroundRadious = (0.2/1.2)*maxRadious
        let backgroundRadious = maxRadious-fourgroundRadious
        let imageSize = CGSize(width: 0.4*backgroundRadious, height: 0.4*backgroundRadious)

        backgroundController = JoystickScene.buildBackgroundView(radius: backgroundRadious)
        fourgroundCircle = JoystickScene.buildFourgroundCircle(radius: fourgroundRadious)

        leftImageNode = JoystickScene.buildDirectionImage(size: imageSize, texture: leftImage)
        leftImageNode.position = CGPoint(x: imageSize.width/2+fourgroundRadious, y: sceneCenter.y)

        rightImageNode = JoystickScene.buildDirectionImage(size: imageSize, texture: rightImage)
        rightImageNode.position = CGPoint(x: sceneCenter.x + backgroundRadious - imageSize.width/2, y: sceneCenter.y)

        topImageNode = JoystickScene.buildDirectionImage(size: imageSize, texture: topImage)
        topImageNode.position = CGPoint(x: sceneCenter.x, y: sceneCenter.y+backgroundRadious-imageSize.height/2)

        bottomImageNode = JoystickScene.buildDirectionImage(size: imageSize, texture: bottomImage)
        bottomImageNode.position = CGPoint(x: sceneCenter.x, y: imageSize.height/2+fourgroundRadious)

        super.init(size: size)

        backgroundController.position = sceneCenter
        fourgroundCircle.position = sceneCenter

        self.addChild(backgroundController)
        self.addChild(fourgroundCircle)

        self.addChild(leftImageNode)
        self.addChild(rightImageNode)
        self.addChild(topImageNode)
        self.addChild(bottomImageNode)
        self.backgroundColor=UIColor.white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Error")
        //super.init(coder: aDecoder)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: UITouch in touches {
            let touchLocation = touch.location(in: self)
            if backgroundController.contains(touchLocation) {
                fourgroundCircle.position = touchLocation
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let reseter = resetDelegate {
            normalizedPosition = reseter.resetPositionFrom(current: normalizedPosition)
        }
    }

}
