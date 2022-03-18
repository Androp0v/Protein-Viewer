//
//  ComputeSDFGrid.swift
//  BioViewer
//
//  Created by Raúl Montón Pinillos on 18/3/22.
//

import Foundation
import Metal

extension MetalScheduler {
    
    public func computeSDFGrid(protein: Protein, boxSize: Float, gridResolution: Int) -> MTLBuffer? {
        
        let numberOfGridPoints: Int = gridResolution * gridResolution * gridResolution
        
        // Populate buffers
        let generatedSDFBuffer = device.makeBuffer(
            length: numberOfGridPoints * MemoryLayout<Float32>.stride
        )
        
        metalDispatchQueue.sync {
                        
            // Populate buffers
            let atomPositionsBuffer = device.makeBuffer(
                bytes: Array(protein.atoms),
                length: protein.atomCount * protein.configurationCount * MemoryLayout<simd_float3>.stride
            )
            let atomTypeBuffer = device.makeBuffer(
                bytes: Array(protein.atomIdentifiers),
                length: protein.atomCount * protein.configurationCount * MemoryLayout<UInt8>.stride
            )

            // Make Metal command buffer
            guard let buffer = queue?.makeCommandBuffer() else { return }

            // Set Metal compute encoder
            guard let computeEncoder = buffer.makeComputeCommandEncoder() else { return }

            // Check if the function needs to be compiled
            if createBondsBundle.requiresBuilding(newFunctionParameters: nil) {
                createBondsBundle.createPipelineState(functionName: "compute_SDF_Grid",
                                                      library: self.library,
                                                      device: self.device,
                                                      constantValues: nil)
            }
            guard let pipelineState = createBondsBundle.getPipelineState(functionParameters: nil) else {
                return
            }

            // Set compute pipeline state for current arguments
            computeEncoder.setComputePipelineState(pipelineState)

            // Set buffer contents
            computeEncoder.setBuffer(atomPositionsBuffer,
                                     offset: 0,
                                     index: 0)
            computeEncoder.setBuffer(atomTypeBuffer,
                                     offset: 0,
                                     index: 1)
            computeEncoder.setBuffer(generatedSDFBuffer,
                                     offset: 0,
                                     index: 2)
                        
            // Schedule the threads
            if device.supportsFamily(.apple3) {
                // Create threads and threadgroup sizes
                let threadsPerArray = MTLSizeMake(numberOfGridPoints, 1, 1)
                let groupSize = MTLSizeMake(pipelineState.maxTotalThreadsPerThreadgroup, 1, 1)
                
                // Avoid crashes dispatching too big of a size
                guard threadsPerArray.width <= UInt32.max else {
                    computeEncoder.endEncoding()
                    return
                }
                
                // Dispatch threads
                computeEncoder.dispatchThreads(threadsPerArray, threadsPerThreadgroup: groupSize)
            } else {
                // LEGACY: Older devices do not support non-uniform threadgroup sizes
                let groupSize = MTLSizeMake(pipelineState.maxTotalThreadsPerThreadgroup, 1, 1)
                let threadGroupsPerGrid = MTLSizeMake(Int(floorf(Float(numberOfGridPoints)
                                                                / Float(pipelineState.maxTotalThreadsPerThreadgroup))), 1, 1)
                // Dispatch threadgroups
                computeEncoder.dispatchThreadgroups(threadGroupsPerGrid, threadsPerThreadgroup: groupSize)
            }

            // REQUIRED: End the compute encoder encoding
            computeEncoder.endEncoding()

            // Commit the buffer contents
            buffer.commit()

            // Wait until the computation is finished!
            buffer.waitUntilCompleted()
        }
        return generatedSDFBuffer
    }
}
