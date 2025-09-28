/*
 * 参数化乐高基础模块 - Parametric LEGO Basic Module
 * 
 * 生成符合乐高官方规格的3D可打印积木模型
 * 支持单个积木和智能平铺排列
 */

/* [Parameters] */

width = 6; // [1:31] 积木宽度 - Block width in units
length = 2; // [1:31] 积木长度 - Block length in units  
height = 3; // [1:Low, 3:High] 积木高度 - Block height in layers
tile_units = 11; // [1:25] 平铺数量 - Number of bricks (1=single, >1=tiling)

/* [Hidden] */

$fn = 96;

// 乐高标准规格常量 - LEGO Standard Specifications
LayerSize = 3.2;        // 每层高度 - Height per layer
UnitSize = 8;           // 单位尺寸 - Unit size (8x8mm grid)
StudDiameter = 4.8;     // 凸点直径 - Stud diameter
StudHeight = 1.8;       // 凸点高度 - Stud height
StudMargin = UnitSize / 2;
TubeInnerDiameter = 4.8;  // 内管直径 - Inner tube diameter
TubeOuterDiameter = 6.5;  // 外管直径 - Outer tube diameter  
TubeMargin = UnitSize;
CLEARANCESize = 0.2;    // 间隙尺寸 - Clearance for tight fit
WallThickness = 1.6;    // 壁厚 - Wall thickness
TileSpacing = 12;       // 平铺间距 - Spacing between bricks


// 尺寸计算函数 - Size Calculation Functions
function calculate_outer_dimensions(width, length, height, unit_size, clearance) = [
    width * unit_size - clearance,
    length * unit_size - clearance,
    height * LayerSize
];

function calculate_inner_dimensions(outer_dims, wall_thickness) = [
    outer_dims[0] - 2 * wall_thickness,
    outer_dims[1] - 2 * wall_thickness,
    outer_dims[2] - wall_thickness
];

function calculate_stud_positions(width, length, unit_size) = [
    for (i = [0:width-1])
        for (j = [0:length-1])
            [
                (i - (width-1)/2) * unit_size,
                (j - (length-1)/2) * unit_size,
                0
            ]
];

function calculate_tube_positions(width, length, tube_margin) = 
    (width > 1 && length > 1) ? [
        for (i = [0:width-2])
            for (j = [0:length-2])
                [
                    (i - (width-2)/2) * tube_margin,
                    (j - (length-2)/2) * tube_margin,
                    0
                ]
    ] : [];

function apply_clearance_adjustment(value, clearance, adjustment_type = "full") = 
    adjustment_type == "full" ? value - clearance :
    adjustment_type == "half" ? value - clearance/2 :
    value;

function validate_parameters(width, length, height) = 
    width > 0 && length > 0 && height > 0;

function calculate_stud_count(width, length) = width * length;

function calculate_tube_count(width, length, height) = 
    (width > 1 && length > 1) ? (width - 1) * (length - 1) : 0;

function calculate_tube_height(height, layer_size) = 
    layer_size * height;

// 平铺网格计算函数 - Tiling Grid Calculation Functions
function calculate_optimal_layout(tile_units, brick_width, brick_length) = 
    assert(tile_units >= 1, "tile_units must be >= 1")
    assert(brick_width >= 1, "brick_width must be >= 1") 
    assert(brick_length >= 1, "brick_length must be >= 1")
    
    tile_units == 1 ? ["regular", [1, 1]] :
    let(
        brick_size_x = brick_width * UnitSize,
        brick_size_y = brick_length * UnitSize,
        regular_result = find_optimal_regular_grid(tile_units, brick_size_x, brick_size_y),
        regular_layout = regular_result[0],
        regular_ratio = regular_result[1],
        irregular_result = find_optimal_irregular_layout(tile_units, brick_size_x, brick_size_y),
        irregular_layout = irregular_result[0],
        irregular_ratio = irregular_result[1],
        best_layout = irregular_ratio < regular_ratio ? irregular_layout : regular_layout
    )
    best_layout;
function find_optimal_regular_grid(n, size_x, size_y) = 
    let(
        all_factors = [for (i = [1 : n]) if (n % i == 0) [i, n/i]],
        ratios = [for (factors = all_factors) 
            let(
                total_x = factors[0] * size_x + (factors[0] - 1) * TileSpacing,
                total_y = factors[1] * size_y + (factors[1] - 1) * TileSpacing,
                ratio = max(total_x, total_y) / min(total_x, total_y)
            )
            [factors, ratio]
        ],
        best_ratio = min([for (r = ratios) r[1]]),
        best_factors = [for (r = ratios) if (r[1] == best_ratio) r[0]][0]
    )
    [["regular", best_factors], best_ratio];
function find_optimal_irregular_layout(n, size_x, size_y) = 
    let(
        layouts_2_rows = generate_2_row_layouts(n, size_x, size_y),
        layouts_3_rows = n >= 6 ? generate_3_row_layouts(n, size_x, size_y) : [],
        layouts_4_rows = n >= 10 ? generate_4_row_layouts(n, size_x, size_y) : [],
        all_irregular = concat(layouts_2_rows, layouts_3_rows, layouts_4_rows),
        best_irregular = len(all_irregular) > 0 ? 
            let(
                ratios = [for (layout = all_irregular) layout[1]],
                min_ratio = min(ratios),
                best_layout = [for (layout = all_irregular) if (layout[1] == min_ratio) layout][0]
            )
            best_layout : [["regular", [1, n]], 999]
    )
    best_irregular;
function generate_2_row_layouts(n, size_x, size_y) = 
    let(
        max_first_row = floor(n/2),
        layouts = [for (first_row = [1 : max_first_row])
            let(
                second_row = n - first_row,
                max_row_width = max(first_row, second_row),
                total_x = max_row_width * size_x + (max_row_width - 1) * TileSpacing,
                total_y = 2 * size_y + TileSpacing,
                ratio = max(total_x, total_y) / min(total_x, total_y),
                layout_config = ["irregular", [first_row, second_row]]
            )
            [layout_config, ratio]
        ]
    )
    layouts;
function generate_3_row_layouts(n, size_x, size_y) = 
    let(
        base_per_row = floor(n / 3),
        remainder = n % 3,
        row1 = base_per_row + (remainder >= 1 ? 1 : 0),
        row2 = base_per_row + (remainder >= 2 ? 1 : 0),
        row3 = base_per_row,
        max_row_width = max(row1, max(row2, row3)),
        total_x = max_row_width * size_x + (max_row_width - 1) * TileSpacing,
        total_y = 3 * size_y + 2 * TileSpacing,
        ratio = max(total_x, total_y) / min(total_x, total_y),
        layout_config = ["irregular", [row1, row2, row3]]
    )
    [[layout_config, ratio]];
function generate_4_row_layouts(n, size_x, size_y) = 
    let(
        base_per_row = floor(n / 4),
        remainder = n % 4,
        row1 = base_per_row + (remainder >= 1 ? 1 : 0),
        row2 = base_per_row + (remainder >= 2 ? 1 : 0),
        row3 = base_per_row + (remainder >= 3 ? 1 : 0),
        row4 = base_per_row,
        max_row_width = max(row1, max(row2, max(row3, row4))),
        total_x = max_row_width * size_x + (max_row_width - 1) * TileSpacing,
        total_y = 4 * size_y + 3 * TileSpacing,
        ratio = max(total_x, total_y) / min(total_x, total_y),
        layout_config = ["irregular", [row1, row2, row3, row4]]
    )
    [[layout_config, ratio]];
function calculate_grid_dimensions(tile_units, brick_width, brick_length) = 
    let(
        layout = calculate_optimal_layout(tile_units, brick_width, brick_length)
    )
    layout[0] == "regular" ? layout[1] : 
    let(
        row_config = layout[1],
        max_row_width = max(row_config),
        row_count = len(row_config)
    )
    [max_row_width, row_count];

function find_optimal_factors(n, size_x, size_y) = 
    assert(n >= 1, "n must be >= 1")
    assert(size_x > 0, "size_x must be > 0")
    assert(size_y > 0, "size_y must be > 0")
    
    let(
        all_factors = [for (i = [1 : n]) if (n % i == 0) [i, n/i]],
        ratios = [for (factors = all_factors) 
            let(
                total_x = factors[0] * size_x + (factors[0] - 1) * TileSpacing,
                total_y = factors[1] * size_y + (factors[1] - 1) * TileSpacing,
                ratio = max(total_x, total_y) / min(total_x, total_y)
            )
            [factors, ratio]
        ],
        best_ratio = min([for (r = ratios) r[1]]),
        best_factors = [for (r = ratios) if (r[1] == best_ratio) r[0]][0]
    )
    best_factors;

function calculate_total_tiling_size(grid_x, grid_y, brick_width, brick_length) = 
    assert(grid_x >= 1, "grid_x must be >= 1")
    assert(grid_y >= 1, "grid_y must be >= 1")
    assert(brick_width >= 1, "brick_width must be >= 1")
    assert(brick_length >= 1, "brick_length must be >= 1")
    
    let(
        total_width = grid_x * brick_width * UnitSize + (grid_x - 1) * TileSpacing,
        total_length = grid_y * brick_length * UnitSize + (grid_y - 1) * TileSpacing
    )
    [total_width, total_length];

// 计算不规则排列总体尺寸的函数
// Function to calculate irregular layout total dimensions
function calculate_irregular_total_size(row_config, brick_width, brick_length) = 
    assert(len(row_config) >= 1, "row_config must have at least 1 row")
    assert(brick_width >= 1, "brick_width must be >= 1")
    assert(brick_length >= 1, "brick_length must be >= 1")
    
    let(
        brick_size_x = brick_width * UnitSize,
        brick_size_y = brick_length * UnitSize,
        row_count = len(row_config),
        
        // 计算最大行宽度
        max_bricks_per_row = max(row_config),
        total_width = max_bricks_per_row * brick_size_x + (max_bricks_per_row - 1) * TileSpacing,
        
        // 计算总高度
        total_height = row_count * brick_size_y + (row_count - 1) * TileSpacing
    )
    [total_width, total_height];

// 计算平铺总体尺寸的主函数（简化接口）
// Main function to calculate total tiling size (simplified interface)
function calculate_total_size(tile_units, brick_width, brick_length) = 
    assert(tile_units >= 1, "tile_units must be >= 1")
    assert(brick_width >= 1, "brick_width must be >= 1")
    assert(brick_length >= 1, "brick_length must be >= 1")
    
    tile_units == 1 ? 
        // 单个积木尺寸 - Single brick size
        [brick_width * UnitSize, brick_length * UnitSize] :
        // 平铺尺寸 - Tiling size
        let(
            grid_dims = calculate_grid_dimensions(tile_units, brick_width, brick_length)
        )
        calculate_total_tiling_size(grid_dims[0], grid_dims[1], brick_width, brick_length);



// 位置计算函数 - Position Calculation Functions


function calculate_brick_positions_advanced(layout_config, brick_width, brick_length, spacing) = 
    let(
        layout_type = layout_config[0],
        layout_data = layout_config[1]
    )
    layout_type == "regular" ? 
        calculate_regular_positions(layout_data[0], layout_data[1], brick_width, brick_length, spacing) :
        calculate_irregular_positions(layout_data, brick_width, brick_length, spacing);
function calculate_regular_positions(grid_x, grid_y, brick_width, brick_length, spacing) = 
    assert(grid_x >= 1, "grid_x must be >= 1")
    assert(grid_y >= 1, "grid_y must be >= 1") 
    assert(brick_width >= 1, "brick_width must be >= 1")
    assert(brick_length >= 1, "brick_length must be >= 1")
    assert(spacing >= 0, "spacing must be >= 0")
    
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
            [
                offset_x + i * brick_pitch_x,
                offset_y + j * brick_pitch_y,
                0
            ]
    ];
function calculate_irregular_positions(row_config, brick_width, brick_length, spacing) = 
    assert(len(row_config) >= 1, "row_config must have at least 1 row")
    assert(brick_width >= 1, "brick_width must be >= 1")
    assert(brick_length >= 1, "brick_length must be >= 1")
    assert(spacing >= 0, "spacing must be >= 0")
    
    let(
        brick_size_x = brick_width * UnitSize,
        brick_size_y = brick_length * UnitSize,
        row_count = len(row_config),
        total_height = row_count * brick_size_y + (row_count - 1) * spacing,
        start_y = -total_height / 2 + brick_size_y / 2,
        row_y_positions = [for (i = [0 : row_count-1]) 
            start_y + i * (brick_size_y + spacing)],
        all_positions = [for (row_idx = [0 : row_count-1])
            let(
                bricks_in_row = row_config[row_idx],
                row_y = row_y_positions[row_idx],
                row_width = bricks_in_row * brick_size_x + (bricks_in_row - 1) * spacing,
                start_x = -row_width / 2 + brick_size_x / 2,
                row_positions = [for (col_idx = [0 : bricks_in_row-1])
                    [start_x + col_idx * (brick_size_x + spacing), row_y, 0]
                ]
            )
            row_positions
        ],
        flattened_positions = [for (row_positions = all_positions)
            for (pos = row_positions) pos]
    )
    flattened_positions;
function calculate_brick_positions(grid_x, grid_y, brick_width, brick_length, spacing) = 
    calculate_regular_positions(grid_x, grid_y, brick_width, brick_length, spacing);
function calculate_brick_pitch(brick_width, brick_length, spacing) = 
    assert(brick_width >= 1, "brick_width must be >= 1")
    assert(brick_length >= 1, "brick_length must be >= 1")
    assert(spacing >= 0, "spacing must be >= 0")
    
    [
        brick_width * UnitSize + spacing,
        brick_length * UnitSize + spacing
    ];
function calculate_center_offset(grid_x, grid_y, pitch_x, pitch_y) = 
    assert(grid_x >= 1, "grid_x must be >= 1")
    assert(grid_y >= 1, "grid_y must be >= 1")
    assert(pitch_x > 0, "pitch_x must be > 0")
    assert(pitch_y > 0, "pitch_y must be > 0")
    
    let(
        total_span_x = (grid_x - 1) * pitch_x,
        total_span_y = (grid_y - 1) * pitch_y
    )
    [
        -total_span_x / 2,
        -total_span_y / 2
    ];

module validate_brick_positions(positions, expected_count) {
    assert(len(positions) == expected_count, 
           str("Position count mismatch: got ", len(positions), ", expected ", expected_count));
    assert(len(positions) > 0, "Position array cannot be empty");
    assert(len([for (pos = positions) if (len(pos) != 3) pos]) == 0, 
           "All positions must have exactly 3 coordinates [x, y, z]");
    assert(len([for (pos = positions) if (pos[2] != 0) pos]) == 0, 
           "All Z coordinates must be 0 (same plane)");
}

function calculate_position_bounds(positions, brick_width, brick_length) = 
    assert(len(positions) > 0, "Position array cannot be empty")
    assert(brick_width >= 1, "brick_width must be >= 1")
    assert(brick_length >= 1, "brick_length must be >= 1")
    
    let(
        brick_size_x = brick_width * UnitSize,
        brick_size_y = brick_length * UnitSize,
        x_coords = [for (pos = positions) pos[0]],
        y_coords = [for (pos = positions) pos[1]],
        min_x = min(x_coords) - brick_size_x / 2,
        max_x = max(x_coords) + brick_size_x / 2,
        min_y = min(y_coords) - brick_size_y / 2,
        max_y = max(y_coords) + brick_size_y / 2
    )
    [
        [min_x, min_y],
        [max_x, max_y]
    ];



// 尺寸验证和警告系统 - Size Validation and Warning System

/*
 * 尺寸验证和警告系统说明 - Size Validation and Warning System Description
 * 
 * 功能：验证平铺尺寸并提供相应的警告和建议
 * Function: Validate tiling dimensions and provide appropriate warnings and suggestions
 * 
 * 主要检查项目 - Main Check Items:
 * 1. 打印床尺寸限制 - Print bed size limitations (256x256mm)
 * 2. 性能影响评估 - Performance impact assessment
 * 3. 平铺信息显示 - Tiling information display
 * 4. 打印建议提供 - Printing recommendations
 * 
 * 警告级别 - Warning Levels:
 * - 信息 INFO: 正常的配置信息显示
 * - 提示 HINT: 性能和使用建议
 * - 警告 WARNING: 可能的问题和限制
 * - 错误 ERROR: 严重问题，可能导致失败
 */

/*
 * 尺寸验证和警告的主模块 - Main module for size validation and warnings
 * 
 * 功能描述 Function Description:
 * 这是一个综合性的尺寸验证和警告系统，负责检查平铺配置的各个方面，
 * 包括打印床兼容性、性能影响、尺寸合理性等，并提供详细的建议和警告。
 * 
 * This is a comprehensive size validation and warning system responsible for checking
 * various aspects of tiling configuration, including print bed compatibility, 
 * performance impact, size reasonableness, etc., and providing detailed suggestions and warnings.
 * 
 * 参数说明 Parameter Description:
 * @param total_x: 平铺总宽度(mm) Total tiling width in mm
 * @param total_y: 平铺总长度(mm) Total tiling length in mm
 * @param grid_x: X方向积木数量 Number of bricks in X direction
 * @param grid_y: Y方向积木数量 Number of bricks in Y direction
 * @param tile_units: 积木总数量 Total number of bricks
 * @param brick_width: 单个积木宽度(单位) Single brick width in units
 * @param brick_length: 单个积木长度(单位) Single brick length in units
 * 
 * 验证项目 Validation Items:
 * 
 * 1. 基本信息显示 Basic Information Display:
 *    - 积木规格和数量 Brick specifications and count
 *    - 网格排列方式 Grid arrangement pattern
 *    - 总体尺寸和长宽比 Overall dimensions and aspect ratio
 * 
 * 2. 打印床兼容性检查 Print Bed Compatibility Check:
 *    - 标准打印床(256×256mm)兼容性 Standard bed compatibility
 *    - 大型打印床(300×300mm)兼容性 Large bed compatibility
 *    - 尺寸超限警告 Size limit warnings
 * 
 * 3. 性能影响评估 Performance Impact Assessment:
 *    - 渲染性能预估 Rendering performance estimation
 *    - 内存使用评估 Memory usage assessment
 *    - 处理时间预警 Processing time warnings
 * 
 * 4. 打印建议生成 Printing Recommendations Generation:
 *    - 基于尺寸的打印设置建议 Size-based print setting suggestions
 *    - 材料和支撑建议 Material and support recommendations
 *    - 质量优化建议 Quality optimization suggestions
 * 
 * 5. 布局优化建议 Layout Optimization Suggestions:
 *    - 长宽比优化建议 Aspect ratio optimization suggestions
 *    - 参数调整建议 Parameter adjustment suggestions
 *    - 替代配置推荐 Alternative configuration recommendations
 * 
 * 警告级别系统 Warning Level System:
 * 
 * ✓ 信息 INFO (绿色):
 *   - 正常配置信息 Normal configuration info
 *   - 兼容性确认 Compatibility confirmation
 *   - 成功状态显示 Success status display
 * 
 * ⚠ 提示 HINT (黄色):
 *   - 性能建议 Performance suggestions
 *   - 优化提示 Optimization hints
 *   - 最佳实践建议 Best practice recommendations
 * 
 * ⚠ 警告 WARNING (橙色):
 *   - 潜在问题警告 Potential issue warnings
 *   - 限制条件提醒 Limitation reminders
 *   - 注意事项说明 Precaution explanations
 * 
 * ✗ 错误 ERROR (红色):
 *   - 严重问题报告 Critical issue reports
 *   - 不可行配置警告 Infeasible configuration warnings
 *   - 必须修改的问题 Issues that must be fixed
 * 
 * 打印床尺寸标准 Print Bed Size Standards:
 * 
 * 小型打印床 Small Print Beds:
 * - 200×200mm: 入门级打印机 Entry-level printers
 * - 220×220mm: 常见桌面打印机 Common desktop printers
 * 
 * 标准打印床 Standard Print Beds:
 * - 256×256mm: 主流打印机标准 Mainstream printer standard
 * - 250×250mm: 常见工业标准 Common industrial standard
 * 
 * 大型打印床 Large Print Beds:
 * - 300×300mm: 大型桌面打印机 Large desktop printers
 * - 400×400mm: 工业级打印机 Industrial-grade printers
 * 
 * 性能阈值设计 Performance Threshold Design:
 * 
 * 积木数量性能影响 Brick Count Performance Impact:
 * - 1-4个积木: 优秀性能 Excellent performance (<1秒渲染 <1s render)
 * - 5-9个积木: 良好性能 Good performance (1-5秒渲染 1-5s render)
 * - 10-16个积木: 中等性能 Moderate performance (5-15秒渲染 5-15s render)
 * - 17-25个积木: 较慢性能 Slow performance (15-60秒渲染 15-60s render)
 * 
 * 尺寸复杂度影响 Size Complexity Impact:
 * - 总尺寸<100mm: 简单处理 Simple processing
 * - 总尺寸100-200mm: 中等复杂度 Moderate complexity
 * - 总尺寸200-300mm: 高复杂度 High complexity
 * - 总尺寸>300mm: 极高复杂度 Very high complexity
 */
module validate_tiling_size(total_x, total_y, grid_x, grid_y, tile_units, brick_width, brick_length) {
    // 参数验证 - Parameter validation
    assert(total_x > 0, "total_x must be > 0");
    assert(total_y > 0, "total_y must be > 0");
    assert(grid_x >= 1, "grid_x must be >= 1");
    assert(grid_y >= 1, "grid_y must be >= 1");
    assert(tile_units >= 1, "tile_units must be >= 1");
    assert(brick_width >= 1, "brick_width must be >= 1");
    assert(brick_length >= 1, "brick_length must be >= 1");
    
    // 打印床尺寸常量 - Print bed size constants
    max_bed_size = 256;        // 常见打印床尺寸 (mm) - Common print bed size
    large_bed_size = 300;      // 大型打印床尺寸 (mm) - Large print bed size
    warning_threshold = 200;   // 警告阈值 (mm) - Warning threshold
    
    // 性能阈值 - Performance thresholds
    performance_warning_count = 16;  // 积木数量性能警告阈值 - Brick count performance warning threshold
    performance_critical_count = 25; // 积木数量性能严重警告阈值 - Brick count performance critical threshold
    
    echo("=== 尺寸验证和警告系统 Size Validation & Warning System ===");
    
    // 1. 基本平铺信息显示 - Basic tiling information display
    echo(str("平铺配置信息 Tiling Configuration Info:"));
    echo(str("  积木规格 Brick Spec: ", brick_width, "×", brick_length, " 单位 units"));
    echo(str("  平铺数量 Tile Count: ", tile_units, " 个积木 bricks"));
    echo(str("  网格排列 Grid Layout: ", grid_x, "×", grid_y));
    echo(str("  积木间距 Brick Spacing: ", TileSpacing, "mm"));
    echo(str("  平铺总尺寸 Total Tiling Size: ", total_x, "×", total_y, "mm"));
    
    // 计算长宽比 - Calculate aspect ratio
    aspect_ratio = max(total_x, total_y) / min(total_x, total_y);
    echo(str("  长宽比 Aspect Ratio: ", aspect_ratio, " (越接近1越好 closer to 1 is better)"));
    
    // 2. 打印床尺寸检查 - Print bed size check
    echo(str("打印床兼容性检查 Print Bed Compatibility Check:"));
    
    if (total_x <= max_bed_size && total_y <= max_bed_size) {
        echo(str("  ✓ 兼容标准打印床 Compatible with standard print bed (", max_bed_size, "×", max_bed_size, "mm)"));
    } else if (total_x <= large_bed_size && total_y <= large_bed_size) {
        echo(str("  ⚠ 需要大型打印床 Requires large print bed (", large_bed_size, "×", large_bed_size, "mm)"));
        echo(str("  警告 WARNING: 尺寸 ", total_x, "×", total_y, "mm 超过标准打印床 ", max_bed_size, "×", max_bed_size, "mm"));
    } else {
        echo(str("  ✗ 超出常见打印床范围 Exceeds common print bed range"));
        echo(str("  错误 ERROR: 尺寸 ", total_x, "×", total_y, "mm 过大，可能无法打印 Too large, may not be printable"));
    }
    
    // 3. 尺寸警告检查 - Size warning check
    if (total_x > warning_threshold || total_y > warning_threshold) {
        echo(str("尺寸警告 Size Warnings:"));
        if (total_x > warning_threshold) {
            echo(str("  ⚠ X方向尺寸较大 Large X dimension: ", total_x, "mm > ", warning_threshold, "mm"));
        }
        if (total_y > warning_threshold) {
            echo(str("  ⚠ Y方向尺寸较大 Large Y dimension: ", total_y, "mm > ", warning_threshold, "mm"));
        }
        echo(str("  建议 Recommendation: 考虑减少tile_units或使用更小的积木规格"));
        echo(str("  Suggestion: Consider reducing tile_units or using smaller brick specifications"));
    }
    
    // 4. 性能影响评估 - Performance impact assessment
    echo(str("性能影响评估 Performance Impact Assessment:"));
    
    if (tile_units <= 4) {
        echo(str("  ✓ 渲染性能良好 Good rendering performance (", tile_units, " 积木 bricks)"));
    } else if (tile_units <= performance_warning_count) {
        echo(str("  ⚠ 渲染性能中等 Moderate rendering performance (", tile_units, " 积木 bricks)"));
        echo(str("  提示 HINT: 渲染时间可能稍长 Rendering time may be slightly longer"));
    } else if (tile_units <= performance_critical_count) {
        echo(str("  ⚠ 渲染性能较慢 Slow rendering performance (", tile_units, " 积木 bricks)"));
        echo(str("  警告 WARNING: 渲染可能需要较长时间，建议使用F5预览模式"));
        echo(str("  Warning: Rendering may take longer, recommend using F5 preview mode"));
    } else {
        echo(str("  ✗ 渲染性能严重影响 Severe rendering performance impact (", tile_units, " 积木 bricks)"));
        echo(str("  严重警告 CRITICAL: 渲染时间很长，可能导致系统响应缓慢"));
        echo(str("  Critical: Very long rendering time, may cause system slowdown"));
    }
    
    // 5. 打印建议 - Printing recommendations
    echo(str("3D打印建议 3D Printing Recommendations:"));
    
    // 基于尺寸的建议 - Size-based recommendations
    if (total_x > max_bed_size || total_y > max_bed_size) {
        echo(str("  • 考虑分批打印或使用更大的打印机"));
        echo(str("    Consider batch printing or using a larger printer"));
    }
    
    // 基于积木数量的建议 - Brick count-based recommendations
    if (tile_units > 9) {
        echo(str("  • 建议使用筏板(Raft)提高附着力"));
        echo(str("    Recommend using raft for better bed adhesion"));
        echo(str("  • 考虑降低打印速度以提高质量"));
        echo(str("    Consider reducing print speed for better quality"));
    }
    
    // 基于间距的建议 - Spacing-based recommendations
    echo(str("  • 12mm间距确保足够的后处理空间"));
    echo(str("    12mm spacing ensures adequate post-processing space"));
    echo(str("  • 建议使用支撑移除工具处理间隙区域"));
    echo(str("    Recommend using support removal tools for gap areas"));
    
    // 6. 优化建议 - Optimization suggestions
    if (aspect_ratio > 2.0) {
        echo(str("布局优化建议 Layout Optimization Suggestions:"));
        echo(str("  • 当前长宽比较大 Current aspect ratio is large: ", aspect_ratio));
        echo(str("  • 考虑调整积木规格以获得更方形的布局"));
        echo(str("    Consider adjusting brick specifications for more square layout"));
        echo(str("  • 或者调整tile_units数量以改善比例"));
        echo(str("    Or adjust tile_units count to improve ratio"));
    }
    
    echo("========================================================");
}

// 简化的尺寸验证函数（向后兼容）
// Simplified size validation function (backward compatibility)
module validate_size_simple(total_x, total_y) {
    max_bed_size = 256;
    if (total_x > max_bed_size || total_y > max_bed_size) {
        echo(str("警告 WARNING: 平铺尺寸 ", total_x, "×", total_y, 
                "mm 超过常见打印床尺寸 ", max_bed_size, "×", max_bed_size, "mm"));
    }
}

// 性能警告函数
// Performance warning function
module performance_warning(tile_units) {
    assert(tile_units >= 1, "tile_units must be >= 1");
    
    if (tile_units > 16) {
        echo("提示 HINT: 积木数量较多，渲染可能需要较长时间");
        echo("Hint: Large number of bricks, rendering may take longer");
        
        if (tile_units > 20) {
            echo("建议 RECOMMENDATION: 考虑使用F5快速预览模式进行调试");
            echo("Recommendation: Consider using F5 quick preview mode for debugging");
        }
    }
}

// 不规则排列的验证函数
// Validation function for irregular layouts
module validate_irregular_tiling_size(total_x, total_y, row_config, tile_units, brick_width, brick_length) {
    // 参数验证 - Parameter validation
    assert(total_x > 0, "total_x must be > 0");
    assert(total_y > 0, "total_y must be > 0");
    assert(len(row_config) >= 1, "row_config must have at least 1 row");
    assert(tile_units >= 1, "tile_units must be >= 1");
    assert(brick_width >= 1, "brick_width must be >= 1");
    assert(brick_length >= 1, "brick_length must be >= 1");
    
    // 验证行配置的积木总数
    total_bricks_in_config = len([for (row = row_config) for (i = [1:row]) i]);
    assert(total_bricks_in_config == tile_units, 
           str("Row config mismatch: ", total_bricks_in_config, " != ", tile_units));
    
    echo("=== 不规则排列验证 Irregular Layout Validation ===");
    echo(str("排列配置信息 Layout Configuration Info:"));
    echo(str("  积木规格 Brick Spec: ", brick_width, "×", brick_length, " 单位 units"));
    echo(str("  平铺数量 Tile Count: ", tile_units, " 个积木 bricks"));
    echo(str("  行配置 Row Configuration: ", row_config, " (每行积木数 bricks per row)"));
    echo(str("  行数 Number of Rows: ", len(row_config)));
    echo(str("  最大行宽 Max Row Width: ", max(row_config), " 积木 bricks"));
    echo(str("  积木间距 Brick Spacing: ", TileSpacing, "mm"));
    echo(str("  平铺总尺寸 Total Tiling Size: ", total_x, "×", total_y, "mm"));
    
    // 计算长宽比 - Calculate aspect ratio
    aspect_ratio = max(total_x, total_y) / min(total_x, total_y);
    echo(str("  长宽比 Aspect Ratio: ", aspect_ratio, " (越接近1越好 closer to 1 is better)"));
    
    // 打印床兼容性检查
    max_bed_size = 256;
    if (total_x <= max_bed_size && total_y <= max_bed_size) {
        echo(str("  ✓ 兼容标准打印床 Compatible with standard print bed (", max_bed_size, "×", max_bed_size, "mm)"));
    } else {
        echo(str("  ⚠ 超出标准打印床 Exceeds standard print bed (", max_bed_size, "×", max_bed_size, "mm)"));
    }
    
    // 不规则排列的优势说明
    echo("不规则排列优势 Irregular Layout Advantages:");
    echo("  • 质数和某些合数的更优排列 Better arrangement for primes and some composites");
    echo("  • 更紧凑的长宽比 More compact aspect ratio");
    echo("  • 更好的打印床利用率 Better print bed utilization");
    
    echo("========================================================");
}

// 打印床兼容性检查函数
// Print bed compatibility check function
function check_bed_compatibility(total_x, total_y, bed_size = 256) = 
    assert(total_x > 0, "total_x must be > 0")
    assert(total_y > 0, "total_y must be > 0")
    assert(bed_size > 0, "bed_size must be > 0")
    
    total_x <= bed_size && total_y <= bed_size;

// 计算打印床利用率函数
// Calculate print bed utilization function
function calculate_bed_utilization(total_x, total_y, bed_size = 256) = 
    assert(total_x > 0, "total_x must be > 0")
    assert(total_y > 0, "total_y must be > 0")
    assert(bed_size > 0, "bed_size must be > 0")
    
    let(
        used_area = total_x * total_y,
        total_area = bed_size * bed_size,
        utilization = used_area / total_area * 100
    )
    min(utilization, 100); // 限制在100%以内 - Limit to 100%

// 计算参数 - Calculated Parameters

// 使用函数计算外壳尺寸 - Calculate exterior dimensions using functions
OuterDimensions = calculate_outer_dimensions(width, length, height, UnitSize, CLEARANCESize);
OuterWidth = OuterDimensions[0];
OuterLength = OuterDimensions[1];
OuterHeight = OuterDimensions[2];

// 使用函数计算内部空腔尺寸 - Calculate interior dimensions using functions
InnerDimensions = calculate_inner_dimensions(OuterDimensions, WallThickness);
InnerWidth = InnerDimensions[0];
InnerLength = InnerDimensions[1];
InnerHeight = InnerDimensions[2];

// 使用函数计算凸点位置 - Calculate stud positions using functions
StudPositions = calculate_stud_positions(width, length, UnitSize);

// 使用函数计算管道位置 - Calculate tube positions using functions
ActualTubeMargin = apply_clearance_adjustment(TubeMargin, CLEARANCESize, "half");
TubePositions = calculate_tube_positions(width, length, ActualTubeMargin);

// 管道相关计算 - Tube calculations
TubeHeight = calculate_tube_height(height, LayerSize);

// 间隙调整后的边距 - Clearance-adjusted margins
ActualStudMargin = apply_clearance_adjustment(StudMargin, CLEARANCESize, "half");

// 数量计算 - Count calculations
StudCount = calculate_stud_count(width, length);
TubeCount = calculate_tube_count(width, length, height);

// 参数验证和调试输出 - Parameter Validation & Debug Output

// 参数验证 - Parameter validation
assert(validate_parameters(width, length, height), 
       "错误 ERROR: width, length, height 必须大于0 - must be greater than 0");

// 额外的参数验证 - Additional parameter validation
assert(width > 0, "错误 ERROR: width 必须大于0 - width must be greater than 0");
assert(length > 0, "错误 ERROR: length 必须大于0 - length must be greater than 0"); 
assert(height > 0, "错误 ERROR: height 必须大于0 - height must be greater than 0");

// 壁厚验证 - Wall thickness validation
assert(InnerWidth > 0 && InnerLength > 0, 
       "错误 ERROR: 壁厚过大，导致内部空腔尺寸为负 - Wall thickness too large, causing negative inner dimensions");

// 间隙验证 - Clearance validation
assert(OuterWidth > 0 && OuterLength > 0, 
       "错误 ERROR: 间隙调整过大，导致外部尺寸为负 - Clearance adjustment too large, causing negative outer dimensions");

// 调试输出 - 显示计算的尺寸
echo("=== 乐高积木参数 LEGO Block Parameters ===");
echo(str("尺寸规格 Dimensions: ", width, "x", length, "x", height));
echo(str("外部尺寸 Outer Size: ", OuterWidth, "x", OuterLength, "x", OuterHeight, "mm"));
echo(str("内部空腔 Inner Cavity: ", InnerWidth, "x", InnerLength, "x", InnerHeight, "mm"));
echo(str("凸点数量 Stud Count: ", StudCount));
echo(str("凸点位置数量 Stud Position Count: ", len(StudPositions)));

echo(str("管道数量 Tube Count: ", TubeCount));
echo(str("管道位置数量 Tube Position Count: ", len(TubePositions)));
echo(str("管道高度 Tube Height: ", TubeHeight, "mm"));
echo(str("调整后管道边距 Adjusted Tube Margin: ", ActualTubeMargin, "mm"));

echo(str("调整后凸点边距 Adjusted Stud Margin: ", ActualStudMargin, "mm"));
echo(str("壁厚 Wall Thickness: ", WallThickness, "mm"));
echo(str("间隙调整 Clearance: ", CLEARANCESize, "mm"));

// 平铺网格计算和显示 - Tiling grid calculation and display (使用新的改进算法)
if (tile_units > 1) {
    // 使用新的最优布局计算
    OptimalLayout = calculate_optimal_layout(tile_units, width, length);
    LayoutType = OptimalLayout[0];
    LayoutData = OptimalLayout[1];
    
    // 计算总体尺寸
    TotalSize = LayoutType == "regular" ? 
        calculate_total_tiling_size(LayoutData[0], LayoutData[1], width, length) :
        calculate_irregular_total_size(LayoutData, width, length);
    
    // 计算长宽比
    AspectRatio = max(TotalSize[0], TotalSize[1]) / min(TotalSize[0], TotalSize[1]);
    
    // 计算积木位置
    BrickPositions = calculate_brick_positions_advanced(OptimalLayout, width, length, TileSpacing);
    
    // 验证位置计算结果
    validate_brick_positions(BrickPositions, tile_units);
    
    // 计算积木pitch
    BrickPitch = calculate_brick_pitch(width, length, TileSpacing);
    
    // 计算位置边界 - Calculate position bounds
    PositionBounds = calculate_position_bounds(BrickPositions, width, length);
    

    
    echo("=== 平铺配置 Tiling Configuration ===");
    echo(str("平铺积木数量 Tile Units: ", tile_units));
    if (LayoutType == "regular") {
        echo(str("网格排列 Grid Layout: ", LayoutData[0], "x", LayoutData[1]));
    } else {
        echo(str("不规则排列 Irregular Layout: ", LayoutData, " (每行积木数 bricks per row)"));
    }
    echo(str("单个积木尺寸 Single Brick Size: ", width, "x", length, " 单位 units"));
    echo(str("积木间距 Brick Spacing: ", TileSpacing, "mm"));
    echo(str("平铺总尺寸 Total Tiling Size: ", TotalSize[0], "x", TotalSize[1], "mm"));
    echo(str("长宽比 Aspect Ratio: ", AspectRatio, " (越接近1越好 closer to 1 is better)"));
    
    echo("=== 位置计算 Position Calculation ===");
    echo(str("积木Pitch X方向 Brick Pitch X: ", BrickPitch[0], "mm"));
    echo(str("积木Pitch Y方向 Brick Pitch Y: ", BrickPitch[1], "mm"));
    echo(str("位置数量 Position Count: ", len(BrickPositions)));

    echo(str("边界范围 Bounds: [", PositionBounds[0][0], ",", PositionBounds[0][1], "] 到 to [", 
             PositionBounds[1][0], ",", PositionBounds[1][1], "]mm"));
    
    // 显示前几个位置作为示例 - Display first few positions as examples
    echo("积木位置示例 Brick Position Examples:");
    for (i = [0 : min(4, len(BrickPositions)-1)]) {
        echo(str("积木 Brick ", i+1, ": [", BrickPositions[i][0], ", ", BrickPositions[i][1], ", ", BrickPositions[i][2], "]mm"));
    }
    if (len(BrickPositions) > 5) {
        echo(str("... (共 total ", len(BrickPositions), " 个位置 positions)"));
    }
    
    // 使用新的尺寸验证和警告系统 - Use new size validation and warning system
    if (LayoutType == "regular") {
        validate_tiling_size(TotalSize[0], TotalSize[1], LayoutData[0], LayoutData[1], 
                            tile_units, width, length);
    } else {
        validate_irregular_tiling_size(TotalSize[0], TotalSize[1], LayoutData, 
                                     tile_units, width, length);
    }
    
    // 计算打印床利用率 - Calculate print bed utilization
    BedUtilization = calculate_bed_utilization(TotalSize[0], TotalSize[1]);
    echo(str("打印床利用率 Print Bed Utilization: ", BedUtilization, "%"));
    
    // 打印床兼容性检查 - Print bed compatibility check
    BedCompatible = check_bed_compatibility(TotalSize[0], TotalSize[1]);
    echo(str("标准打印床兼容 Standard Bed Compatible: ", BedCompatible ? "是 Yes" : "否 No"));
    
    echo("=====================================");
}
echo("==========================================");

// 合理性警告 - Reasonableness warnings
if (width > 10 || length > 10) {
    echo("警告 WARNING: 大尺寸积木可能需要更长的打印时间 - Large blocks may require longer print time");
}
if (height > 10) {
    echo("警告 WARNING: 高积木可能需要支撑结构进行打印 - Tall blocks may require support structures for printing");
}
if (WallThickness < 1.2) {
    echo("警告 WARNING: 壁厚可能过薄，影响打印强度 - Wall thickness may be too thin, affecting print strength");
}
if (CLEARANCESize > 0.5) {
    echo("警告 WARNING: 间隙过大可能影响配合精度 - Large clearance may affect fit precision");
}



// 单个积木生成模块 - Single Brick Generation Module

/*
 * 单个乐高积木生成模块 - Single LEGO Brick Generation Module
 * 
 * 功能：生成单个LEGO积木，包含所有标准组件
 * Function: Generate single LEGO brick with all standard components
 * 
 * 参数 Parameters:
 * - brick_width: 积木宽度（单位数量）- Brick width in units
 * - brick_length: 积木长度（单位数量）- Brick length in units  
 * - brick_height: 积木高度（层数）- Brick height in layers
 * 
 * 组件 Components:
 * - 外壳薄壳结构 - Exterior shell structure
 * - 顶部凸点阵列 - Top studs array
 * - 底部管道结构 - Bottom tubes structure
 * 
 * 特性 Features:
 * - 完全兼容LEGO标准 - Fully LEGO compatible
 * - 3D打印优化 - 3D printing optimized
 * - 可重复调用 - Reusable and callable multiple times
 * - 无副作用 - No side effects
 */
module single_lego_brick(brick_width, brick_length, brick_height) {
    // 参数验证 - Parameter validation
    assert(brick_width > 0, "brick_width must be > 0");
    assert(brick_length > 0, "brick_length must be > 0");
    assert(brick_height > 0, "brick_height must be > 0");
    
    // 计算当前积木的尺寸参数 - Calculate current brick dimensions
    local_outer_dims = calculate_outer_dimensions(brick_width, brick_length, brick_height, UnitSize, CLEARANCESize);
    local_inner_dims = calculate_inner_dimensions(local_outer_dims, WallThickness);
    
    local_outer_width = local_outer_dims[0];
    local_outer_length = local_outer_dims[1];
    local_outer_height = local_outer_dims[2];
    
    local_inner_width = local_inner_dims[0];
    local_inner_length = local_inner_dims[1];
    local_inner_height = local_inner_dims[2];
    
    // 计算管道高度 - Calculate tube height
    local_tube_height = calculate_tube_height(brick_height, LayerSize);
    
    // 计算调整后的管道边距 - Calculate adjusted tube margin
    local_tube_margin = apply_clearance_adjustment(TubeMargin, CLEARANCESize, "half");
    
    // 主积木组装 - Main brick assembly
    union() {
        // 外壳薄壳结构 - Exterior shell structure
        single_brick_exterior_shell(local_outer_width, local_outer_length, local_outer_height,
                                   local_inner_width, local_inner_length, local_inner_height);
        
        // 顶部凸点阵列 - Top studs array
        single_brick_top_studs(brick_width, brick_length, local_outer_height);
        
        // 底部管道结构 - Bottom tubes structure
        single_brick_bottom_tubes(brick_width, brick_length, local_tube_height, local_tube_margin);
    }
}

// 单个积木的外壳结构模块 - Single brick exterior shell module
module single_brick_exterior_shell(outer_width, outer_length, outer_height,
                                   inner_width, inner_length, inner_height) {
    difference() {
        // 外部立方体几何体 - Outer cube geometry
        translate([0, 0, outer_height/2]) {
            cube([outer_width, outer_length, outer_height], center=true);
        }
        
        // 内部空腔几何体（考虑壁厚）- Inner cavity geometry (considering wall thickness)
        // 空腔从底部开始，顶面封闭，底面开放
        // Cavity starts from bottom, top face closed, bottom face open
        translate([0, 0, inner_height/2]) {
            cube([inner_width, inner_length, inner_height], center=true);
        }
    }
}

// 单个积木的顶部凸点阵列模块 - Single brick top studs array module
module single_brick_top_studs(brick_width, brick_length, outer_height) {
    // 使用循环生成brick_width × brick_length的凸点阵列
    // Use loops to generate brick_width × brick_length stud array
    for (i = [0:brick_width-1]) {
        for (j = [0:brick_length-1]) {
            // 计算凸点位置 - Calculate stud position
            stud_x = (i - (brick_width-1)/2) * UnitSize;
            stud_y = (j - (brick_length-1)/2) * UnitSize;
            stud_z = outer_height; // 凸点位于顶面 - Studs on top surface
            
            // 生成单个凸点 - Generate single stud
            translate([stud_x, stud_y, stud_z]) {
                single_stud();
            }
        }
    }
}

// 单个积木的底部管道阵列模块 - Single brick bottom tubes array module
module single_brick_bottom_tubes(brick_width, brick_length, tube_height, tube_margin) {
    // 只有当brick_width>1且brick_length>1时才生成管道 - Only generate tubes when brick_width>1 and brick_length>1
    if (brick_width > 1 && brick_length > 1) {
        // 使用循环生成管道阵列 - Use loops to generate tube array
        // 管道数量：(brick_width-1) × (brick_length-1) - Tube count: (brick_width-1) × (brick_length-1)
        for (i = [0:brick_width-2]) {
            for (j = [0:brick_length-2]) {
                // 计算管道位置 - Calculate tube position
                // 圆心距离基于tube_margin，考虑间隙调整 - Center distance based on tube_margin with clearance
                tube_x = (i - (brick_width-2)/2) * tube_margin;
                tube_y = (j - (brick_length-2)/2) * tube_margin;
                tube_z = 0; // 管道从底面开始 - Tubes start from bottom
                
                // 生成单个薄壳管道 - Generate single thin-wall tube
                translate([tube_x, tube_y, tube_z]) {
                    single_tube_with_height(tube_height);
                }
            }
        }
    }
}

// 带高度参数的单个薄壳管道模块 - Single thin-wall tube module with height parameter
module single_tube_with_height(tube_height) {
    // 使用difference()操作生成薄壳管道 - Use difference() to generate thin-wall tube
    // 外径圆柱减去内径圆柱 - Outer cylinder minus inner cylinder
    difference() {
        // 外径圆柱几何体 - Outer cylinder geometry
        cylinder(
            h = tube_height,                   // 管道高度 - Tube height
            d = TubeOuterDiameter,             // 外径 - Outer diameter
            center = false                     // 从底面开始 - Start from bottom
        );
        
        // 内径圆柱几何体（形成空腔）- Inner cylinder geometry (creates cavity)
        cylinder(
            h = tube_height + 0.1,             // 稍微高一点确保完全切除 - Slightly taller to ensure complete cut
            d = TubeInnerDiameter,             // 内径 - Inner diameter
            center = false                     // 从底面开始 - Start from bottom
        );
    }
}

// ========================================
// 主平铺渲染逻辑 - Main Tiling Rendering Logic
module generate_tiling() {
    assert(tile_units >= 1, "tile_units must be >= 1");
    assert(tile_units <= 25, "tile_units must be <= 25 (maximum 5x5 arrangement)");
    assert(width >= 1, "width must be >= 1");
    assert(length >= 1, "length must be >= 1");
    assert(height >= 1, "height must be >= 1");
    
    if (tile_units == 1) {
        echo("=== 单个积木模式 Single Brick Mode ===");
        echo(str("积木规格 Brick Spec: ", width, "×", length, "×", height, " 单位 units"));
        echo(str("积木尺寸 Brick Size: ", width * UnitSize, "×", length * UnitSize, "×", height * LayerSize, "mm"));
        echo("========================================");
        
        single_lego_brick(width, length, height);
        
    } else {
        echo("=== 平铺模式 Tiling Mode (改进版 Improved) ===");
        
        optimal_layout = calculate_optimal_layout(tile_units, width, length);
        layout_type = optimal_layout[0];
        layout_data = optimal_layout[1];
        
        echo(str("布局类型 Layout Type: ", layout_type));
        if (layout_type == "regular") {
            echo(str("规则网格 Regular Grid: ", layout_data[0], "×", layout_data[1]));

        } else {
            echo(str("不规则排列 Irregular Layout: ", layout_data, " (每行积木数 bricks per row)"));
            // 验证不规则排列的积木总数
            total_bricks_in_config = len([for (row = layout_data) for (i = [1:row]) i]);
            assert(total_bricks_in_config == tile_units, 
                   str("Irregular layout error: ", total_bricks_in_config, " ≠ ", tile_units));
        }
        
        // 2. 计算总体尺寸 - Calculate total dimensions
        total_size = layout_type == "regular" ? 
            calculate_total_tiling_size(layout_data[0], layout_data[1], width, length) :
            calculate_irregular_total_size(layout_data, width, length);
        total_x = total_size[0];
        total_y = total_size[1];
        
        // 3. 计算积木位置 - Calculate brick positions (支持不规则排列)
        brick_positions = calculate_brick_positions_advanced(optimal_layout, width, length, TileSpacing);
        
        // 验证位置计算结果 - Validate position calculation results
        validate_brick_positions(brick_positions, tile_units);
        
        // 4. 计算长宽比并显示优化效果 - Calculate aspect ratio and show optimization effect
        aspect_ratio = max(total_x, total_y) / min(total_x, total_y);
        echo(str("长宽比 Aspect Ratio: ", aspect_ratio, " (越接近1越好 closer to 1 is better)"));
        
        // 5. 集成尺寸验证和警告系统 - Integrate size validation and warning system
        if (layout_type == "regular") {
            validate_tiling_size(total_x, total_y, layout_data[0], layout_data[1], tile_units, width, length);
        } else {
            validate_irregular_tiling_size(total_x, total_y, layout_data, tile_units, width, length);
        }
        
        // 6. 性能警告 - Performance warning
        performance_warning(tile_units);
        
        // 7. 生成平铺积木阵列 - Generate tiling brick array
        echo("开始生成平铺积木 Starting tiling brick generation...");
        if (layout_type == "regular") {
            echo(str("网格配置 Grid configuration: ", layout_data[0], "×", layout_data[1], " = ", tile_units, " 积木 bricks"));
        } else {
            echo(str("不规则配置 Irregular configuration: ", layout_data, " = ", tile_units, " 积木 bricks"));
        }
        echo(str("积木间距 Brick spacing: ", TileSpacing, "mm (固定 fixed)"));
        echo(str("总体尺寸 Total dimensions: ", total_x, "×", total_y, "mm"));
        
        // 验证积木数量匹配 - Verify brick count matches
        assert(len(brick_positions) == tile_units, 
               str("Position count mismatch: ", len(brick_positions), " != ", tile_units));
        
        // 使用for循环和translate在计算位置上放置积木
        // Use for loop and translate to place bricks at calculated positions
        for (i = [0 : len(brick_positions)-1]) {
            translate(brick_positions[i]) {
                // 在每个计算位置生成单个积木 - Generate single brick at each calculated position
                // 确保所有积木使用相同的width、length、height参数 - Ensure all bricks use same width, length, height parameters
                single_lego_brick(width, length, height);
            }
        }
        
        echo(str("平铺生成完成 Tiling generation completed: ", len(brick_positions), " 个积木 bricks"));
        echo(str("所有积木规格一致 All bricks uniform spec: ", width, "×", length, "×", height, " 单位 units"));
        echo("========================================");
    }
}

// 主模型生成 - Main Model Generation

// 主模型组装 - Main model assembly
// 使用新的generate_tiling模块根据tile_units选择渲染模式 - Use new generate_tiling module to select rendering mode based on tile_units
generate_tiling();

// ========================================
// 模块定义 - Module Definitions
// ========================================

// ========================================
// 原有模块定义（向后兼容）- Original Module Definitions (Backward Compatibility)
// ========================================

// 外壳薄壳结构模块 - Exterior shell structure module
// 保持向后兼容，内部调用新的单个积木模块 - Maintain backward compatibility, internally calls new single brick module
module exterior_shell() {
    single_brick_exterior_shell(OuterWidth, OuterLength, OuterHeight,
                               InnerWidth, InnerLength, InnerHeight);
}

module top_studs() {
    single_brick_top_studs(width, length, OuterHeight);
}

module bottom_tubes() {
    single_brick_bottom_tubes(width, length, TubeHeight, ActualTubeMargin);
}

module single_stud() {
    cylinder(
        h = StudHeight,
        d = StudDiameter,
        center = false            // 从底面开始 - Start from bottom
    );
}

// 单个薄壳管道模块 - Single thin-wall tube module
// 保持向后兼容，内部调用带高度参数的版本 - Maintain backward compatibility, internally calls version with height parameter
module single_tube() {
    single_tube_with_height(TubeHeight);
}

// ========================================
// 使用示例 - Usage Examples
// ========================================

/*
 * 基本使用示例 - Basic Usage Examples
 * 
 * 单个积木 Single Brick:
 * width = 2; length = 4; height = 3; tile_units = 1;
 * 
 * 平铺积木 Tiling Bricks:
 * width = 2; length = 2; height = 3; tile_units = 9;  // 3×3排列
 * width = 16; length = 2; height = 3; tile_units = 4; // 智能排列
 * 
 * 详细使用说明请参考README.md文件
 * For detailed usage instructions, please refer to README.md
 */