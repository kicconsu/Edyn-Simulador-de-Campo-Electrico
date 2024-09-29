#[compute]
#version 450

//Work group dimensions
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

//Shader that performs vector camp calculations for the sake of performance.
//This would allow calculating tons of vector lines with little performance impact.

//--------------------------------------------------------- STRUCTS ---------------------------------------------------------

struct Charge{

    int chargeType;
    vec2 pos;
    float rot;

};

//--------------------------------------------------------- BUFFERS ---------------------------------------------------------

//input SSBO for the vector arroy. Image where each pixel stores the position of a vector in the R and G channels
layout(rg32f, binding = 0) restrict readonly uniform image2D vectors;

//output image for the resulting magnitudes and directions
precision highp image2D;
layout(rg32f, binding = 1) writeonly uniform image2D ecamp;

//input SSBO for the charges array
//layout(binding = 2, std430) restrict readonly buffer ChargBuffer{

    //Charge chargeList[];

//}
//charges;

//--------------------------------------------------------- FUNCTIONS ---------------------------------------------------------

//Electric Camp functions

//--------------------------------------------------------- MAIN --------------------------------------------------------------

//Main loop that iterates through the vector array.
//For each vector, calculate total E, add to output SSBO
void main(){
    ivec2 vecIndex = ivec2(gl_GlobalInvocationID.xy);
    vec4 vecCoord = imageLoad(vectors, vecIndex);
    imageStore(ecamp, vecIndex, vec4(vecCoord.y, vecCoord.x, 0, 1));
}