#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

layout (location=0) uniform vec2 uDownsample;
layout (location=1) uniform vec2 uSize;

layout (location=0) uniform sampler2D uTexture;

layout (location=0) out vec4 fragColor;

void main() {
    fragColor=texture(uTexture,round((FlutterFragCoord().xy/uSize)*uDownsample)/uDownsample);
}