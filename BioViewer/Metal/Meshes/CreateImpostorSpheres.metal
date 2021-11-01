//
//  CreateImpostorSpheres.metal
//  BioViewer
//
//  Created by Raúl Montón Pinillos on 21/10/21.
//

#include <metal_stdlib>
#include "AtomProperties.h"
#include "GeneratedVertex.h"

using namespace metal;

kernel void createImpostorSpheres(const device simd_float3 *atomPoints [[ buffer(0) ]],
                                  const device uint8_t *atomType [[ buffer(1) ]],
                                  device BillboardVertex *generatedVertices [[ buffer(2) ]],
                                  device uint32_t *generatedIndices [[ buffer(3) ]],
                                  uint i [[ thread_position_in_grid ]],
                                  uint l [[ thread_position_in_threadgroup ]]) {
    // TO-DO
    
    // Retrieve the radius and position of the atom
    const simd_float3 position = atomPoints[i];
    const uint32_t index = i * 4;
    const uint32_t index_2 = i * 6;
    // TO-DO: Deprecate AtomProperties, single source of truth with FrameData
    const float radius = atomRadius[atomType[i]];
    
    // MARK: - Vertices

    generatedVertices[index+0].position = simd_float3(radius, radius, 0.0) + position;
    generatedVertices[index+1].position = simd_float3(-radius, radius, 0.0) + position;
    generatedVertices[index+2].position = simd_float3(-radius, -radius, 0.0) + position;
    generatedVertices[index+3].position = simd_float3(radius, -radius, 0.0) + position;
    
    generatedVertices[index+0].billboardMapping = simd_float2(1, 1);
    generatedVertices[index+1].billboardMapping = simd_float2(-1, 1);
    generatedVertices[index+2].billboardMapping = simd_float2(-1, -1);
    generatedVertices[index+3].billboardMapping = simd_float2(1, -1);
    
    generatedVertices[index+0].atomCenter = position;
    generatedVertices[index+1].atomCenter = position;
    generatedVertices[index+2].atomCenter = position;
    generatedVertices[index+3].atomCenter = position;
    
    // MARK: - Indices

    generatedIndices[index_2+0] = 0 + index;
    generatedIndices[index_2+1] = 2 + index;
    generatedIndices[index_2+2] = 1 + index;
    
    generatedIndices[index_2+3] = 2 + index;
    generatedIndices[index_2+4] = 0 + index;
    generatedIndices[index_2+5] = 3 + index;
}
