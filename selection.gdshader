shader_type spatial;

uniform vec2 corner1 = vec2(0, 0);
uniform vec2 corner2 = vec2(0.1, 0.1);
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform float green = 0.5;

void vertex() {
    vec2 size = corner2 - corner1;
    vec2 position = (corner1 + corner2) / 2.0;

    // Transform only the x and z coordinates of the vertex position
    VERTEX.xz *= size;
    VERTEX.xz += position;
}

void fragment() {
    ALBEDO = vec3(0.009, 0.118, 0.263); 
	ALPHA = 0.7;
}