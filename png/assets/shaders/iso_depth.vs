#version 330

in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec4 vertexColor;

out vec2 fragTexCoord;
out vec4 fragColor;

uniform mat4 mvp;
uniform float mapHeight;

void main() {
    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;
    
    vec4 position = mvp * vec4(vertexPosition.x, vertexPosition.y, 0.0, 1.0);

    float base_y = vertexPosition.z;

    float height_val = mapHeight;
    if (height_val < 1.0) {
        height_val = 1000.0;
    }
    //float safe_y = clamp(base_y, 0.0, mapHeight);
    float normalized_y = base_y / mapHeight;

    float z_depth = 1.0 - normalized_y;
    position.z = (z_depth * 1.6) - 0.8;

    gl_Position = position;
}