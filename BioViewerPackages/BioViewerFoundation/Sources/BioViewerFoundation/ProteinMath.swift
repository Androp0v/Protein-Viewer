//
//  ProteinMath.swift
//  BioViewer
//
//  Created by Raúl Montón Pinillos on 7/5/21.
//

import Foundation
import simd

// MARK: - Model normalization

public func averagePosition(atoms: ContiguousArray<simd_float3>) -> simd_float3 {
    var meanPosition = simd_float3.zero
    atoms.forEach({
        meanPosition += $0
    })
    return meanPosition / Float(atoms.count)
}

public func normalizeAtomPositions(atoms: inout ContiguousArray<simd_float3>, center: simd_float3) {
    for i in 0..<atoms.count {
        atoms[i] -= center
    }
}

// MARK: - Bounding volumes

/// Returns the approximate bounding sphere of a set of points, with an extra margin.
/// - Parameters:
///   - atoms: The positions of the atom centers.
///   - extraMargin: Safety margin to account for the radii of the atoms.
/// - Returns: Position of the center of the bounding sphere and its radius.
public func computeBoundingVolume(atoms: ContiguousArray<simd_float3>, extraMargin: Float = 5) -> BoundingVolume {
    
    guard atoms.count != 1 else {
        let center = atoms.first!
        let boundingBox = BoundingBox(
            minX: center.x - extraMargin,
            maxX: center.x + extraMargin,
            minY: center.y - extraMargin,
            maxY: center.y + extraMargin,
            minZ: center.z - extraMargin,
            maxZ: center.z + extraMargin
        )
        let boundingSphere = BoundingSphere(center: atoms.first!, radius: extraMargin)
        return BoundingVolume(sphere: boundingSphere, box: boundingBox)
    }
    
    let boundingBox = computeBoundingBox(atoms: atoms)
    let center: simd_float3 = simd_float3(
        x: (boundingBox.minX + boundingBox.maxX) / 2,
        y: (boundingBox.minY + boundingBox.maxY) / 2,
        z: (boundingBox.minZ + boundingBox.maxZ) / 2
    )
    
    var maxDistanceToCenter: Float = 0.0
    for atom in atoms {
        let atomDistance = distance(atom, center)
        if atomDistance > maxDistanceToCenter {
            maxDistanceToCenter = atomDistance
        }
    }
    return BoundingVolume(
        sphere: BoundingSphere(center: center, radius: maxDistanceToCenter + extraMargin),
        box: boundingBox
    )
}

public func computeBoundingVolume(proteins: [Protein], extraMargin: Float = 5) -> BoundingVolume {
    var allAtoms = ContiguousArray<simd_float3>()
    for protein in proteins {
        allAtoms.append(contentsOf: protein.atoms)
    }
    return computeBoundingVolume(atoms: allAtoms, extraMargin: extraMargin)
}

public func computeBoundingBox(atoms: ContiguousArray<simd_float3>) -> BoundingBox {
    var minX = Float32.infinity
    var maxX = -Float32.infinity
    var minY = Float32.infinity
    var maxY = -Float32.infinity
    var minZ = Float32.infinity
    var maxZ = -Float32.infinity
    for atom in atoms {
        let x = atom.x
        let y = atom.y
        let z = atom.z
        if x > maxX {
            maxX = x
        }
        if x < minX {
            minX = x
        }
        if y > maxY {
            maxY = y
        }
        if y < minY {
            minY = y
        }
        if z > maxZ {
            maxZ = z
        }
        if z < minZ {
            minZ = z
        }
    }
    return BoundingBox(minX: minX, maxX: maxX, minY: minY, maxY: maxY, minZ: minZ, maxZ: maxZ)
}

/// Uses the Halton sequence generator for random numbers.
///
/// This provides a good convergence rate for TAA, although it doesn't seem completely random.
public func halton(index: UInt32, base: UInt32) -> Float {
    var result: Float = 0.0
    var fractional: Float = 1.0
    var currentIndex: UInt32 = index
    while currentIndex > 0 {
        fractional /= Float(base)
        result += fractional * Float(currentIndex % base)
        currentIndex /= base
    }
    return result
}
