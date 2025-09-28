---
inclusion: always
---

---
inclusion: always
---

# LEGO Brick Generator - Product Guidelines

## Core Purpose
Parametric LEGO-compatible brick generator in OpenSCAD with intelligent tiling for batch 3D printing. Maintains 100% LEGO compatibility while optimizing for FDM printing constraints.

## IMMUTABLE LEGO Specifications
**NEVER modify these mathematically precise dimensions:**
- Stud spacing: 8.0mm center-to-center
- Layer height: 9.6mm per layer
- Stud diameter: 4.8mm outer, 3.2mm inner
- Wall thickness: 1.5mm minimum
- Tube dimensions: 6.51mm outer, 4.8mm inner

## Required Code Architecture

### Parameter Structure
```scad
/* [Parameters] */
width = 2;       // [1:16] 宽度 - Width in studs
length = 4;      // [1:16] 长度 - Length in studs  
height = 3;      // [1:Low, 3:High] 高度 - Height in layers
tile_units = 1;  // [1:25] 平铺数量 - Number of bricks to tile

/* [Hidden] */
TileSpacing = 12.0;  // Fixed spacing between tiled bricks
```

### Module Hierarchy
1. `generate_tiling()` - Main assembly (single/tiling mode)
2. `single_lego_brick()` - Individual brick generation
3. `exterior_shell()`, `top_studs()`, `bottom_tubes()` - Core components
4. `calculate_grid_dimensions()`, `calculate_brick_positions()` - Tiling functions

### Naming Conventions
- **User parameters**: lowercase (`width`, `length`, `height`)
- **Internal constants**: CamelCase (`StudSpacing`, `TileSpacing`)
- **Modules**: snake_case (`exterior_shell()`, `single_stud()`)
- **Comments**: Bilingual `// 中文 - English`

## Implementation Standards

### OpenSCAD Requirements
- Resolution: `$fn = 96`
- Assembly: Always use `union()` for parts
- Validation: `assert()` for parameter ranges
- Debugging: `echo()` for parameter output

## Tiling System Rules

### Layout Algorithm
- Grid optimization for minimal footprint
- Square preference for balanced printing
- Center alignment at origin (0,0)
- Smart factorization for non-square arrangements

### Tiling Modes
1. Single (tile_units = 1)
2. Regular grid (N×N when possible)
3. Optimized irregular (factorized)
4. Linear fallback (1×N for primes)

### Size Limits
- Single brick: 1-16 studs (width/length), 1-6 layers (height)
- Tiling: 1-25 bricks total

## Scope Boundaries

### Allowed
- Rectangular bricks/plates only
- Standard LEGO studs and tubes
- Parameter-driven dimensions
- Multi-brick tiling layouts

### Forbidden
- Technic components
- Curved shapes
- Minifigure accessories
- Complex mechanical parts

## Quality Checklist
Always verify before completion:
1. LEGO dimensions exact match
2. Parameter validation with `assert()`
3. Wall thickness ≥0.8mm
4. No OpenSCAD errors/warnings
5. Manifold STL output
6. 8mm stud grid alignment
7. 12mm tiling spacing
8. Reasonable render performance