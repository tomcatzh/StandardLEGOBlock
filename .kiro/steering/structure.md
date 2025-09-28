# Project Structure

## Repository Organization

```
StandardLEGOBlock/
├── README.md                           # Bilingual project documentation (Chinese/English)
├── LICENSE                            # MIT license
├── .gitignore                         # Excludes STL outputs, temp files, IDE configs
├── lego_basic_module.scad            # Main parametric OpenSCAD model
├── .maker_world_example/             # MakerWorld parametric syntax examples
│   └── sample.scad                   # Reference for parametric annotations
└── .kiro/                           # Kiro AI assistant configuration
    ├── steering/                    # AI guidance documents
    │   ├── product.md              # Product overview and features
    │   ├── tech.md                 # Technology stack and commands
    │   └── structure.md            # This file - project organization
    └── specs/                      # Project specifications
        ├── lego-basic-module/      # Core LEGO brick generator
        │   ├── requirements.md     # User stories and acceptance criteria
        │   ├── design.md          # Technical architecture and design
        │   └── tasks.md           # Implementation checklist
        └── lego-tiling-generator/  # Advanced tiling system
            ├── requirements.md     # User stories and acceptance criteria
            ├── design.md          # Technical architecture and design
            └── tasks.md           # Implementation checklist
```

## File Conventions

### OpenSCAD Files
- **Main Model**: `lego_basic_module.scad` - Primary parametric model
- **Parameters**: Use lowercase names for MakerWorld compatibility (`width`, `length`, `height`)
- **Comments**: Bilingual comments (Chinese/English) for international accessibility
- **Structure**: Parameters section, Hidden section, then module definitions

### Documentation
- **Bilingual**: All user-facing docs in Chinese and English
- **Technical Specs**: Detailed requirements, design, and tasks in `.kiro/specs/`
- **Steering Rules**: AI guidance documents for consistent development approach

### Generated Files (Excluded from Git)
- `*.stl` - 3D printable output files
- `*.obj`, `*.ply`, `*.3mf`, `*.amf` - Alternative 3D formats
- `build/`, `output/`, `exports/` - Build directories
- `*.echo` - OpenSCAD debug output

## Code Organization Patterns

### Parameter Structure
```scad
/* [Parameters] */
// User-configurable parameters with MakerWorld annotations

/* [Hidden] */
// Technical constants and internal parameters
```

### Module Hierarchy
1. **Main Assembly**: `union()` of all components
2. **Core Components**: 
   - `exterior_shell()` - Thin-wall outer structure
   - `top_studs()` - LEGO stud array
   - `bottom_tubes()` - Internal tube structure
3. **Helper Functions**: Dimension calculations and validations

### Naming Conventions
- **Variables**: CamelCase for constants (`LayerSize`, `UnitSize`)
- **Parameters**: lowercase for user params (`width`, `length`, `height`)
- **Modules**: snake_case for functions (`exterior_shell()`, `single_stud()`)
- **Comments**: Descriptive with units (`// 每层高度 (mm) - Height per layer`)

## Development Workflow
1. Modify parameters in OpenSCAD
2. Use F5 for quick preview during development
3. Use F6 for final render before STL export
4. Export STL for 3D printing validation
5. Update documentation if adding new features