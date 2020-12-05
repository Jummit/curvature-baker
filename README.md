# Curvature Baker

Utility addon that bakes grayscale curvature maps from a mesh.

## Usage

Instanciate the `curvature_baker.tscn` scene and call the `bake_curvature_map` function on it. It takes a mesh, the line thickness and the surface to be used.

## Results

**The model with the curvature map applied:**

![model](results/model.jpg)

**The baked curvature texture:**

![texture](results/texture.png)

## Issues

Sometimes the angle isn't correct and black or white lines appear where they shouldn't.
