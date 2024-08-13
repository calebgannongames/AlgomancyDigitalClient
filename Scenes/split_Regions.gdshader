shader_type spatial;
//render_mode unshaded;
// Textures for the two regions
uniform sampler2D player_texture;
uniform sampler2D opponent_texture;


#define SIZE 30.

#define col1 vec3(150.,30.,0.)/255.
#define col2 vec3(219.,73.,0.)/255.

#define col3 vec3(140.,60.,140.)/255.
#define col4 vec3(40.,0.,54.)/255.
// The position of the divider in normalized coordinates (0.0 to 1.0)
//uniform float divider_position; 
uniform vec2 divider_position; // Center position of the line (in UV coordinates)
uniform vec2 divider_direction; // Angle in degrees

vec2 ran(vec2 uv) {
    uv *= vec2(dot(uv,vec2(127.1,311.7)),dot(uv,vec2(227.1,521.7)) );
    return 1.0-fract(tan(cos(uv)*123.6)*3533.3)*fract(tan(cos(uv)*123.6)*3533.3);
}
vec2 pt(vec2 id) {
    return sin(0.2*TIME*(ran(id+.5)-0.5)+ran(id-20.1)*8.0)*0.5;
}

void fragment() {
    vec2 uv = UV;
    vec2 p = uv - divider_position;
	
    if (dot(p, divider_direction) > 0.0) {
        // Normalized pixel coordinates (from 0 to 1)
	float time = TIME + 2.0;
	vec2 uv = UV;
	vec4 color = vec4(uv,0.75+0.25*sin(time*0.4),1.0);
    
    color.xyz *= 0.5;
	color.y*= 0.3;
	
    //color.xyz += 0.8;

    // Output to screen
    ALBEDO =color.xyz;
		
        //ALBEDO = texture(opponent_texture, uv).rgb;
		
		
		
		//ALBEDO = texture(player_texture, uv).rgb;
    } else {
		
	float time = TIME;
	vec2 uv = UV;
	vec4 color = vec4(uv,0.75+0.25*sin(time*0.4),1.0);
    
	color.y*=0.3;
	
    color.xyz *= 0.5;
    color.xyz += 0.2;
	

    // Output to screen
    ALBEDO =color.xyz;
		//
        //ALBEDO = texture(opponent_texture, uv).rgb;
    }
	
	ALBEDO.rgb = mix(pow((ALBEDO.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),ALBEDO.rgb.rgb * (1.0 / 12.92),lessThan(ALBEDO.rgb,vec3(0.04045)));
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
