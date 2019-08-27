/*
Title: Advanced Ray Tracer
File Name: FragmentShader.glsl
Copyright � 2019
Original authors: Niko Procopi
Written under the supervision of David I. Schwartz, Ph.D., and
supported by a professional development seed grant from the B. Thomas
Golisano College of Computing & Information Sciences
(https://www.rit.edu/gccis) at the Rochester Institute of Technology.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

References:
https://github.com/LWJGL/lwjgl3-wiki/wiki/2.6.1.-Ray-tracing-with-OpenGL-Compute-Shaders-(Part-I)

Description:
This program serves to demonstrate the concept of ray tracing. This
builds off a previous Intermediate Ray Tracer, adding in reflections. 
There are four point lights, specular and diffuse lighting, and shadows. 
It is important to note that the light positions and triangles being 
rendered are all hardcoded in the shader itself. Usually, you would 
pass those values into the Fragment Shader via a Uniform Buffer.

WARNING: Framerate may suffer depending on your hardware. This is a normal 
problem with Ray Tracing. If it runs too slowly, try removing the second 
cube from the triangles array in the Fragment Shader (and also adjusting 
NUM_TRIANGLES accordingly). There are many optimization techniques out 
there, but ultimately Ray Tracing is not typically used for Real-Time 
rendering.
*/

// Compute shaders are part of openGL core since version 4.3
#version 430

// This will just run once for each particle.
layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

struct InTriangle {
	vec4 a;
	vec4 b;
	vec4 c;
	vec4 normal;
	vec4 color;
};

struct OutTriangle
{
	vec3 a;
	vec3 b;
	vec3 c;
	vec3 normal;
	vec3 color;
};

// A layout describing the vertex buffer.
layout(binding = 0) buffer b0
{
	OutTriangle triangles[14];
} outBuffer;

#define MAX_MESHES 2
#define MAX_TRIANGLES_PER_MESH 12

struct Mesh
{
	int numTriangles;
	int junk1;
	int junk2;
	int junk3;
	InTriangle t[MAX_TRIANGLES_PER_MESH];
};

layout (binding = 1) buffer b1
{
	Mesh m[MAX_MESHES];
} inGeometry;

layout (binding = 2) buffer b2
{
	mat4x4 m[MAX_MESHES];
} inMatrices;

// Declare main program function which is executed when
void main()
{
	// Get the index of this object into the buffer
	uint i = gl_GlobalInvocationID.x;

	int meshIndex = 0;
	uint count = i;
	
	// count is the triangle index of the mesh
	// that is being processed

	while(count >= inGeometry.m[meshIndex].numTriangles)
	{
		count -= inGeometry.m[meshIndex].numTriangles;
		meshIndex++;
	}

	vec4 a = inMatrices.m[meshIndex] * inGeometry.m[meshIndex].t[count].a;
	vec4 b = inMatrices.m[meshIndex] * inGeometry.m[meshIndex].t[count].b;
	vec4 c = inMatrices.m[meshIndex] * inGeometry.m[meshIndex].t[count].c;

	outBuffer.triangles[i].a = a.xyz;
	outBuffer.triangles[i].b = b.xyz;
	outBuffer.triangles[i].c = c.xyz;

	vec3 normal = mat3(inMatrices.m[meshIndex]) * inGeometry.m[meshIndex].t[count].normal.xyz;

	outBuffer.triangles[i].normal = normalize(normal);
	outBuffer.triangles[i].color = inGeometry.m[meshIndex].t[count].color.xyz;
}