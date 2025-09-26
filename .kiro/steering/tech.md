# Technology Stack

## Primary Technology
- **OpenSCAD**: Parametric 3D modeling language for generating LEGO-compatible brick models
- **Language**: OpenSCAD scripting (.scad files)

## Development Environment
- **Platform**: Cross-platform (macOS, Linux, Windows)
- **IDE**: OpenSCAD application or any text editor
- **Version Control**: Git

## Key Libraries & Dependencies
- No external libraries required - uses pure OpenSCAD
- Requires OpenSCAD application for rendering and STL export

## Build & Development Commands

### Preview and Rendering
```bash
# Open model in OpenSCAD GUI
open lego_basic_module.scad

# Command line rendering (if OpenSCAD CLI available)
openscad -o output.stl lego_basic_module.scad
```

### OpenSCAD Workflow
- **F5**: Quick preview (fast, lower quality)
- **F6**: Full render (slow, high quality for STL export)
- **Export STL**: File → Export → Export as STL

### Testing Parameters
```scad
// Common test configurations
Width = 2; Length = 4; Height = 3;  // Standard 2x4 brick
Width = 1; Length = 1; Height = 1;  // Minimal 1x1 plate
Width = 8; Length = 1; Height = 3;  // Long 1x8 brick
```

## File Structure
- `lego_basic_module.scad`: Main parametric model file
- `.maker_world_example/sample.scad`: MakerWorld parametric syntax reference
- `.kiro/specs/`: Project specifications and requirements

## Output Formats
- **STL**: Primary format for 3D printing
- **3MF/AMF**: Alternative 3D printing formats (via OpenSCAD export)
- **PNG**: 2D renders for documentation

## Performance Considerations
- Use `$fn = 96` for smooth curves in final renders
- Lower `$fn` values for faster preview during development
- Large brick dimensions (>10 units) may require longer render times