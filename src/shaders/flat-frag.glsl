#version 300 es
precision highp float;
uniform float u_DayNight;

// The fragment shader used to render the background of the scene
// Modify this to make your background more interesting

out vec4 out_Col;

void main() {
  out_Col = vec4((200.0 - u_DayNight * 10.0)/ 255.0, (200.0 - u_DayNight * 8.0) / 255.0, (100.0 + u_DayNight * 4.0) / 255.0, 0.6);
}
