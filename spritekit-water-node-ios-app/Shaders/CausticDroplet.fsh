void main(void) {
    
    // Current shader can be split into two separete shaders that perform different tasks - cutoff droplets and create caustics illusion
    
    // Water causting calculation
    
    float time = u_time * .25;
    vec2 sp = gl_FragCoord.xy / size.xy;
    vec2 p = sp * 6.0 - 20.0;
    vec2 i = p;
    float c = 1.0;
    float inten = .05;
    
    for (int n = 0; n < iterations; n++) {
        float t = time * (1.0 - (3.5 / float(n+1)));
        i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
        c += 1.0 / length(vec2(p.x / (sin(i.x + t) / inten), p.y / (cos(i.y + t) / inten)));
    }
    
    c /= float(5);
    c = 1.5-sqrt(c);
    vec3 colour = vec3(pow(abs(c), 15.0));
    
    vec4 waterColor = vec4(clamp(colour + vec3(0.0, 0.17, 0.3), 0.0, .5), 0.5);
    
    // Droplet threshold calculation and color mixing
    
    vec4 texture = texture2D(u_texture, v_tex_coord);
    float mix = 0.5;
    
    if (texture.a > 0.8) {
        texture = u_color * mix + waterColor * (1 - mix);
    } else{
        texture = vec4(0.0, 0.0, 0.0, 0.0);
    }
    
    gl_FragColor = texture;
}
