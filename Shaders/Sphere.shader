shader_type spatial;

uniform sampler2D grid_tex : hint_albedo;
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

void fragment() {
	//pos1 
	float dist0 = clamp(pow(distance(world_pos, pos0) / transition_distance, transition_falloff),0,1);
	float dist1 = clamp(pow(distance(world_pos, pos1) / transition_distance, transition_falloff),0,1);
	float dist2 = clamp(pow(distance(world_pos, pos2) / transition_distance, transition_falloff),0,1);
	float dist3 = clamp(pow(distance(world_pos, pos3) / transition_distance, transition_falloff),0,1);		
	
	//vec4 tex = texture(grid_tex, vec2(mod(UV.x * 100.0, 1), mod(UV.y * 100.0, 1)));
	
	//ALBEDO = tex.rgb;
	//ALPHA = tex.r * (1.0-(dist0 * dist1 * dist2 * dist3)) * 0.025;
	//EMISSION = tex.rgb * (1.0 - (dist0 * dist1 * dist2 * dist3)) * vec3(1,1,1);
}