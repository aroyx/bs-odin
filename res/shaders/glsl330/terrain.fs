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
        
        float darkness = clamp((height + 1.5) / 1.5, 0.6, 1.0);
        
        vec3 waterBase = vec3(50.0, 162.0, 230.0) / 255.0;

        finalColor = vec4(waterBase * darkness, 1.0);
    } else {
        finalColor = fragColor;
    }
}
