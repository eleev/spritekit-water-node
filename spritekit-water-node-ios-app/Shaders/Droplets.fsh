void main() {
    
    vec4 texture = texture2D(u_texture, v_tex_coord);
    if (texture.a > 0.8) {
        texture = u_color;
    }
    else{
        texture = vec4(0.0, 0.0, 0.0, 0.0);
    }
    
    gl_FragColor = texture;
}
