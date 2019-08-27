Documentation Author: Niko Procopi 2019

This tutorial was designed for Visual Studio 2017 / 2019
If the solution does not compile, retarget the solution
to a different version of the Windows SDK. If you do not
have any version of the Windows SDK, it can be installed
from the Visual Studio Installer Tool

Welcome to the Ray Tracing UBO Tutorial!
Prerequesites: Compute Shaders

In this tutorial, all the hard-coding is removed from the shaders, and
put into C++. By removing the hard-coded arrays, we are boosting
the performance of the shaders. All of the Geometry is generated in 
main.cpp, which allows us to load OBJs in future tutorials. In addition
to geometry being generated in main.cpp, the lights are also generated
in main.cpp. The lights and geometry can be translated, rotated, and 
scaled from main.cpp with GLM, without requiring the shader code to
be changed. The shader will need to be changed if the maximum 
number of triangles per mesh, or maximum number of triangles in the scene
needs to be changed.

We have one GPU buffer that holds every triangle in the scene. It is called
compToFrag, and it is static because the CPU won't touch it. To hold 14 
triangles, the size is: sizeof(triangle) * 14. It is written by the compute shader
and read by the fragment shader

We have one GPU buffer that holds all the lights. We can easily adjust the
position, color, radius, and brightness of each light at any time. This is a 
dynamic buffer because the CPU will write to it often. It will go straight to
the fragment shader, and skip the compute shader. It is called lightToFrag

We have one GPU buffer that holds one matrix for each mesh. This is 
dynamic so that we can change the matrix. This matrix holds translation,
rotation, and scale. You can use glm::translate, glm::rotate, and glm::scale
to adjust the matrices. This is called the matrixBuffer

We have one GPU buffer that holds all Meshes, this is the triangleBuffer.
It is static because we only need to send geometry to the GPU one time