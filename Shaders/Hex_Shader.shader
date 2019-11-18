shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled;

uniform vec4 base_color:hint_color;
uniform vec2 near_far=vec2(0.1,100.0);
uniform sampler2D hex_tex:hint_black;
uniform float hexes_scale:hint_range(1,100);

// Swiggies Edit
uniform vec3 pos0 = vec3(10,0,10);
uniform vec3 pos1 = vec3(10,0,10);
uniform vec3 pos2 = vec3(10,0,10);
uniform vec3 pos3 = vec3(10,0,10);
uniform float transition_distance : hint_range(0,100);
uniform float transition_falloff : hint_range(0,100);

varying vec3 world_pos;

void vertex() {
	world_pos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float linearize(float val) {
    val = 2.0 * val - 1.0;
    val = 2.0 * near_far[0] * near_far[1] / (near_far[1] + near_far[0] - val * (near_far[1] - near_far[0]));
    return val;
}

float tri_wave(float t, float offset, float y_offset) {
    return clamp(abs(fract(offset + t) * 2.0 - 1.0) + y_offset, 0, 1);
}

void fragment() {
    float zdepth = linearize(texture(DEPTH_TEXTURE, SCREEN_UV).r);
    float zpos = linearize(FRAGCOORD.z);
    float diff = zdepth - zpos;
    float intersect = 0.0;
    if (diff > 0.0) {
        intersect = 1.0 - smoothstep(0.0, (1.0/near_far[1])*10.0, diff);
    }

    float t = tri_wave(TIME * 0.5, FRAGCOORD.x/FRAGCOORD.w , -0.75) * 4.0;
    
    float pole = (1.0 - UV.y-0.3) * 1.5;
    float rim = clamp(1.0 - abs(dot(NORMAL, VERTEX)*0.75), 0.0, 1.0);
    float glow = clamp(max(max(intersect, rim), pole), 0.0, 1.0);

    vec3 hexes = texture(hex_tex, UV*hexes_scale).rgb;
    hexes.r *= t;
    hexes.g *= clamp(rim, 0, 1) * (sin((TIME*2.0) + hexes.b * 4.0)+1.0);
    
	// Swiggies Edit
	float dist0 = clamp(pow(distance(world_pos, pos0) / transition_distance, transition_falloff),0,1);
	float dist1 = clamp(pow(distance(world_pos, pos1) / transition_distance, transition_falloff),0,1);
	float dist2 = clamp(pow(distance(world_pos, pos2) / transition_distance, transition_falloff),0,1);
	float dist3 = clamp(pow(distance(world_pos, pos3) / transition_distance, transition_falloff),0,1);	
	float final_dist = (1.0-(dist0 * dist1 * dist2 * dist3));
	
    hexes = (hexes.r + hexes.g) * base_color.rgb * 2.0 ;
    vec3 glow_color = smoothstep(base_color.rgb, vec3(1), vec3(pow(glow, 8)));
    vec3 final_color = (base_color.rgb) + (glow_color.rgb * glow) + hexes*4.0;
    
    // Akhil's Edit
    vec3 view_distort = (final_color + VIEW)/2.0;
	
    ALBEDO = final_color * view_distort;
	EMISSION = (vec3(1.0,1.0,1.0) * 10.0) * final_dist * final_color;
    ALPHA = base_color.a;
}