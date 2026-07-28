#version 330
in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform int is_water;

out vec4 finalColor;

void main() {
    if (is_water == 1) {
        float tex_val = texture(texture0, fragTexCoord).r; 
        
        float height = (tex_val * 3.0) - 1.5; 
        
        float blend = smoothstep(-1.0, -0.3, height);
        
        vec3 water = vec3(50.0, 162.0, 230.0) / 255.0;
        vec3 waterDark = vec3(34, 115, 163) / 255.0;

        finalColor = vec4(mix(waterDark, water, blend), 1.0);
    } else {
        finalColor = fragColor;
    }
}
