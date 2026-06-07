//
//  GameScene.swift
//  Jimothy
//
//  Created by Clifton Baggerman on 07/06/2026.
//

import SpriteKit

/// The RPG game scene: a grid world with Jimothy, who walks smoothly under
/// D-pad control, looping his walk cycle in the faced direction while a button
/// is held and standing idle when released.
///
/// Art: composed from Liberated Pixel Cup (LPC) modular layers — CC-BY-SA / GPL.
final class GameScene: SKScene {
    enum Direction {
        case up
        case down
        case left
        case right
    }

    private let walkSpeed: CGFloat = 200
    private let hero = SKSpriteNode()
    private let backdrop = SKSpriteNode(imageNamed: "village")

    private var moveDirection: Direction?
    private var facing: Direction = .down
    private var lastUpdate: TimeInterval = 0
    private var hasLaidOutScene = false

    private var walkFrames: [Direction: [SKTexture]] = [:]
    private var idleFrame: [Direction: SKTexture] = [:]

    private let walkKey = "walk"

    // Collision in normalized backdrop space (x: 0→1 left→right, y: 0→1 top→bottom).
    private let walkableArea = CGRect(x: 0.05, y: 0.30, width: 0.90, height: 0.62)
    private let blockedAreas: [CGRect] = [
        CGRect(x: 0.12, y: 0.32, width: 0.32, height: 0.20), // left house
        CGRect(x: 0.55, y: 0.36, width: 0.31, height: 0.24), // right house
        CGRect(x: 0.34, y: 0.66, width: 0.32, height: 0.26)  // pond
    ]

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.09, green: 0.13, blue: 0.10, alpha: 1)
        loadTextures()

        backdrop.texture?.filteringMode = .nearest
        backdrop.zPosition = 0
        addChild(backdrop)

        hero.texture = idleFrame[.down]
        hero.size = CGSize(width: 64, height: 64)
        hero.setScale(1.0)
        hero.zPosition = 10
        addChild(hero)
    }

    /// Begins continuous movement in `direction`, looping the walk cycle.
    func startMoving(_ direction: Direction) {
        guard moveDirection != direction else { return }
        moveDirection = direction
        facing = direction

        let frames = walkFrames[direction] ?? []
        hero.removeAction(forKey: walkKey)
        let cycle = SKAction.animate(with: frames, timePerFrame: 0.07)
        hero.run(SKAction.repeatForever(cycle), withKey: walkKey)
    }

    /// Stops movement and returns to the idle frame for the current facing.
    func stopMoving() {
        moveDirection = nil
        hero.removeAction(forKey: walkKey)
        hero.texture = idleFrame[facing]
    }

    override func update(_ currentTime: TimeInterval) {
        layOutBackdrop()
        if !hasLaidOutScene {
            hero.position = CGPoint(x: size.width / 2, y: size.height / 2)
            hasLaidOutScene = true
        }

        defer { lastUpdate = currentTime }
        guard let direction = moveDirection, lastUpdate != 0 else { return }

        let distance = walkSpeed * CGFloat(currentTime - lastUpdate)
        var deltaX: CGFloat = 0
        var deltaY: CGFloat = 0
        switch direction {
        case .up: deltaY = distance
        case .down: deltaY = -distance
        case .left: deltaX = -distance
        case .right: deltaX = distance
        }

        // Move per-axis so the hero slides along obstacles instead of sticking.
        var position = hero.position
        let tryX = CGPoint(x: position.x + deltaX, y: position.y)
        if isWalkable(feet(of: tryX)) { position.x = tryX.x }
        let tryY = CGPoint(x: position.x, y: position.y + deltaY)
        if isWalkable(feet(of: tryY)) { position.y = tryY.y }
        hero.position = position
    }

    /// The hero's standing point — roughly his feet, used for collision.
    private func feet(of position: CGPoint) -> CGPoint {
        CGPoint(x: position.x, y: position.y - 26 * hero.yScale)
    }

    /// Whether a scene point falls on walkable ground (inside the platform and
    /// clear of obstacles), tested in normalized backdrop space.
    private func isWalkable(_ point: CGPoint) -> Bool {
        let scaledWidth = backdrop.size.width * backdrop.xScale
        let scaledHeight = backdrop.size.height * backdrop.yScale
        guard scaledWidth > 0, scaledHeight > 0 else { return true }

        let originX = backdrop.position.x - scaledWidth / 2
        let originY = backdrop.position.y - scaledHeight / 2
        let normalized = CGPoint(
            x: (point.x - originX) / scaledWidth,
            y: 1 - (point.y - originY) / scaledHeight
        )

        guard walkableArea.contains(normalized) else { return false }
        return !blockedAreas.contains { $0.contains(normalized) }
    }

    // MARK: - Textures

    /// Slices the 9x4 walk sheet (64px cells) into per-direction frames.
    private func loadTextures() {
        let sheet = SKTexture(imageNamed: "jimothy_walk")
        sheet.filteringMode = .nearest

        let directions: [(Direction, Int)] = [(.up, 0), (.left, 1), (.down, 2), (.right, 3)]
        for (direction, row) in directions {
            walkFrames[direction] = makeFrames(in: sheet, row: row, columns: Array(1..<9))
            idleFrame[direction] = makeFrames(in: sheet, row: row, columns: [0]).first
        }
    }

    private func makeFrames(in sheet: SKTexture, row: Int, columns: [Int]) -> [SKTexture] {
        let cellWidth: CGFloat = 1.0 / 9.0
        let cellHeight: CGFloat = 1.0 / 4.0
        return columns.map { column in
            // SpriteKit texture coordinates originate bottom-left; sheet rows are top-down.
            let rect = CGRect(
                x: CGFloat(column) * cellWidth,
                y: CGFloat(3 - row) * cellHeight,
                width: cellWidth,
                height: cellHeight
            )
            let texture = SKTexture(rect: rect, in: sheet)
            texture.filteringMode = .nearest
            return texture
        }
    }

    /// Scales the backdrop to cover the view, centred. Cheap; run each frame so
    /// it stays filled as SpriteView resolves its size.
    private func layOutBackdrop() {
        let textureSize = backdrop.texture?.size() ?? backdrop.size
        guard textureSize.width > 0, textureSize.height > 0 else { return }
        let fillScale = max(size.width / textureSize.width, size.height / textureSize.height)
        backdrop.setScale(fillScale)
        backdrop.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
}
