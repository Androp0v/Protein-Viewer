//
//  ConfigurationSelector.swift
//  BioViewer
//
//  Created by Raúl Montón Pinillos on 17/12/21.
//

import Foundation

struct BufferRegion {
    let length: Int
    let offset: Int
}

class ConfigurationSelector {
    weak var scene: MetalScene?
    
    var atomsPerConfiguration: Int
    
    var subunitIndices: [Int]
    var subunitLengths: [Int]
    
    var bondsPerConfiguration: [Int]?
    var bondArrayStarts: [Int]?
    
    var currentConfiguration: Int = 0
    var lastConfiguration: Int
    
    // MARK: - Initialization
    
    init(scene: MetalScene, atomsPerConfiguration: Int, subunitIndices: [Int], subunitLengths: [Int], configurationCount: Int) {
        self.scene = scene
        self.atomsPerConfiguration = atomsPerConfiguration
        self.subunitIndices = subunitIndices
        self.subunitLengths = subunitLengths
        self.lastConfiguration = configurationCount - 1
    }
    
    func addBonds(bondsPerConfiguration: [Int], bondArrayStarts: [Int]) {
        self.bondsPerConfiguration = bondsPerConfiguration
        self.bondArrayStarts = bondArrayStarts
    }
    
    // MARK: - Change configuration
    
    func previousConfiguration() {
        currentConfiguration -= 1
        if currentConfiguration <= -1 {
            currentConfiguration = lastConfiguration
        }
        scene?.needsRedraw = true
    }
    
    func nextConfiguration() {
        currentConfiguration += 1
        if currentConfiguration >= lastConfiguration {
            currentConfiguration = 0
        }
        scene?.needsRedraw = true
    }
    
    // MARK: - Get buffer regions
    
    func getImpostorVertexBufferRegion() -> BufferRegion {
        return BufferRegion(length: atomsPerConfiguration * 4,
                            offset: atomsPerConfiguration * 4 * currentConfiguration)
    }
    
    func getSubunitSplitImpostorVertexBufferRegions() -> [BufferRegion] {
        var bufferRegions = [BufferRegion]()
        for (subunitIndex, subunitLength) in zip(subunitIndices, subunitLengths) {
            bufferRegions.append(BufferRegion(length: subunitLength * 4,
                                              offset: subunitIndex * 4 + atomsPerConfiguration * 4 * currentConfiguration))
        }
        return bufferRegions
    }
    
    func getImpostorIndexBufferRegion() -> BufferRegion {
        return BufferRegion(length: atomsPerConfiguration * 2 * 3,
                            offset: atomsPerConfiguration * 2 * 3 * currentConfiguration)
    }
    
    func getSubunitSplitImpostorIndexBufferRegions() -> [BufferRegion] {
        var bufferRegions = [BufferRegion]()
        for (subunitIndex, subunitLength) in zip(subunitIndices, subunitLengths) {
            bufferRegions.append(BufferRegion(length: subunitLength * 2 * 3,
                                              offset: subunitIndex * 2 * 3 + atomsPerConfiguration * 2 * 3 * currentConfiguration))
        }
        return bufferRegions
    }
    
    func getBondsIndexBufferRegion() -> BufferRegion? {
        guard let bondsPerConfiguration = bondsPerConfiguration else { return nil }
        guard let bondArrayStarts = bondArrayStarts else { return nil }
        return BufferRegion(length: bondsPerConfiguration[currentConfiguration] * 8 * 3,
                            offset: bondArrayStarts[currentConfiguration] * 8 * 3)
    }
}
