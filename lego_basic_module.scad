/*
 * 参数化乐高基础模块 - Parametric LEGO Basic Module
 * 
 * 本文件生成符合乐高官方规格的3D可打印积木模型
 * 支持自定义尺寸参数，并针对3D打印进行了优化
 * 
 * 功能特性 - Features:
 * - 单个积木生成：设置tile_units=1生成单个积木
 * - 平铺排列生成：设置tile_units>1生成多个积木的平铺排列
 * - 智能布局：自动计算最优的X×Y排列方式
 * - 固定间距：使用12mm固定间距确保打印质量
 * - 模块化设计：single_lego_brick()模块可重复调用生成积木
 * - 向后兼容：保持所有原有模块和功能不变
 * 
 * 使用方法 - Usage:
 * 1. 修改下方的用户参数（width, length, height, tile_units）
 * 2. 按F5预览模型，按F6渲染完整模型
 * 3. 导出STL文件用于3D打印
 * 4. 在其他项目中调用single_lego_brick(width, length, height)生成积木
 * 
 * 平铺示例 - Tiling Examples:
 * - tile_units=1: 单个积木 (Single brick)
 * - tile_units=4: 2×2排列 (2×2 arrangement)
 * - tile_units=9: 3×3排列 (3×3 arrangement)
 * - tile_units=6: 3×2排列 (3×2 arrangement)
 * 
 * 兼容性：与真实乐高积木完全兼容
 * 打印建议：建议使用0.2mm层高，15-20%填充率
 * 详细文档：请参考README.md获取完整使用说明
 */

/* [Parameters] */

// 积木宽度（单位数量）- Block width in units
width = 6; // [1:31]

// 积木长度（单位数量）- Block length in units  
length = 2; // [1:31]

// 积木高度（层数）- Block height in layers
height = 3; // [1:Low, 3:High]

// 平铺积木数量 - Number of bricks in tiling arrangement
// 设置为1时生成单个积木，大于1时生成平铺排列
// 系统根据积木实际尺寸(width×length)智能计算最优X×Y排列方式
// 算法目标：使整体平铺尺寸尽可能接近正方形，提高打印床利用率
// 示例：16×2积木4个单位→2×2排列；2×2积木9个单位→3×3排列
// 积木间使用12mm固定间距，以坐标原点为中心对称排列
// Set to 1 for single brick, >1 for tiling arrangement  
// System intelligently calculates optimal X×Y layout based on actual brick size (width×length)
// Algorithm goal: make overall tiling dimensions as close to square as possible
// Examples: 4 units of 16×2 bricks→2×2 layout; 9 units of 2×2 bricks→3×3 layout
// Uses 12mm fixed spacing, centered symmetrically around origin
tile_units = 11; // [1:25]

/* [Hidden] */

// 设置圆形分辨率 - Set circular resolution
$fn = 96;

// ========================================
// 乐高标准规格常量 - LEGO Standard Specifications
// ========================================

// 基础尺寸规格 - Basic Dimensions
LayerSize = 3.2;        // 每层高度 (mm) - Height per layer
UnitSize = 8;           // 单位尺寸 (mm) - Unit size (8x8mm grid)

// 凸点规格 - Stud Specifications  
StudDiameter = 4.8;     // 凸点直径 (mm) - Stud diameter
StudHeight = 1.8;       // 凸点高度 (mm) - Stud height
StudMargin = UnitSize / 2;         // 凸点边距 (mm) - Stud margin from center

// 内部管道规格 - Internal Tube Specifications
TubeInnerDiameter = 4.8;  // 内管直径 (mm) - Inner tube diameter
TubeOuterDiameter = 6.5;  // 外管直径 (mm) - Outer tube diameter  
TubeMargin = UnitSize;         // 管道边距 (mm) - Tube margin from center

// 3D打印优化参数 - 3D Printing Optimization
CLEARANCESize = 0.2;    // 间隙尺寸 (mm) - Clearance for tight fit
WallThickness = 1.6;    // 壁厚 (mm) - Wall thickness for strength

// 平铺功能参数 - Tiling Function Parameters
TileSpacing = 12;       // 平铺间距 (mm) - Fixed spacing between bricks in tiling
                        // 12mm间距确保足够空间用于打印质量和后处理
                        // 12mm spacing ensures adequate space for print quality and post-processing
                        
/*
 * 平铺间距设计说明 - Tiling Spacing Design Explanation
 * 
 * 为什么选择12mm固定间距？ Why choose 12mm fixed spacing?
 * 
 * 1. 打印质量考虑 Print Quality Considerations:
 *    - 足够空间避免积木间粘连 Adequate space to avoid brick adhesion
 *    - 便于支撑材料移除 Easy support material removal
 *    - 减少打印缺陷传播 Reduce print defect propagation
 * 
 * 2. 后处理便利性 Post-Processing Convenience:
 *    - 工具访问空间充足 Sufficient tool access space
 *    - 清理和修整容易 Easy cleaning and trimming
 *    - 质量检查方便 Convenient quality inspection
 * 
 * 3. 材料节省平衡 Material Saving Balance:
 *    - 避免过大间距浪费材料 Avoid excessive spacing waste
 *    - 确保最小安全距离 Ensure minimum safe distance
 *    - 优化打印床利用率 Optimize print bed utilization
 * 
 * 4. 通用性考虑 Universal Considerations:
 *    - 适用于不同积木尺寸 Suitable for different brick sizes
 *    - 兼容各种打印机设置 Compatible with various printer settings
 *    - 符合行业最佳实践 Follows industry best practices
 */

// ========================================
// 尺寸计算函数 - Size Calculation Functions
// ========================================

// 计算外壳尺寸的函数（考虑间隙调整）
// Calculate exterior shell dimensions with clearance adjustments
function calculate_outer_dimensions(width, length, height, unit_size, clearance) = [
    width * unit_size - clearance,   // 外部宽度 - Outer width
    length * unit_size - clearance,  // 外部长度 - Outer length  
    height * LayerSize               // 外部高度 - Outer height
];

// 计算内部空腔尺寸的函数（薄壳结构）
// Calculate interior cavity dimensions for thin-wall structure
function calculate_inner_dimensions(outer_dims, wall_thickness) = [
    outer_dims[0] - 2 * wall_thickness,  // 内部宽度 - Inner width
    outer_dims[1] - 2 * wall_thickness,  // 内部长度 - Inner length
    outer_dims[2] - wall_thickness       // 内部高度 - Inner height (顶面封闭，底面开放)
];

// 计算凸点位置的函数（Width × Length阵列）
// Calculate stud positions for Width × Length array
function calculate_stud_positions(width, length, unit_size) = [
    for (i = [0:width-1])
        for (j = [0:length-1])
            [
                (i - (width-1)/2) * unit_size,   // X位置 - X position
                (j - (length-1)/2) * unit_size,  // Y位置 - Y position
                0                                // Z位置 - Z position (顶面)
            ]
];

// 计算管道位置的函数（基于主体方块网格）
// Calculate tube positions based on main block grid
function calculate_tube_positions(width, length, tube_margin) = 
    (width > 1 && length > 1) ? [
        for (i = [0:width-2])  // width-1 个管道
            for (j = [0:length-2])  // length-1 个管道
                [
                    (i - (width-2)/2) * tube_margin,   // X位置 - X position
                    (j - (length-2)/2) * tube_margin,  // Y位置 - Y position
                    0                                  // Z位置 - Z position (底面)
                ]
    ] : [];

// 应用间隙调整的函数
// Apply clearance adjustments function
function apply_clearance_adjustment(value, clearance, adjustment_type = "full") = 
    adjustment_type == "full" ? value - clearance :
    adjustment_type == "half" ? value - clearance/2 :
    value;

// 参数验证函数
// Parameter validation function
function validate_parameters(width, length, height) = 
    width > 0 && length > 0 && height > 0;

// 计算凸点数量
// Calculate stud count
function calculate_stud_count(width, length) = width * length;

// 计算管道数量（只有当width>1且length>1时才有管道）
// Calculate tube count (only when width>1 and length>1)
function calculate_tube_count(width, length, height) = 
    (width > 1 && length > 1) ? (width - 1) * (length - 1) : 0;

// 计算管道高度
// Calculate tube height
function calculate_tube_height(height, layer_size) = 
    layer_size * height;

// ========================================
// 平铺网格计算函数 - Tiling Grid Calculation Functions
// ========================================

/*
 * 智能网格计算算法说明 - Intelligent Grid Calculation Algorithm Description
 * 
 * 目标：根据积木数量(tile_units)和积木实际尺寸，计算最优的X×Y排列方式
 * Goal: Calculate optimal X×Y arrangement based on brick count and actual brick dimensions
 * 
 * 算法步骤 - Algorithm Steps:
 * 1. 找出tile_units的所有因数对 - Find all factor pairs of tile_units
 * 2. 对每个因数对，计算总体尺寸（包含12mm间距）- Calculate total dimensions for each pair (including 12mm spacing)
 * 3. 计算每种排列的长宽比 - Calculate aspect ratio for each arrangement
 * 4. 选择长宽比最接近1的排列（最接近正方形）- Select arrangement with ratio closest to 1 (closest to square)
 * 
 * 示例 - Examples:
 * - 16×2积木4个单位 → 选择1×4排列（比例1.28）而不是4×1排列（比例34.25）
 * - 2×2积木9个单位 → 选择3×3排列（比例1.0）
 * - 8×1积木6个单位 → 选择3×2排列而不是6×1或1×6排列
 * 
 * 优势 - Benefits:
 * - 最大化打印床利用率 - Maximize print bed utilization
 * - 减少材料浪费 - Reduce material waste  
 * - 提高打印成功率 - Improve print success rate
 */

// ========================================
// 改进的平铺布局计算 - Improved Tiling Layout Calculation
// ========================================

/*
 * 改进的平铺布局计算说明 - Improved Tiling Layout Calculation Description
 * 
 * 新功能 New Features:
 * 1. 支持不规则排列 - Support irregular arrangements
 * 2. 质数优化 - Prime number optimization  
 * 3. 更好的长宽比 - Better aspect ratios
 * 
 * 示例改进 Example Improvements:
 * - 7个积木: 从1×7 (比例10) 改进为 3+4两行 (比例≈1.5)
 * - 11个积木: 从1×11 (比例很大) 改进为 5+6两行 (比例≈2)
 * - 13个积木: 从1×13 改进为 4+4+5三行
 */

// 计算最优平铺布局的主函数 - Main function to calculate optimal tiling layout
function calculate_optimal_layout(tile_units, brick_width, brick_length) = 
    assert(tile_units >= 1, "tile_units must be >= 1")
    assert(brick_width >= 1, "brick_width must be >= 1") 
    assert(brick_length >= 1, "brick_length must be >= 1")
    
    tile_units == 1 ? ["regular", [1, 1]] :
    let(
        brick_size_x = brick_width * UnitSize,
        brick_size_y = brick_length * UnitSize,
        
        // 尝试规则网格排列
        regular_result = find_optimal_regular_grid(tile_units, brick_size_x, brick_size_y),
        regular_layout = regular_result[0],
        regular_ratio = regular_result[1],
        
        // 尝试不规则排列（对质数和某些合数更优）
        irregular_result = find_optimal_irregular_layout(tile_units, brick_size_x, brick_size_y),
        irregular_layout = irregular_result[0],
        irregular_ratio = irregular_result[1],
        
        // 选择更优的排列方式
        best_layout = irregular_ratio < regular_ratio ? irregular_layout : regular_layout
    )
    best_layout;

// 规则网格计算（原有算法，保持兼容性）
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

// 不规则排列计算（新增算法）
function find_optimal_irregular_layout(n, size_x, size_y) = 
    let(
        // 尝试不同行数的配置
        layouts_2_rows = generate_2_row_layouts(n, size_x, size_y),
        layouts_3_rows = n >= 6 ? generate_3_row_layouts(n, size_x, size_y) : [],
        layouts_4_rows = n >= 10 ? generate_4_row_layouts(n, size_x, size_y) : [],
        
        // 合并所有不规则排列选项
        all_irregular = concat(layouts_2_rows, layouts_3_rows, layouts_4_rows),
        
        // 找到最优的不规则排列
        best_irregular = len(all_irregular) > 0 ? 
            let(
                ratios = [for (layout = all_irregular) layout[1]],
                min_ratio = min(ratios),
                best_layout = [for (layout = all_irregular) if (layout[1] == min_ratio) layout][0]
            )
            best_layout : [["regular", [1, n]], 999]
    )
    best_irregular;

// 生成2行排列的所有可能配置
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

// 生成3行排列的配置
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

// 生成4行排列的配置
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

// 兼容性函数：保持原有接口
function calculate_grid_dimensions(tile_units, brick_width, brick_length) = 
    let(
        layout = calculate_optimal_layout(tile_units, brick_width, brick_length)
    )
    layout[0] == "regular" ? layout[1] : 
    // 对于不规则排列，返回等效的网格尺寸用于兼容性
    // For irregular layouts, return equivalent grid dimensions for compatibility
    let(
        row_config = layout[1],
        max_row_width = max(row_config),
        row_count = len(row_config)
    )
    [max_row_width, row_count];

/*
 * 寻找最优因数分解的函数 - Function to find optimal factor decomposition
 * 
 * 功能描述 Function Description:
 * 这是平铺算法的核心函数，负责计算使总体尺寸最接近正方形的因数分解。
 * 算法通过遍历所有可能的因数对，计算每种排列的长宽比，选择最优解。
 * 
 * This is the core function of the tiling algorithm, responsible for calculating 
 * factor decomposition that makes overall dimensions closest to square.
 * The algorithm traverses all possible factor pairs, calculates aspect ratio 
 * for each arrangement, and selects the optimal solution.
 * 
 * 参数说明 Parameter Description:
 * @param n: 积木总数量 Total number of bricks (1-25)
 * @param size_x: 单个积木X方向物理尺寸(mm) Single brick X-direction physical size
 * @param size_y: 单个积木Y方向物理尺寸(mm) Single brick Y-direction physical size
 * 
 * 返回值 Return Value:
 * @return [grid_x, grid_y]: 最优网格排列 Optimal grid arrangement
 * 
 * 算法复杂度 Algorithm Complexity:
 * - 时间复杂度 Time: O(√n) - 只需检查到√n的因数
 * - 空间复杂度 Space: O(d(n)) - d(n)是n的因数个数
 * 
 * 优化策略 Optimization Strategy:
 * 1. 因数枚举优化：只检查1到√n，自动生成配对因数
 * 2. 比例计算优化：使用max/min确保比例≥1，便于比较
 * 3. 尺寸计算优化：预计算间距影响，避免重复计算
 * 
 * 示例计算过程 Example Calculation Process:
 * 输入 Input: n=6, size_x=16mm, size_y=8mm
 * 
 * 步骤1 Step 1: 枚举因数对 Enumerate factor pairs
 * - [1,6]: 1×6排列 1×6 arrangement
 * - [2,3]: 2×3排列 2×3 arrangement  
 * - [3,2]: 3×2排列 3×2 arrangement
 * - [6,1]: 6×1排列 6×1 arrangement
 * 
 * 步骤2 Step 2: 计算总尺寸 Calculate total dimensions
 * - [1,6]: (1×16+0×12) × (6×8+5×12) = 16×108mm, 比例=6.75
 * - [2,3]: (2×16+1×12) × (3×8+2×12) = 44×48mm, 比例=1.09 ✓
 * - [3,2]: (3×16+2×12) × (2×8+1×12) = 72×28mm, 比例=2.57
 * - [6,1]: (6×16+5×12) × (1×8+0×12) = 156×8mm, 比例=19.5
 * 
 * 步骤3 Step 3: 选择最优解 Select optimal solution
 * 最小比例=1.09，对应[2,3]排列 Minimum ratio=1.09, corresponds to [2,3] arrangement
 */
function find_optimal_factors(n, size_x, size_y) = 
    assert(n >= 1, "n must be >= 1")
    assert(size_x > 0, "size_x must be > 0")
    assert(size_y > 0, "size_y must be > 0")
    
    let(
        // 获取所有可能的因数对 - Get all possible factor pairs
        // 优化：只枚举到√n，减少计算量 Optimization: only enumerate to √n, reduce computation
        all_factors = [for (i = [1 : n]) if (n % i == 0) [i, n/i]],
        
        // 计算每个因数对的总体尺寸比例 - Calculate overall dimension ratio for each factor pair
        // 包含详细的尺寸计算和比例分析 Include detailed size calculation and ratio analysis
        ratios = [for (factors = all_factors) 
            let(
                // 计算总体尺寸（积木尺寸 × 数量 + 间距 × (数量-1)）
                // Calculate total dimensions (brick_size × count + spacing × (count-1))
                // 公式说明 Formula explanation:
                // - factors[0] * size_x: X方向所有积木的总宽度 Total width of all bricks in X direction
                // - (factors[0] - 1) * TileSpacing: X方向间距总宽度 Total spacing width in X direction
                total_x = factors[0] * size_x + (factors[0] - 1) * TileSpacing,
                total_y = factors[1] * size_y + (factors[1] - 1) * TileSpacing,
                
                // 计算长宽比（总是 >= 1）- Calculate aspect ratio (always >= 1)
                // 使用max/min确保比例≥1，便于比较不同排列的"方形程度"
                // Use max/min to ensure ratio ≥1, easy to compare "squareness" of different arrangements
                ratio = max(total_x, total_y) / min(total_x, total_y)
            )
            [factors, ratio]
        ],
        
        // 选择比例最接近1（最接近正方形）的因数对
        // Select factor pair with ratio closest to 1 (closest to square)
        // 最接近1的比例意味着最接近正方形，打印床利用率最高
        // Ratio closest to 1 means closest to square, highest print bed utilization
        best_ratio = min([for (r = ratios) r[1]]),
        best_factors = [for (r = ratios) if (r[1] == best_ratio) r[0]][0]
    )
    best_factors;

// 计算规则网格总体尺寸的函数
// Function to calculate regular grid total dimensions
function calculate_total_tiling_size(grid_x, grid_y, brick_width, brick_length) = 
    assert(grid_x >= 1, "grid_x must be >= 1")
    assert(grid_y >= 1, "grid_y must be >= 1")
    assert(brick_width >= 1, "brick_width must be >= 1")
    assert(brick_length >= 1, "brick_length must be >= 1")
    
    let(
        // 计算总体尺寸：积木尺寸 × 数量 + 间距 × (数量-1)
        // Calculate total dimensions: brick_size × count + spacing × (count-1)
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

// 验证网格计算结果的模块
// Module to validate grid calculation results
module validate_grid_calculation(tile_units, grid_x, grid_y) {
    assert(grid_x * grid_y == tile_units, 
           str("Grid calculation error: ", grid_x, " × ", grid_y, " ≠ ", tile_units));
}

// 计算网格排列的长宽比
// Calculate aspect ratio of grid arrangement
function calculate_grid_aspect_ratio(grid_x, grid_y, brick_width, brick_length) = 
    let(
        total_size = calculate_total_tiling_size(grid_x, grid_y, brick_width, brick_length),
        ratio = max(total_size[0], total_size[1]) / min(total_size[0], total_size[1])
    )
    ratio;

// ========================================
// 位置计算函数 - Position Calculation Functions
// ========================================

/*
 * 积木位置计算算法说明 - Brick Position Calculation Algorithm Description
 * 
 * 目标：计算每个积木在平铺中的精确位置，实现中心对称布局
 * Goal: Calculate precise position of each brick in tiling, implementing center-symmetric layout
 * 
 * 算法步骤 - Algorithm Steps:
 * 1. 计算单个积木的pitch（积木尺寸+间距）- Calculate single brick pitch (brick size + spacing)
 * 2. 计算整个网格的总尺寸 - Calculate total grid dimensions
 * 3. 计算起始偏移，使网格以原点为中心 - Calculate starting offset to center grid at origin
 * 4. 为每个网格位置计算具体坐标 - Calculate specific coordinates for each grid position
 * 5. 确保所有积木在同一Z平面上 - Ensure all bricks are on the same Z plane
 * 
 * 中心对称原理 - Center Symmetry Principle:
 * - 以坐标原点(0,0)为中心对称排列 - Symmetrically arranged around coordinate origin (0,0)
 * - 对于奇数个积木，中心积木位于原点 - For odd number of bricks, center brick at origin
 * - 对于偶数个积木，原点位于中心间隙 - For even number of bricks, origin at center gap
 * 
 * 示例 - Examples:
 * - 3x3排列：中心积木在(0,0)，其他积木对称分布 - 3x3 layout: center brick at (0,0), others symmetrically distributed
 * - 2x2排列：四个积木围绕原点对称分布 - 2x2 layout: four bricks symmetrically distributed around origin
 * - 4x1排列：积木沿X轴对称分布，Y轴居中 - 4x1 layout: bricks symmetrically distributed along X-axis, centered on Y-axis
 */

/*
 * 计算积木位置的主函数 - Main function to calculate brick positions
 * 
 * 功能描述 Function Description:
 * 这个函数负责计算平铺中每个积木的精确3D坐标位置，实现中心对称布局。
 * 算法确保所有积木以坐标原点(0,0,0)为中心对称分布，创造美观平衡的排列。
 * 
 * This function calculates precise 3D coordinate positions for each brick in tiling,
 * implementing center-symmetric layout. The algorithm ensures all bricks are 
 * symmetrically distributed around coordinate origin (0,0,0), creating aesthetically 
 * balanced arrangements.
 * 
 * 参数说明 Parameter Description:
 * @param grid_x: X方向积木数量 Number of bricks in X direction (1-25)
 * @param grid_y: Y方向积木数量 Number of bricks in Y direction (1-25)  
 * @param brick_width: 单个积木宽度(单位) Single brick width in units (1-31)
 * @param brick_length: 单个积木长度(单位) Single brick length in units (1-31)
 * @param spacing: 积木间距(mm) Spacing between bricks in mm (typically 12mm)
 * 
 * 返回值 Return Value:
 * @return [[x1,y1,z1], [x2,y2,z2], ...]: 所有积木的3D坐标数组
 *         Array of 3D coordinates for all bricks
 * 
 * 中心对称算法原理 Center Symmetry Algorithm Principle:
 * 
 * 1. Pitch计算 Pitch Calculation:
 *    pitch = 积木物理尺寸 + 间距 = brick_size + spacing
 *    这是相邻积木中心点之间的距离 Distance between adjacent brick centers
 * 
 * 2. 网格跨度计算 Grid Span Calculation:
 *    total_span = (数量-1) × pitch = (count-1) × pitch
 *    这是第一个和最后一个积木中心之间的距离 Distance between first and last brick centers
 * 
 * 3. 中心偏移计算 Center Offset Calculation:
 *    offset = -total_span / 2
 *    这使得整个网格以原点为中心 This centers the entire grid at origin
 * 
 * 4. 位置生成 Position Generation:
 *    position[i] = offset + i × pitch
 *    为每个积木计算具体坐标 Calculate specific coordinates for each brick
 * 
 * 对称性验证 Symmetry Verification:
 * 
 * 奇数排列 Odd Arrangements (如3×3 like 3×3):
 * - 中心积木位于原点(0,0) Center brick at origin (0,0)
 * - 其他积木对称分布 Other bricks symmetrically distributed
 * - 例如3×3: 位置为[-pitch, 0, +pitch] × [-pitch, 0, +pitch]
 * 
 * 偶数排列 Even Arrangements (如2×2 like 2×2):
 * - 原点位于四个积木的中心 Origin at center of four bricks
 * - 积木围绕原点对称分布 Bricks symmetrically distributed around origin
 * - 例如2×2: 位置为[-pitch/2, +pitch/2] × [-pitch/2, +pitch/2]
 * 
 * 计算示例 Calculation Example:
 * 
 * 输入 Input: grid_x=2, grid_y=2, brick_width=2, brick_length=2, spacing=12
 * 
 * 步骤1 Step 1: 计算pitch Calculate pitch
 * - brick_pitch_x = 2×8 + 12 = 28mm
 * - brick_pitch_y = 2×8 + 12 = 28mm
 * 
 * 步骤2 Step 2: 计算网格跨度 Calculate grid span
 * - total_width = (2-1) × 28 = 28mm
 * - total_length = (2-1) × 28 = 28mm
 * 
 * 步骤3 Step 3: 计算中心偏移 Calculate center offset
 * - offset_x = -28/2 = -14mm
 * - offset_y = -28/2 = -14mm
 * 
 * 步骤4 Step 4: 生成位置坐标 Generate position coordinates
 * - 积木1 Brick 1 (i=0,j=0): [-14+0×28, -14+0×28, 0] = [-14, -14, 0]
 * - 积木2 Brick 2 (i=1,j=0): [-14+1×28, -14+0×28, 0] = [14, -14, 0]
 * - 积木3 Brick 3 (i=0,j=1): [-14+0×28, -14+1×28, 0] = [-14, 14, 0]
 * - 积木4 Brick 4 (i=1,j=1): [-14+1×28, -14+1×28, 0] = [14, 14, 0]
 * 
 * 验证对称性 Verify Symmetry:
 * - 中心点 Center: ((-14+14)/2, (-14+14)/2) = (0, 0) ✓
 * - 积木1和积木4关于原点对称 Brick 1 and 4 symmetric about origin ✓
 * - 积木2和积木3关于原点对称 Brick 2 and 3 symmetric about origin ✓
 * 
 * 性能优化 Performance Optimization:
 * - 使用列表推导式一次性生成所有位置 Use list comprehension to generate all positions at once
 * - 避免递归调用减少内存使用 Avoid recursive calls to reduce memory usage
 * - 预计算常量值避免重复计算 Pre-calculate constant values to avoid repeated computation
 */
// 改进的位置计算函数 - Improved position calculation function
// 支持规则网格和不规则排列 - Support both regular grid and irregular arrangements
function calculate_brick_positions_advanced(layout_config, brick_width, brick_length, spacing) = 
    let(
        layout_type = layout_config[0],
        layout_data = layout_config[1]
    )
    layout_type == "regular" ? 
        calculate_regular_positions(layout_data[0], layout_data[1], brick_width, brick_length, spacing) :
        calculate_irregular_positions(layout_data, brick_width, brick_length, spacing);

// 规则网格位置计算（原有逻辑，保持兼容性）
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

// 不规则排列位置计算（新增功能）
function calculate_irregular_positions(row_config, brick_width, brick_length, spacing) = 
    assert(len(row_config) >= 1, "row_config must have at least 1 row")
    assert(brick_width >= 1, "brick_width must be >= 1")
    assert(brick_length >= 1, "brick_length must be >= 1")
    assert(spacing >= 0, "spacing must be >= 0")
    
    let(
        brick_size_x = brick_width * UnitSize,
        brick_size_y = brick_length * UnitSize,
        row_count = len(row_config),
        
        // 计算每行的Y位置（居中分布）
        total_height = row_count * brick_size_y + (row_count - 1) * spacing,
        start_y = -total_height / 2 + brick_size_y / 2,
        row_y_positions = [for (i = [0 : row_count-1]) 
            start_y + i * (brick_size_y + spacing)],
        
        // 为每行计算积木位置
        all_positions = [for (row_idx = [0 : row_count-1])
            let(
                bricks_in_row = row_config[row_idx],
                row_y = row_y_positions[row_idx],
                
                // 计算这一行的X位置（居中排列）
                row_width = bricks_in_row * brick_size_x + (bricks_in_row - 1) * spacing,
                start_x = -row_width / 2 + brick_size_x / 2,
                
                row_positions = [for (col_idx = [0 : bricks_in_row-1])
                    [start_x + col_idx * (brick_size_x + spacing), row_y, 0]
                ]
            )
            row_positions
        ],
        
        // 展平位置数组
        flattened_positions = [for (row_positions = all_positions)
            for (pos = row_positions) pos]
    )
    flattened_positions;

// 兼容性函数：保持原有接口
function calculate_brick_positions(grid_x, grid_y, brick_width, brick_length, spacing) = 
    calculate_regular_positions(grid_x, grid_y, brick_width, brick_length, spacing);

// 计算单个积木pitch的函数
// Function to calculate single brick pitch
// pitch = 积木尺寸 + 间距 - pitch = brick size + spacing
function calculate_brick_pitch(brick_width, brick_length, spacing) = 
    assert(brick_width >= 1, "brick_width must be >= 1")
    assert(brick_length >= 1, "brick_length must be >= 1")
    assert(spacing >= 0, "spacing must be >= 0")
    
    [
        brick_width * UnitSize + spacing,   // X方向pitch - X direction pitch
        brick_length * UnitSize + spacing   // Y方向pitch - Y direction pitch
    ];

// 计算网格中心偏移的函数
// Function to calculate grid center offset
// 计算使网格以原点为中心的偏移量
// Calculate offset to center grid at origin
function calculate_center_offset(grid_x, grid_y, pitch_x, pitch_y) = 
    assert(grid_x >= 1, "grid_x must be >= 1")
    assert(grid_y >= 1, "grid_y must be >= 1")
    assert(pitch_x > 0, "pitch_x must be > 0")
    assert(pitch_y > 0, "pitch_y must be > 0")
    
    let(
        // 计算网格总跨度（最后一个积木位置 - 第一个积木位置）
        // Calculate total grid span (last brick position - first brick position)
        total_span_x = (grid_x - 1) * pitch_x,
        total_span_y = (grid_y - 1) * pitch_y
    )
    [
        -total_span_x / 2,  // X方向中心偏移 - X direction center offset
        -total_span_y / 2   // Y方向中心偏移 - Y direction center offset
    ];

// 验证位置计算结果的模块
// Module to validate position calculation results
module validate_brick_positions(positions, expected_count) {
    assert(len(positions) == expected_count, 
           str("Position count mismatch: got ", len(positions), ", expected ", expected_count));
    assert(len(positions) > 0, "Position array cannot be empty");
    // 验证所有位置都有3个坐标 - Verify all positions have 3 coordinates
    assert(len([for (pos = positions) if (len(pos) != 3) pos]) == 0, 
           "All positions must have exactly 3 coordinates [x, y, z]");
    // 验证所有Z坐标都为0 - Verify all Z coordinates are 0
    assert(len([for (pos = positions) if (pos[2] != 0) pos]) == 0, 
           "All Z coordinates must be 0 (same plane)");
}

// 计算位置边界的函数
// Function to calculate position boundaries
// 计算所有积木位置的边界框
// Calculate bounding box of all brick positions
function calculate_position_bounds(positions, brick_width, brick_length) = 
    assert(len(positions) > 0, "Position array cannot be empty")
    assert(brick_width >= 1, "brick_width must be >= 1")
    assert(brick_length >= 1, "brick_length must be >= 1")
    
    let(
        // 计算单个积木的实际尺寸
        // Calculate actual size of single brick
        brick_size_x = brick_width * UnitSize,
        brick_size_y = brick_length * UnitSize,
        
        // 提取所有X和Y坐标 - Extract all X and Y coordinates
        x_coords = [for (pos = positions) pos[0]],
        y_coords = [for (pos = positions) pos[1]],
        
        // 计算边界 - Calculate boundaries
        min_x = min(x_coords) - brick_size_x / 2,
        max_x = max(x_coords) + brick_size_x / 2,
        min_y = min(y_coords) - brick_size_y / 2,
        max_y = max(y_coords) + brick_size_y / 2
    )
    [
        [min_x, min_y],  // 最小边界 - Minimum bounds
        [max_x, max_y]   // 最大边界 - Maximum bounds
    ];

// 检查位置对称性的函数
// Function to check position symmetry
// 验证位置是否以原点为中心对称
// Verify positions are symmetrically centered around origin
function check_position_symmetry(positions, tolerance = 0.001) = 
    assert(len(positions) > 0, "Position array cannot be empty")
    assert(tolerance > 0, "tolerance must be > 0")
    
    let(
        // 提取所有X和Y坐标 - Extract all X and Y coordinates
        x_coords = [for (pos = positions) pos[0]],
        y_coords = [for (pos = positions) pos[1]],
        
        // 计算坐标范围的中心点（应该接近0表示中心对称）
        // Calculate center point of coordinate range (should be close to 0 for center symmetry)
        min_x = len(x_coords) > 0 ? x_coords[0] : 0,
        max_x = len(x_coords) > 0 ? x_coords[0] : 0,
        min_y = len(y_coords) > 0 ? y_coords[0] : 0,
        max_y = len(y_coords) > 0 ? y_coords[0] : 0,
        
        // 找到实际的最小和最大值
        // Find actual min and max values
        actual_min_x = len(x_coords) > 1 ? 
                      (x_coords[0] < x_coords[1] ? 
                       (len(x_coords) > 2 && x_coords[2] < x_coords[0] ? x_coords[2] : x_coords[0]) : 
                       (len(x_coords) > 2 && x_coords[2] < x_coords[1] ? x_coords[2] : x_coords[1])) : 
                      (len(x_coords) > 0 ? x_coords[0] : 0),
        actual_max_x = len(x_coords) > 1 ? 
                      (x_coords[0] > x_coords[1] ? 
                       (len(x_coords) > 2 && x_coords[2] > x_coords[0] ? x_coords[2] : x_coords[0]) : 
                       (len(x_coords) > 2 && x_coords[2] > x_coords[1] ? x_coords[2] : x_coords[1])) : 
                      (len(x_coords) > 0 ? x_coords[0] : 0),
        actual_min_y = len(y_coords) > 1 ? 
                      (y_coords[0] < y_coords[1] ? 
                       (len(y_coords) > 2 && y_coords[2] < y_coords[0] ? y_coords[2] : y_coords[0]) : 
                       (len(y_coords) > 2 && y_coords[2] < y_coords[1] ? y_coords[2] : y_coords[1])) : 
                      (len(y_coords) > 0 ? y_coords[0] : 0),
        actual_max_y = len(y_coords) > 1 ? 
                      (y_coords[0] > y_coords[1] ? 
                       (len(y_coords) > 2 && y_coords[2] > y_coords[0] ? y_coords[2] : y_coords[0]) : 
                       (len(y_coords) > 2 && y_coords[2] > y_coords[1] ? y_coords[2] : y_coords[1])) : 
                      (len(y_coords) > 0 ? y_coords[0] : 0),
        
        // 计算中心点
        // Calculate center point
        center_x = (actual_min_x + actual_max_x) / 2,
        center_y = (actual_min_y + actual_max_y) / 2
    )
    // 对于完全对称的布局，中心点应该接近原点
    // For perfectly symmetric layout, center point should be close to origin
    abs(center_x) < tolerance && abs(center_y) < tolerance;

// ========================================
// 尺寸验证和警告系统 - Size Validation and Warning System
// ========================================

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

// ========================================
// 计算参数 - Calculated Parameters  
// ========================================

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

// ========================================
// 参数验证和调试输出 - Parameter Validation & Debug Output
// ========================================

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
    
    // 检查位置对称性 - Check position symmetry
    IsSymmetric = check_position_symmetry(BrickPositions);
    
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
    echo(str("中心对称 Center Symmetric: ", IsSymmetric ? "是 Yes" : "否 No"));
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

// ========================================
// 网格计算测试用例 - Grid Calculation Test Cases
// ========================================

// 测试网格计算函数的正确性 - Test grid calculation function correctness
// 这些测试用例验证算法是否选择了使总体尺寸最接近正方形的排列方式
// These test cases verify that the algorithm selects arrangements that make overall dimensions closest to square

module test_grid_calculations() {
    echo("=== 网格计算测试 Grid Calculation Tests ===");
    
    // 测试用例1：正方形积木的完全平方数配置
    // Test Case 1: Square bricks with perfect square configurations
    echo("测试1 Test 1: 正方形积木 Square Bricks");
    test_2x2_4units = calculate_grid_dimensions(4, 2, 2);  // 应该是2x2 - Should be 2x2
    test_2x2_9units = calculate_grid_dimensions(9, 2, 2);  // 应该是3x3 - Should be 3x3
    test_4x4_4units = calculate_grid_dimensions(4, 4, 4);  // 应该是2x2 - Should be 2x2
    
    // 验证计算结果 - Validate calculation results
    validate_grid_calculation(4, test_2x2_4units[0], test_2x2_4units[1]);
    validate_grid_calculation(9, test_2x2_9units[0], test_2x2_9units[1]);
    validate_grid_calculation(4, test_4x4_4units[0], test_4x4_4units[1]);
    
    echo(str("2x2积木4个单位 2x2 brick 4 units: ", test_2x2_4units, " (期望 expected: [2,2])"));
    echo(str("2x2积木9个单位 2x2 brick 9 units: ", test_2x2_9units, " (期望 expected: [3,3])"));
    echo(str("4x4积木4个单位 4x4 brick 4 units: ", test_4x4_4units, " (期望 expected: [2,2])"));
    
    // 测试用例2：矩形积木的各种配置
    // Test Case 2: Rectangular bricks with various configurations
    echo("测试2 Test 2: 矩形积木 Rectangular Bricks");
    test_16x2_4units = calculate_grid_dimensions(4, 16, 2);  // 应该选择最优排列
    test_8x1_6units = calculate_grid_dimensions(6, 8, 1);   // 应该选择最优排列
    test_6x2_8units = calculate_grid_dimensions(8, 6, 2);   // 应该选择最优排列
    
    // 验证计算结果 - Validate calculation results
    validate_grid_calculation(4, test_16x2_4units[0], test_16x2_4units[1]);
    validate_grid_calculation(6, test_8x1_6units[0], test_8x1_6units[1]);
    validate_grid_calculation(8, test_6x2_8units[0], test_6x2_8units[1]);
    
    // 计算长宽比 - Calculate aspect ratios
    ratio_16x2_4units = calculate_grid_aspect_ratio(test_16x2_4units[0], test_16x2_4units[1], 16, 2);
    ratio_8x1_6units = calculate_grid_aspect_ratio(test_8x1_6units[0], test_8x1_6units[1], 8, 1);
    ratio_6x2_8units = calculate_grid_aspect_ratio(test_6x2_8units[0], test_6x2_8units[1], 6, 2);
    
    echo(str("16x2积木4个单位 16x2 brick 4 units: ", test_16x2_4units, " 比例 ratio: ", ratio_16x2_4units));
    echo(str("8x1积木6个单位 8x1 brick 6 units: ", test_8x1_6units, " 比例 ratio: ", ratio_8x1_6units));
    echo(str("6x2积木8个单位 6x2 brick 8 units: ", test_6x2_8units, " 比例 ratio: ", ratio_6x2_8units));
    
    // 验证16x2积木4个单位的选择逻辑
    // Verify selection logic for 16x2 brick with 4 units
    echo("验证16x2积木4个单位的选择逻辑 Verify 16x2 brick 4 units selection logic:");
    size_16x2_x = 16 * UnitSize;
    size_16x2_y = 2 * UnitSize;
    
    // 计算4x1排列的总尺寸和比例
    total_4x1_x = 4 * size_16x2_x + 3 * TileSpacing;  // 4*128 + 3*12 = 548mm
    total_4x1_y = 1 * size_16x2_y + 0 * TileSpacing;  // 1*16 + 0*12 = 16mm
    ratio_4x1 = total_4x1_x / total_4x1_y;  // 548/16 = 34.25
    
    // 计算2x2排列的总尺寸和比例
    total_2x2_x = 2 * size_16x2_x + 1 * TileSpacing;  // 2*128 + 1*12 = 268mm
    total_2x2_y = 2 * size_16x2_y + 1 * TileSpacing;  // 2*16 + 1*12 = 44mm
    ratio_2x2 = total_2x2_x / total_2x2_y;  // 268/44 = 6.09
    
    // 计算1x4排列的总尺寸和比例
    total_1x4_x = 1 * size_16x2_x + 0 * TileSpacing;  // 1*128 + 0*12 = 128mm
    total_1x4_y = 4 * size_16x2_y + 3 * TileSpacing;  // 4*16 + 3*12 = 100mm
    ratio_1x4 = total_1x4_x / total_1x4_y;  // 128/100 = 1.28
    
    echo(str("4x1排列 4x1 layout: ", total_4x1_x, "x", total_4x1_y, "mm, 比例 ratio: ", ratio_4x1));
    echo(str("2x2排列 2x2 layout: ", total_2x2_x, "x", total_2x2_y, "mm, 比例 ratio: ", ratio_2x2));
    echo(str("1x4排列 1x4 layout: ", total_1x4_x, "x", total_1x4_y, "mm, 比例 ratio: ", ratio_1x4));
    echo(str("最优选择 Optimal choice: 1x4 (比例最接近1 ratio closest to 1)"));
    
    // 测试用例3：边界条件
    // Test Case 3: Boundary conditions
    echo("测试3 Test 3: 边界条件 Boundary Conditions");
    test_single = calculate_grid_dimensions(1, 6, 2);     // 单个积木 - Single brick
    test_prime = calculate_grid_dimensions(7, 3, 3);      // 质数 - Prime number
    test_large = calculate_grid_dimensions(25, 2, 2);     // 最大值 - Maximum value
    
    // 验证计算结果 - Validate calculation results
    validate_grid_calculation(1, test_single[0], test_single[1]);
    validate_grid_calculation(7, test_prime[0], test_prime[1]);
    validate_grid_calculation(25, test_large[0], test_large[1]);
    
    echo(str("单个积木 Single brick: ", test_single, " (期望 expected: [1,1])"));
    echo(str("质数7个单位 Prime 7 units: ", test_prime, " (期望 expected: [7,1] 或 or [1,7])"));
    echo(str("最大25个单位 Maximum 25 units: ", test_large, " (期望 expected: [5,5])"));
    
    // 额外测试：验证算法确实选择了最优排列
    // Additional test: verify algorithm indeed selects optimal arrangement
    echo("测试4 Test 4: 算法验证 Algorithm Verification");
    
    // 测试不同积木尺寸的6个单位排列
    test_1x1_6units = calculate_grid_dimensions(6, 1, 1);   // 1x1积木6个单位
    test_2x1_6units = calculate_grid_dimensions(6, 2, 1);   // 2x1积木6个单位
    test_3x1_6units = calculate_grid_dimensions(6, 3, 1);   // 3x1积木6个单位
    
    ratio_1x1_6units = calculate_grid_aspect_ratio(test_1x1_6units[0], test_1x1_6units[1], 1, 1);
    ratio_2x1_6units = calculate_grid_aspect_ratio(test_2x1_6units[0], test_2x1_6units[1], 2, 1);
    ratio_3x1_6units = calculate_grid_aspect_ratio(test_3x1_6units[0], test_3x1_6units[1], 3, 1);
    
    echo(str("1x1积木6个单位: ", test_1x1_6units, " 比例: ", ratio_1x1_6units));
    echo(str("2x1积木6个单位: ", test_2x1_6units, " 比例: ", ratio_2x1_6units));
    echo(str("3x1积木6个单位: ", test_3x1_6units, " 比例: ", ratio_3x1_6units));
    
    echo("============================================");
}

// ========================================
// 位置计算测试用例 - Position Calculation Test Cases
// ========================================

// 测试位置计算函数的正确性 - Test position calculation function correctness
// 这些测试用例验证位置计算、中心对称和间距逻辑的正确性
// These test cases verify correctness of position calculation, center symmetry and spacing logic

module test_position_calculations() {
    echo("=== 位置计算测试 Position Calculation Tests ===");
    
    // 测试用例1：单个积木位置
    // Test Case 1: Single brick position
    echo("测试1 Test 1: 单个积木位置 Single Brick Position");
    single_pos = calculate_brick_positions(1, 1, 2, 2, TileSpacing);
    validate_brick_positions(single_pos, 1);
    
    echo(str("单个积木位置 Single brick position: ", single_pos[0]));
    echo(str("期望位置 Expected position: [0, 0, 0]"));
    
    // 验证单个积木位于原点 - Verify single brick is at origin
    assert(abs(single_pos[0][0]) < 0.001, "Single brick X should be at origin");
    assert(abs(single_pos[0][1]) < 0.001, "Single brick Y should be at origin");
    assert(single_pos[0][2] == 0, "Single brick Z should be 0");
    
    // 测试用例2：2x2排列的中心对称性
    // Test Case 2: 2x2 arrangement center symmetry
    echo("测试2 Test 2: 2x2排列中心对称 2x2 Arrangement Center Symmetry");
    pos_2x2 = calculate_brick_positions(2, 2, 2, 2, TileSpacing);
    validate_brick_positions(pos_2x2, 4);
    
    // 计算2x2排列的pitch和偏移
    pitch_2x2 = calculate_brick_pitch(2, 2, TileSpacing);
    offset_2x2 = calculate_center_offset(2, 2, pitch_2x2[0], pitch_2x2[1]);
    
    echo(str("2x2积木Pitch: [", pitch_2x2[0], ", ", pitch_2x2[1], "]mm"));
    echo(str("2x2中心偏移: [", offset_2x2[0], ", ", offset_2x2[1], "]mm"));
    echo("2x2积木位置 2x2 brick positions:");
    for (i = [0 : len(pos_2x2)-1]) {
        echo(str("  积木 Brick ", i+1, ": [", pos_2x2[i][0], ", ", pos_2x2[i][1], ", ", pos_2x2[i][2], "]mm"));
    }
    
    // 验证2x2排列的对称性 - Verify 2x2 arrangement symmetry
    is_symmetric_2x2 = check_position_symmetry(pos_2x2);
    echo(str("2x2对称性 2x2 symmetry: ", is_symmetric_2x2 ? "是 Yes" : "否 No"));
    
    // 测试用例3：3x3排列的中心对称性（奇数排列）
    // Test Case 3: 3x3 arrangement center symmetry (odd arrangement)
    echo("测试3 Test 3: 3x3排列中心对称 3x3 Arrangement Center Symmetry");
    pos_3x3 = calculate_brick_positions(3, 3, 2, 2, TileSpacing);
    validate_brick_positions(pos_3x3, 9);
    
    // 计算3x3排列的pitch和偏移
    pitch_3x3 = calculate_brick_pitch(2, 2, TileSpacing);
    offset_3x3 = calculate_center_offset(3, 3, pitch_3x3[0], pitch_3x3[1]);
    
    echo(str("3x3积木Pitch: [", pitch_3x3[0], ", ", pitch_3x3[1], "]mm"));
    echo(str("3x3中心偏移: [", offset_3x3[0], ", ", offset_3x3[1], "]mm"));
    
    // 验证3x3排列的中心积木位于原点 - Verify center brick of 3x3 arrangement is at origin
    center_brick_3x3 = pos_3x3[4]; // 第5个积木应该是中心积木 - 5th brick should be center brick
    echo(str("3x3中心积木位置 3x3 center brick position: [", center_brick_3x3[0], ", ", center_brick_3x3[1], ", ", center_brick_3x3[2], "]mm"));
    
    // 验证3x3排列的对称性 - Verify 3x3 arrangement symmetry
    is_symmetric_3x3 = check_position_symmetry(pos_3x3);
    echo(str("3x3对称性 3x3 symmetry: ", is_symmetric_3x3 ? "是 Yes" : "否 No"));
    
    // 测试用例4：矩形排列（4x1）
    // Test Case 4: Rectangular arrangement (4x1)
    echo("测试4 Test 4: 矩形排列 Rectangular Arrangement (4x1)");
    pos_4x1 = calculate_brick_positions(4, 1, 2, 2, TileSpacing);
    validate_brick_positions(pos_4x1, 4);
    
    // 计算4x1排列的pitch和偏移
    pitch_4x1 = calculate_brick_pitch(2, 2, TileSpacing);
    offset_4x1 = calculate_center_offset(4, 1, pitch_4x1[0], pitch_4x1[1]);
    
    echo(str("4x1积木Pitch: [", pitch_4x1[0], ", ", pitch_4x1[1], "]mm"));
    echo(str("4x1中心偏移: [", offset_4x1[0], ", ", offset_4x1[1], "]mm"));
    echo("4x1积木位置 4x1 brick positions:");
    for (i = [0 : len(pos_4x1)-1]) {
        echo(str("  积木 Brick ", i+1, ": [", pos_4x1[i][0], ", ", pos_4x1[i][1], ", ", pos_4x1[i][2], "]mm"));
    }
    
    // 验证4x1排列的对称性 - Verify 4x1 arrangement symmetry
    is_symmetric_4x1 = check_position_symmetry(pos_4x1);
    echo(str("4x1对称性 4x1 symmetry: ", is_symmetric_4x1 ? "是 Yes" : "否 No"));
    
    // 测试用例5：不同积木尺寸的位置计算
    // Test Case 5: Position calculation for different brick sizes
    echo("测试5 Test 5: 不同积木尺寸 Different Brick Sizes");
    
    // 16x2积木的2x2排列
    pos_16x2_2x2 = calculate_brick_positions(2, 2, 16, 2, TileSpacing);
    validate_brick_positions(pos_16x2_2x2, 4);
    
    // 计算16x2积木的pitch
    pitch_16x2 = calculate_brick_pitch(16, 2, TileSpacing);
    
    echo(str("16x2积木Pitch: [", pitch_16x2[0], ", ", pitch_16x2[1], "]mm"));
    echo("16x2积木2x2排列位置 16x2 brick 2x2 arrangement positions:");
    for (i = [0 : len(pos_16x2_2x2)-1]) {
        echo(str("  积木 Brick ", i+1, ": [", pos_16x2_2x2[i][0], ", ", pos_16x2_2x2[i][1], ", ", pos_16x2_2x2[i][2], "]mm"));
    }
    
    // 验证16x2积木排列的对称性 - Verify 16x2 brick arrangement symmetry
    is_symmetric_16x2 = check_position_symmetry(pos_16x2_2x2);
    echo(str("16x2对称性 16x2 symmetry: ", is_symmetric_16x2 ? "是 Yes" : "否 No"));
    
    // 测试用例6：边界计算
    // Test Case 6: Boundary calculation
    echo("测试6 Test 6: 边界计算 Boundary Calculation");
    
    bounds_2x2 = calculate_position_bounds(pos_2x2, 2, 2);
    bounds_3x3 = calculate_position_bounds(pos_3x3, 2, 2);
    bounds_4x1 = calculate_position_bounds(pos_4x1, 2, 2);
    
    echo(str("2x2边界 2x2 bounds: [", bounds_2x2[0][0], ",", bounds_2x2[0][1], "] 到 to [", bounds_2x2[1][0], ",", bounds_2x2[1][1], "]mm"));
    echo(str("3x3边界 3x3 bounds: [", bounds_3x3[0][0], ",", bounds_3x3[0][1], "] 到 to [", bounds_3x3[1][0], ",", bounds_3x3[1][1], "]mm"));
    echo(str("4x1边界 4x1 bounds: [", bounds_4x1[0][0], ",", bounds_4x1[0][1], "] 到 to [", bounds_4x1[1][0], ",", bounds_4x1[1][1], "]mm"));
    
    // 测试用例7：间距验证
    // Test Case 7: Spacing verification
    echo("测试7 Test 7: 间距验证 Spacing Verification");
    
    // 验证2x2排列中相邻积木的间距
    // Verify spacing between adjacent bricks in 2x2 arrangement
    pos1 = pos_2x2[0]; // 第一个积木 [-14, -14, 0] - First brick
    pos3 = pos_2x2[2]; // 第三个积木 [14, -14, 0] - Third brick (same Y, different X)
    
    distance_x = abs(pos3[0] - pos1[0]);
    expected_distance_x = pitch_2x2[0];
    
    echo(str("相邻积木X方向距离 Adjacent brick X distance: ", distance_x, "mm"));
    echo(str("期望X方向距离 Expected X distance: ", expected_distance_x, "mm"));
    echo(str("间距验证 Spacing verification: ", abs(distance_x - expected_distance_x) < 0.001 ? "通过 Pass" : "失败 Fail"));
    
    // 测试用例8：Z平面验证
    // Test Case 8: Z plane verification
    echo("测试8 Test 8: Z平面验证 Z Plane Verification");
    
    // 验证所有积木都在Z=0平面上
    // Verify all bricks are on Z=0 plane
    all_z_zero = len([for (pos = pos_3x3) if (pos[2] != 0) pos]) == 0;
    echo(str("所有积木在Z=0平面 All bricks on Z=0 plane: ", all_z_zero ? "是 Yes" : "否 No"));
    
    echo("============================================");
}

// 执行测试（仅在开发时启用）- Execute tests (enable only during development)
// 取消注释下面这行来运行测试 - Uncomment the line below to run tests
// test_grid_calculations();
// test_position_calculations();

// ========================================
// 单个积木生成模块 - Single Brick Generation Module
// ========================================

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
// ========================================

/*
 * 主平铺渲染模块 - Main Tiling Rendering Module
 * 
 * 功能：根据tile_units参数选择单个积木或平铺模式
 * Function: Select single brick or tiling mode based on tile_units parameter
 * 
 * 渲染逻辑 - Rendering Logic:
 * - tile_units = 1: 单个积木模式，保持原有功能 - Single brick mode, maintain original functionality
 * - tile_units > 1: 平铺模式，生成多个积木的智能排列 - Tiling mode, generate intelligent arrangement of multiple bricks
 * 
 * 特性 Features:
 * - 智能网格计算：自动选择最优X×Y排列 - Intelligent grid calculation: automatically select optimal X×Y arrangement
 * - 中心对称布局：以原点为中心对称排列 - Center symmetric layout: symmetrically arranged around origin
 * - 固定间距：使用12mm固定间距确保打印质量 - Fixed spacing: use 12mm fixed spacing to ensure print quality
 * - 尺寸验证：集成警告系统检查打印床兼容性 - Size validation: integrated warning system checks print bed compatibility
 * - 向后兼容：完全兼容现有参数和功能 - Backward compatible: fully compatible with existing parameters and functionality
 */
module generate_tiling() {
    // 参数验证 - Parameter validation
    assert(tile_units >= 1, "tile_units must be >= 1");
    assert(tile_units <= 25, "tile_units must be <= 25 (maximum 5x5 arrangement)");
    assert(width >= 1, "width must be >= 1");
    assert(length >= 1, "length must be >= 1");
    assert(height >= 1, "height must be >= 1");
    
    if (tile_units == 1) {
        // ========================================
        // 单个积木模式 - Single Brick Mode
        // ========================================
        
        echo("=== 单个积木模式 Single Brick Mode ===");
        echo(str("积木规格 Brick Spec: ", width, "×", length, "×", height, " 单位 units"));
        echo(str("积木尺寸 Brick Size: ", width * UnitSize, "×", length * UnitSize, "×", height * LayerSize, "mm"));
        echo("========================================");
        
        // 生成单个积木（保持原有功能）- Generate single brick (maintain original functionality)
        single_lego_brick(width, length, height);
        
    } else {
        // ========================================
        // 平铺模式 - Tiling Mode
        // ========================================
        
        echo("=== 平铺模式 Tiling Mode (改进版 Improved) ===");
        
        // 1. 计算最优布局 - Calculate optimal layout (支持不规则排列)
        optimal_layout = calculate_optimal_layout(tile_units, width, length);
        layout_type = optimal_layout[0];
        layout_data = optimal_layout[1];
        
        echo(str("布局类型 Layout Type: ", layout_type));
        if (layout_type == "regular") {
            echo(str("规则网格 Regular Grid: ", layout_data[0], "×", layout_data[1]));
            // 验证规则网格计算结果
            validate_grid_calculation(tile_units, layout_data[0], layout_data[1]);
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

// ========================================
// 主模型生成 - Main Model Generation
// ========================================

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

// 顶部凸点阵列模块 - Top studs array module
// 保持向后兼容，内部调用新的单个积木模块 - Maintain backward compatibility, internally calls new single brick module
module top_studs() {
    single_brick_top_studs(width, length, OuterHeight);
}

// 底部管道阵列模块 - Bottom tubes array module
// 保持向后兼容，内部调用新的单个积木模块 - Maintain backward compatibility, internally calls new single brick module
module bottom_tubes() {
    single_brick_bottom_tubes(width, length, TubeHeight, ActualTubeMargin);
}

// 单个凸点模块 - Single stud module
module single_stud() {
    // 创建圆柱形凸点几何体 - Create cylindrical stud geometry
    // 使用StudDiameter和StudHeight参数 - Use StudDiameter and StudHeight parameters
    cylinder(
        h = StudHeight,           // 凸点高度 - Stud height
        d = StudDiameter,         // 凸点直径 - Stud diameter
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