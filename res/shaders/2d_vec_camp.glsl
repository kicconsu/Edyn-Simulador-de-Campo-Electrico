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
    vec4 info; 
    /*

    chargedLine:
    char: lambda
    info[0] = length
    info[1] = rotation angle (radians)
    info[2] = no. segments
    info[3] = space filler (0)

    chargedDisk OR chargedRing:
    char: sigma
    info[0] = minor radius (if not a ring, 0)
    info[1] = radius
    info[2] = no. radial segments
    info[3] = no. angular segments

    chargedRectangle:
    char: sigma
    info[0]: horizontal length (a)
    info[1]: vertical length (b)
    info[2]: no. segments
    info[3]: rotation angle (radians)
    */
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

const float k = 9*pow(10, 9);

vec2 chargedRectangle(float sigma, float a, float b, int n_segments, float theta, vec2 ri, vec2 P) {

    // Dimensiones de los segmentos
    float du = a / float(n_segments);
    float dv = b / float(n_segments);

    vec2 field = vec2(0.0, 0.0);

    //Iterar sobre los segmentos
    for (int i = 0; i < n_segments; i++) {
        for (int j = 0; j < n_segments; j++) {
            // Coordenadas locales del centro del segmento
            float u = -a / 2.0 + (i + 0.5) * du;
            float v = -b / 2.0 + (j + 0.5) * dv;

            // Conversión a coordenadas globales
            vec2 p = ri + vec2(
                u * cos(theta) - v * sin(theta),
                u * sin(theta) + v * cos(theta)
            );

            // Vector distancia
            vec2 r_dist = P - p;
            float r = length(r_dist);

            if (r > 0.0) {
                vec2 dir = normalize(r_dist);
                float dE = k * sigma * du * dv / (r * r);
                field += dE * dir;
            }
        }
    }

    return field;
}

vec2 chargedRing(float sigma, float r, float R, int n_radial, 
                        int n_angular, vec2 position, vec2 p) {
    vec2 field = vec2(0.0);

    // Discretizar drho y dtheta
    float drho = (R - r) / float(n_radial);
    float dtheta = 2.0 * 3.14159265 / float(n_angular);

    for (int i = 0; i < n_radial; ++i) {
        // Posicion del radio en cada anillo (+0.5 para evaluar 
        //en el medio del intervalo)
        float rho = r + drho * (float(i) + 0.5); 
        for (int j = 0; j < n_angular; ++j) {
            float theta = dtheta * j;

            // Posicion del diferencial de area en coordenadas cartesianas
            vec2 pos = position + vec2(rho * cos(theta), rho * sin(theta));

            // Vector desde el elemento de carga hasta el punto P
            vec2 dist = p - pos;
            float r_squared = dot(dist, dist);
            
            if (r_squared > 0.0) {
                vec2 dir = normalize(dist);
                float dE = k * sigma * rho * drho * dtheta / r_squared;
                field += dE * dir;
            }
        }
    }

    return field;
}

vec2 chargedDisk(float sigma, float radius, int n_radial, int n_angular, vec2 position, vec2 p) {
    vec2 field = vec2(0.0);

    // Discretizar dr y dtheta
    float dr = radius / float(n_radial);
    float dtheta = 2.0 * 3.14159265 / float(n_angular);

    for (int i = 0; i < n_radial; ++i) {
        // Posición del radio en cada anillo (+0.5 para evaluar en el medio del intervalo)
        float r = dr * (float(i) + 0.5); 
        for (int j = 0; j < n_angular; ++j) {
            float theta = dtheta * j;

            // Posición del diferencial de área en coordenadas cartesianas
            vec2 pos = position + vec2(r * cos(theta), r * sin(theta));

            // Vector desde el elemento de carga hasta el punto P
            vec2 dist = p - pos;
            float dist_squared = dot(dist, dist);
            
            if (dist_squared > 0.0) {
                vec2 dir = normalize(dist);
                float dE = k * sigma * r * dr * dtheta / dist_squared;
                field += dE * dir;
            }
        }
    }

    return field;
}

vec2 chargedLine(float lambda, float L, int n_segments, float theta, vec2 position, vec2 p){

    //Borde inicial de la varilla: posición del centro menos las proyecciones de L/2 en cada eje
    vec2 ri = position - 0.5*L*vec2(cos(theta), sin(theta));

    int lim = n_segments/2;
    vec2 field = vec2(0,0); 
    for(int i = -lim; i <= lim; i++){

        //Posición del segmento
        float l = (float(i) / float(n_segments)) * L;
        //Adaptada a coordenadas cartesianas:
        vec2 l_vec = ri + l*vec2(cos(theta), sin(theta));
   
        vec2 dist = p - l_vec;

        float r =  length(dist);
        
        if (r > 0){
            vec2 dir = normalize(dist);
            float dE = k*lambda/(r*r);
            field += dE*dir;
        }
    }

    return field;
}

vec2 pointCharge(float charge, vec2 position, vec2 point){
    vec2 p = point - position;
    float r = length(p);

    if (r == 0){
        return vec2(0,0);
    }

    vec2 dir = normalize(p);
    float mag = (k*charge/(r*r));
    return dir*(mag);
}

vec2 calculateField(vec2 point){
    vec2 field = vec2(0,0);
    for(int i = 0; i < charges.chargeList.length(); i++){
        Charge body = charges.chargeList[i];
        if(body.type == 0){

            //pointCharge(float charge, vec2 position, vec2 point)
            field += pointCharge(body.char, body.pos, point);

        } else if (body.type == 1){

            //chargedLine(float lambda, float L, int n_segments, float theta, vec2 position, vec2 p)
            field += chargedLine(body.char, body.info[0], int(body.info[2]), body.info[1], body.pos, point);

        } else if (body.type == 2){

            //chargedDisk(float sigma, float radius, int n_radial, int n_angular, vec2 position, vec2 p)
            field += chargedDisk(body.char, body.info[1], int(body.info[2]), int(body.info[3]), body.pos, point);

        } else if(body.type == 3){

            //chargedRing(float sigma, float r, float R, int n_radial, int n_angular, vec2 position, vec2 p)
            chargedRing(body.char, body.info[0], body.info[1], int(body.info[2]), int(body.info[3]), body.pos, point);

        } else if (body.type == 4){

            // chargedRectangle(float sigma, float a, float b, int n_segments, float theta, vec2 ri, vec2 P)
            field += chargedRectangle(body.char, body.info[0], body.info[1], int(body.info[2]), body.info[3], body.pos, point);
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