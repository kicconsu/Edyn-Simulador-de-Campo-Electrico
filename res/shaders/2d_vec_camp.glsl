#[compute]
#version 450

//Work group dimensions
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

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

//input SSBO for the charges array
layout(binding = 1, std430) restrict readonly buffer ChargBuffer{

    Charge chargeList[];

}
charges;

//output SSBO for the resulting magnitudes and directions
layout(rg32f, binding = 2) restrict writeonly uniform image2D ecamp;

//--------------------------------------------------------- FUNCTIONS ---------------------------------------------------------

//Electric Camp functions

//--------------------------------------------------------- MAIN --------------------------------------------------------------

//Main loop that iterates through the vector array.
//For each vector, calculate total E, add to output SSBO
void main(){
    
}