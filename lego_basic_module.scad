/*
 * 参数化乐高基础模块 - Parametric LEGO Basic Module
 * 
 * 本文件生成符合乐高官方规格的3D可打印积木模型
 * 支持自定义尺寸参数，并针对3D打印进行了优化
 * 
 * 使用方法：
 * 1. 修改下方的用户参数（width, length, height）
 * 2. 按F5预览模型，按F6渲染完整模型
 * 3. 导出STL文件用于3D打印
 * 
 * 兼容性：与真实乐高积木完全兼容
 * 打印建议：建议使用0.2mm层高，15-20%填充率
 */

/* [Parameters] */

// 积木宽度（单位数量）- Block width in units
width = 6; // [1:31]

// 积木长度（单位数量）- Block length in units  
length = 2; // [1:31]

// 积木高度（层数）- Block height in layers
height = 3; // [1:Low, 3:High]

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
function calculate_tube_positions(width, length, tube_margin) = [
    for (i = [0:width-2])  // width-1 个管道
        for (j = [0:length-2])  // length-1 个管道
            [
                (i - (width-2)/2) * tube_margin,   // X位置 - X position
                (j - (length-2)/2) * tube_margin,  // Y位置 - Y position
                0                                  // Z位置 - Z position (底面)
            ]
];

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

// 计算管道数量（所有积木都有管道）
// Calculate tube count (all blocks have tubes)
function calculate_tube_count(width, length, height) = 
    (width - 1) * (length - 1);

// 计算管道高度
// Calculate tube height
function calculate_tube_height(height, layer_size) = 
    layer_size * height;

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
// 主模型生成 - Main Model Generation
// ========================================

// 主模型组装 - Main model assembly
union() {
    // 外壳薄壳结构 - Exterior shell structure
    exterior_shell();
    
    // 顶部凸点阵列 - Top studs array
    top_studs();
    
    // 底部管道结构（所有积木都有）- Bottom tubes structure (all blocks have tubes)
    bottom_tubes();
}

// ========================================
// 模块定义 - Module Definitions
// ========================================

// 外壳薄壳结构模块 - Exterior shell structure module
module exterior_shell() {
    difference() {
        // 外部立方体几何体 - Outer cube geometry
        translate([0, 0, OuterHeight/2]) {
            cube([OuterWidth, OuterLength, OuterHeight], center=true);
        }
        
        // 内部空腔几何体（考虑壁厚）- Inner cavity geometry (considering wall thickness)
        // 空腔从底部开始，顶面封闭，底面开放
        // Cavity starts from bottom, top face closed, bottom face open
        translate([0, 0, InnerHeight/2]) {
            cube([InnerWidth, InnerLength, InnerHeight], center=true);
        }
    }
}

// 顶部凸点阵列模块 - Top studs array module
module top_studs() {
    // 使用循环生成width × length的凸点阵列
    // Use loops to generate width × length stud array
    for (i = [0:width-1]) {
        for (j = [0:length-1]) {
            // 计算凸点位置 - Calculate stud position
            stud_x = (i - (width-1)/2) * UnitSize;
            stud_y = (j - (length-1)/2) * UnitSize;
            stud_z = OuterHeight; // 凸点位于顶面 - Studs on top surface
            
            // 生成单个凸点 - Generate single stud
            translate([stud_x, stud_y, stud_z]) {
                single_stud();
            }
        }
    }
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

// 底部管道阵列模块 - Bottom tubes array module
module bottom_tubes() {
    // 使用循环生成管道阵列 - Use loops to generate tube array
    // 管道数量：(width-1) × (length-1) - Tube count: (width-1) × (length-1)
    for (i = [0:width-2]) {
        for (j = [0:length-2]) {
            // 计算管道位置 - Calculate tube position
            // 圆心距离基于TubeMargin，考虑间隙调整 - Center distance based on TubeMargin with clearance
            tube_x = (i - (width-2)/2) * ActualTubeMargin;
            tube_y = (j - (length-2)/2) * ActualTubeMargin;
            tube_z = 0; // 管道从底面开始 - Tubes start from bottom
            
            // 生成单个薄壳管道 - Generate single thin-wall tube
            translate([tube_x, tube_y, tube_z]) {
                single_tube();
            }
        }
    }
}

// 单个薄壳管道模块 - Single thin-wall tube module
module single_tube() {
    // 使用difference()操作生成薄壳管道 - Use difference() to generate thin-wall tube
    // 外径圆柱减去内径圆柱 - Outer cylinder minus inner cylinder
    difference() {
        // 外径圆柱几何体 - Outer cylinder geometry
        cylinder(
            h = TubeHeight,                    // 管道高度 - Tube height
            d = TubeOuterDiameter,             // 外径 - Outer diameter
            center = false                     // 从底面开始 - Start from bottom
        );
        
        // 内径圆柱几何体（形成空腔）- Inner cylinder geometry (creates cavity)
        cylinder(
            h = TubeHeight + 0.1,              // 稍微高一点确保完全切除 - Slightly taller to ensure complete cut
            d = TubeInnerDiameter,             // 内径 - Inner diameter
            center = false                     // 从底面开始 - Start from bottom
        );
    }
}