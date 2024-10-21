#[compute]
#version 450

//Work group dimensions
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

//Charge struct that stores the data of a single charged object
struct Charge{

    vec3 pos; // 12 bytes + 4 padding = 16 bytes at 0
    vec4 direc; // 16 bytes + 0 at 16
    float char; //4 bytes + 0 at 32
    int type; //4 bytes + 0 at 36
    //Size: 40, add 4*2 padding at the end

    /*

    chargedSphere:
    char = charge Q
    direc[0] = radius R
    direc[1] = space filler (0)
    direc[2] = space filler (0)
    direc[3] = space filler (0)

    infiniteLine:
    char: lambda
    direc[0] = x component of the axis's direction
    direc[1] = y component of the axis's direction
    direc[2] = z component of the axis's direction
    direc[3] = space filler (0)

    infiniteCilinder:
    char: rho
    direc[0] = x component of the axis's direction
    direc[1] = y component of the axis's direction
    direc[2] = z component of the axis's direction
    direc[3] = radius R

    infinitePlane:
    char: sigma
    direc[0] = x component of the plane's normal vector
    direc[1] = y component of the plane's normal vector
    direc[2] = z component of the plane's normal vector
    direc[3] = space filler (0)
    */
};

//--------------------------------------------------------- BUFFERS ---------------------------------------------------------

//input SSBO for the vector arroy. Image where each pixel stores the position of a vector in the R and G channels
layout(rgba32f, binding = 0) restrict readonly uniform image2D vectors;

//output image for the resulting magnitudes and directions
precision highp image2D;
layout(rgba32f, binding = 1) writeonly uniform image2D ecamp;

//input SSBO for the charges array
layout(binding = 2, std430) restrict readonly buffer ChargBuffer{

    Charge chargeList[];

}
charges;

//--------------------------------------------------------- FUNCIONE' ---------------------------------------------------------

const float k = 9*pow(10, 9);
const float e_0 = 8.85*pow(10, -12);

vec3 pointCharge(float charge, vec3 ri, vec3 p){
    vec3 r = p - ri;
    float dist = length(r);

    //dist = dist*pow(10, 2);

    if (dist == 0){
        return vec3(0,0,0);
    }

    vec3 dir = normalize(r);
    float mag = (k*charge/(dist*dist));
    return dir*(mag);
}

vec3 infinitePlane(float sigma, vec3 n, vec3 ri, vec3 p){
    vec3 r = p - ri;
    float d = dot(r, n);

    // Cercanía a 0 para evitar problemas de precisión
    if(abs(d) < 1e-6){
        return vec3(0,0,0);
    }

    float field = sigma/(2.0*e_0);

    //Dirección del campo
    if(d > 0){
        return field*n;
    } else {
        return -field*n;
    }
}

vec3 infiniteCilinder(float rho, float R, vec3 ri, vec3 d, vec3 p){
    vec3 v = p - ri;

    vec3 proj =dot(v, d)*d;

    //Distancia radial
    vec3 dist = v - proj;
    vec3 dir = normalize(dist);
    float r = length(dist);

    if(r < R){
        return (rho*r)/(2.0*e_0) * dir;
    }

    return (rho*R*R)/(2.0*e_0*r) * dir;
}

vec3 infiniteLine(float lambda, vec3 ri, vec3 d, vec3 p){

    vec3 v = p - ri;

    vec3 proj = (dot(v, d)*d);

    //Distancia radial
    vec3 dist = v - proj;
    float r = length(dist);

    float field = 2*k*lambda/r;//Valor del campo a partir de la ley de Gauss
    return field*normalize(dist);
}

vec3 chargedSphere(float Q, float R, vec3 ri, vec3 p) {

    vec3 r = p - ri;
    float dist = length(r);

    // Dentro de la esfera
    if (dist < R) {
        return k*Q*dist/(R*R*R)*normalize(r);
    }

    // Fuera de la esfera, se resuelve para cargas puntuales
    return pointCharge(Q, ri, p);
    
}

vec3 calculateField(vec3 point){
    vec3 field = vec3(0, 0, 0);
    for(int i = 0; i < charges.chargeList.length(); i++){
        Charge body = charges.chargeList[i];
        body.char /= pow(10, 10);
        if(body.type == 0){

            //pointCharge(float charge, vec3 ri, vec3 p)
            field += pointCharge(body.char, body.pos, point);

        } else if (body.type == 1){

            //chargedSphere(float Q, float R, vec3 ri, vec3 p)
            field += chargedSphere(body.char, body.direc[3], body.pos, point);

        } else if (body.type == 2){

            //infiniteLine(float lambda, vec3 ri, vec3 d, vec3 p)
            field += infiniteLine(body.char, body.pos, vec3(body.direc[0], body.direc[1], body.direc[2]), point);

        } else if (body.type == 3){

            // infiniteCilinder(float rho, float R, vec3 ri, vec3 d, vec3 p)
            field += infiniteCilinder(body.char, body.direc[3], body.pos, vec3(body.direc[0], body.direc[1], body.direc[2]), point);

        } else if (body.type == 4){

            //infinitePlane(float sigma, vec3 n, vec3 ri, vec3 p)
            field += infinitePlane(body.char, vec3(body.direc[0], body.direc[1], body.direc[2]), body.pos, point);
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
    vec3 field = calculateField(vecCoord.xyz);
    Charge charg = charges.chargeList[0];
    imageStore(ecamp, vecIndex, vec4(field,1));
}