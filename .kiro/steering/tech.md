---
inclusion: always
---

# Technology Stack & Development Guidelines

## Core Technology
- **OpenSCAD**: Parametric 3D modeling for LEGO-compatible bricks
- **Target Platform**: Cross-platform (macOS/Linux/Windows)
- **Output**: STL files for FDM 3D printing

## OpenSCAD Code Standards

### Resolution Settings
```scad
$fn = 32;  // Preview mode (F5) - fast iteration
$fn = 96;  // Render mode (F6) - final quality for STL export
```

### Required Code Structure
```scad
/* [Parameters] */
// User parameters: lowercase, MakerWorld compatible
width = 2;       // [1:16] 宽度 - Width in studs
length = 4;      // [1:16] 长度 - Length in studs
height = 3;      // [1:6] 高度 - Height in layers
tile_units = 1;  // [1:25] 平铺数量 - Number of bricks to tile

/* [Hidden] */
// Internal constants: CamelCase
StudSpacing = 8.0;    // IMMUTABLE: LEGO standard
LayerHeight = 9.6;    // IMMUTABLE: LEGO standard
TileSpacing = 12.0;   // FIXED: 12mm spacing between tiled bricks
```

### Validation Requirements
- Use `assert()` for all parameter bounds checking
- Use `echo()` for debugging parameter values
- Validate LEGO compatibility with exact dimensions

### Assembly Patterns
```scad
// Main assembly with tiling support
module generate_tiling() {
    if (tile_units == 1) {
        // Single brick mode
        single_lego_brick(width, length, height);
    } else {
        // Tiling mode with intelligent layout
        grid_dims = calculate_grid_dimensions(tile_units, width, length);
        positions = calculate_brick_positions(grid_dims[0], grid_dims[1], width, length, TileSpacing);
        
        for (i = [0 : len(positions)-1]) {
            translate(positions[i]) {
                single_lego_brick(width, length, height);
            }
        }
    }
}

// Individual brick assembly
union() {
    exterior_shell(width, length, height);
    top_studs(width, length);
    bottom_tubes(width, length, height);
}
```

## Development Workflow

### Testing Commands (macOS)
```bash
# Open in OpenSCAD GUI
open lego_basic_module.scad

# CLI rendering (if available)
openscad -o test_output.stl lego_basic_module.scad
```

### Standard Test Cases
```scad
// Minimal: width=1, length=1, height=1
// Standard: width=2, length=4, height=3  
// Large: width=8, length=1, height=3
// Tiling Regular: tile_units=4 (2x2 grid)
// Tiling Irregular: tile_units=7 (3+2+2 arrangement)
// Tiling Prime: tile_units=11 (4+4+3 arrangement)
```

### Performance Guidelines
- Preview with F5 during development
- Full render with F6 before STL export
- Large tiling (>16 units) may require extended render time
- Keep wall thickness ≥0.8mm for FDM printing

### Tiling System v2.0 Features
- **Intelligent Layout**: Supports both regular grid and irregular arrangements
- **Prime Number Optimization**: Special handling for prime tile_units (7→[3,2,2], 11→[4,4,3])
- **Square Preference**: Perfect squares use NxN grids when optimal
- **Fixed Spacing**: Always 12mm between bricks regardless of brick size
- **Center Alignment**: All arrangements centered at origin (0,0)
- **Size Warnings**: Automatic warnings for layouts >256x256mm

## Tiling Algorithm Implementation

### Grid Calculation Logic
```scad
function calculate_grid_dimensions(tile_units, brick_width, brick_length) = 
    tile_units == 1 ? [1, 1] :
    let(
        // Calculate physical brick dimensions with spacing
        brick_size_x = brick_width * UnitSize + TileSpacing,
        brick_size_y = brick_length * UnitSize + TileSpacing,
        
        // Find optimal factorization for square-like arrangement
        best_factors = find_optimal_factors(tile_units, brick_size_x, brick_size_y)
    )
    best_factors;
```

### Irregular Arrangement Examples
- **7 units**: [3,2,2] rows instead of 1×7 (ratio 1.0 vs ~10)
- **11 units**: [4,4,3] rows instead of 1×11 (ratio ~1.39 vs ~15)
- **13 units**: [4,3,3,3] rows instead of 1×13 (ratio 1.0 vs ~17)

### Position Calculation
```scad
function calculate_brick_positions(grid_x, grid_y, brick_width, brick_length, spacing) = 
    let(
        brick_pitch_x = brick_width * UnitSize + spacing,
        brick_pitch_y = brick_length * UnitSize + spacing,
        total_width = (grid_x - 1) * brick_pitch_x,
        total_length = (grid_y - 1) * brick_pitch_y,
        offset_x = -total_width / 2,
        offset_y = -total_length / 2
    )
    [for (i = [0 : grid_x-1])
        for (j = [0 : grid_y-1])
            [offset_x + i * brick_pitch_x, 
             offset_y + j * brick_pitch_y, 
             0]
    ];
```

## File Organization
- `lego_basic_module.scad`: Main parametric model with tiling support
- `.maker_world_example/sample.scad`: MakerWorld syntax reference
- Generated STL files excluded from git via `.gitignore`

## Quality Checklist
Before completing any code changes:
1. No OpenSCAD errors/warnings in console
2. F6 render completes successfully  
3. STL export produces manifold geometry
4. All parameters within valid ranges
5. LEGO dimensions mathematically exact
6. Tiling spacing exactly 12mm between all bricks
7. Grid calculations produce optimal aspect ratios
8. Center alignment verified at origin (0,0)
9. Size warnings display for large arrangements
10. Both single and tiling modes function correctly