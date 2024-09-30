#[compute]
#version 450

//Work group dimensions
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

//Shader that performs vector camp calculations for the sake of performance.
//This would allow calculating tons of vector lines with little performance impact.

//--------------------------------------------------------- STRUCTS ---------------------------------------------------------

//Charge struct that stores the data of a single charged object
struct Charge{

    vec2 pos;
    float rot;
    float char;
    int type;

};

//--------------------------------------------------------- BUFFERS ---------------------------------------------------------

//input SSBO for the vector arroy. Image where each pixel stores the position of a vector in the R and G channels
layout(rg32f, binding = 0) restrict readonly uniform image2D vectors;

//output image for the resulting magnitudes and directions
precision highp image2D;
layout(rg32f, binding = 1) writeonly uniform image2D ecamp;

//input SSBO for the charges array
layout(binding = 2, std430) restrict readonly buffer ChargBuffer{

    Charge chargeList[];

}
charges;

//--------------------------------------------------------- FUNCTIONS ---------------------------------------------------------

float k = 9*pow(10, 9);

vec2 pointCharge(float charge, vec2 position, vec2 point){
    vec2 p = point - position;
    float r = length(p);

    if (r == 0){
        return vec2(0,0);
    }

    vec2 dir = normalize(p);
    return dir*(k*charge/(r*r));
}

vec2 calculateField(vec2 point){
    vec2 field = vec2(0,0);
    for(int i = 0; i < charges.chargeList.length(); i++){
        Charge body = charges.chargeList[i];
        if(body.type == 0){
            field += pointCharge(body.char, body.pos, point);
        }
    }
    return field;
}

//--------------------------------------------------------- MAIN --------------------------------------------------------------

//Main loop that iterates through the vector array.
//For each vector, calculate total E, add to output SSBO
void main(){
    ivec2 vecIndex = ivec2(gl_GlobalInvocationID.xy);
    vec4 vecCoord = imageLoad(vectors, vecIndex);
    vec2 field = calculateField(vecCoord.xy);
    imageStore(ecamp, vecIndex, vec4(field, 0, 1));
}