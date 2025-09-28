# 设计文档

## 概述

本设计文档描述了LEGO基础模块平铺生成功能的技术实现。该功能将扩展现有的单个LEGO积木生成器，增加批量平铺排列能力。设计采用模块化方法，通过添加平铺计算逻辑和位置分布算法，实现多个积木的智能排列。

**🆕 v2.0 改进版本**：新增不规则排列支持，显著优化质数和某些合数的排列效果。

核心设计原则：
1. **无缝集成**：与现有LEGO基础模块完全兼容，不破坏原有功能
2. **简化操作**：用户只需设置tile_units参数，系统自动计算最优排列
3. **智能布局**：支持规则网格和不规则排列，使整体平铺尽可能接近正方形
4. **固定间距**：使用12mm固定间距，确保打印质量和一致性
5. **中心对称**：以坐标原点为中心对称排列，保持布局平衡
6. **🆕 质数优化**：针对质数和某些合数提供更优的不规则排列方案

### 改进的智能排列算法示例

#### 规则网格排列（保持原有功能）
- **16x2积木，4个单位**：算法会选择1x4排列而不是2x2，因为：
  - 1x4排列总尺寸：128×100mm，比例 ≈ 1.28
  - 2x2排列总尺寸：284×52mm，比例 ≈ 5.46
  - 选择比例更接近1的1x4排列
- **2x2积木，4个单位**：算法会选择2x2排列，因为积木本身是正方形，总体也是正方形

#### 🆕 不规则排列（新增功能）
- **7个积木**：从1×7排列（比例≈10）改进为3+2+2三行排列（比例=1.0）
- **11个积木**：从1×11排列（比例很大）改进为4+4+3三行排列（比例≈1.39）
- **13个积木**：从1×13排列改进为4+3+3+3四行排列（比例=1.0）

#### 算法选择逻辑
系统会自动比较规则网格和不规则排列的长宽比，选择更优的方案：
- **质数**：通常选择不规则排列（如7→[3,2,2]，11→[4,4,3]）
- **完全平方数**：通常选择规则网格（如9→3×3，16→4×4）
- **其他合数**：根据具体情况选择最优方案

## 架构

### 整体结构
```
TilingLegoGenerator
├── ParameterDefinition (参数定义)
│   ├── ExistingParameters (现有参数: width, length, height)
│   └── TilingParameter (新增参数: tile_units)
├── TilingCalculation (平铺计算模块)
│   ├── GridCalculator (网格计算器)
│   ├── PositionCalculator (位置计算器)
│   └── SizeValidator (尺寸验证器)
├── SingleBrickGenerator (单个积木生成器 - 复用现有代码)
└── TilingRenderer (平铺渲染器)
    ├── BrickPositioning (积木定位)
    └── LayoutGeneration (布局生成)
```

### 设计模式
- **策略模式**：根据tile_units值选择单个积木或平铺模式
- **模板方法**：复用现有的积木生成逻辑
- **计算器模式**：分离平铺计算逻辑，便于测试和维护

## 组件和接口

### 1. 参数定义模块

#### 扩展的参数结构
```openscad
/* [Parameters] */
// 现有参数（保持不变）
width = 6; // [1:31]
length = 2; // [1:31] 
height = 3; // [1:Low, 3:High]

// 新增平铺参数
tile_units = 1; // [1:25] 平铺积木数量

/* [Hidden] */
// 现有隐藏参数（保持不变）
$fn = 96;
LayerSize = 3.2;
UnitSize = 8;
// ... 其他现有参数

// 新增平铺相关常量
TileSpacing = 12;  // 固定间距 12mm
```

#### 参数设计原则
1. **向后兼容**：所有现有参数保持不变
2. **默认行为**：tile_units默认为1，保持原有单个积木功能
3. **简化接口**：只增加一个用户可见参数
4. **MakerWorld兼容**：遵循现有的参数化规范

### 2. 平铺计算模块 (TilingCalculation)

#### 网格计算器 (GridCalculator)
**功能**: 根据tile_units和积木实际尺寸计算最优的X和Y方向积木数量
**输入**: tile_units (整数), brick_width, brick_length (积木尺寸)
**输出**: grid_x, grid_y (整数对)

**算法逻辑**:
```openscad
function calculate_grid_dimensions(tile_units, brick_width, brick_length) = 
    tile_units == 1 ? [1, 1] :
    let(
        // 计算积木的实际物理尺寸（包含间距）
        brick_size_x = brick_width * UnitSize + TileSpacing,
        brick_size_y = brick_length * UnitSize + TileSpacing,
        
        // 寻找使总体尺寸最接近正方形的因数分解
        best_factors = find_optimal_factors(tile_units, brick_size_x, brick_size_y)
    )
    best_factors;

function find_optimal_factors(n, size_x, size_y) = 
    let(
        // 获取所有可能的因数对
        all_factors = [for (i = [1 : n]) if (n % i == 0) [i, n/i]],
        
        // 计算每个因数对的总体尺寸比例
        ratios = [for (factors = all_factors) 
            let(
                total_x = factors[0] * size_x,
                total_y = factors[1] * size_y,
                ratio = max(total_x, total_y) / min(total_x, total_y)
            )
            [factors, ratio]
        ],
        
        // 选择比例最接近1（最接近正方形）的因数对
        best_ratio = min([for (r = ratios) r[1]]),
        best_factors = [for (r = ratios) if (r[1] == best_ratio) r[0]][0]
    )
    best_factors;
```

#### 位置计算器 (PositionCalculator)
**功能**: 计算每个积木在平铺中的精确位置
**输入**: grid_x, grid_y, brick_dimensions, spacing
**输出**: 位置坐标数组

**计算逻辑**:
```openscad
function calculate_brick_positions(grid_x, grid_y, brick_width, brick_length, spacing) = 
    let(
        // 单个积木的实际尺寸（包含间距）
        brick_pitch_x = brick_width * UnitSize + spacing,
        brick_pitch_y = brick_length * UnitSize + spacing,
        
        // 整个网格的总尺寸
        total_width = (grid_x - 1) * brick_pitch_x,
        total_length = (grid_y - 1) * brick_pitch_y,
        
        // 起始偏移（使网格居中于原点）
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

#### 尺寸验证器 (SizeValidator)
**功能**: 验证平铺尺寸并提供警告
**输入**: 总体尺寸
**输出**: 验证结果和警告信息

```openscad
module validate_tiling_size(total_x, total_y) {
    max_bed_size = 256; // 常见打印床尺寸
    
    if (total_x > max_bed_size || total_y > max_bed_size) {
        echo(str("警告: 平铺尺寸 ", total_x, "x", total_y, 
                "mm 超过常见打印床尺寸 ", max_bed_size, "x", max_bed_size, "mm"));
    }
    
    grid_dims = calculate_grid_dimensions(tile_units, width, length);
    echo(str("平铺信息: ", 
            grid_dims[0], "x", grid_dims[1], " 排列, ",
            "积木尺寸: ", width, "x", length, " 单位, ",
            "总尺寸: ", total_x, "x", total_y, "mm"));
}
```

### 3. 单个积木生成器 (SingleBrickGenerator)

**功能**: 复用现有的积木生成逻辑
**设计**: 将现有的积木生成代码封装为模块，便于在平铺中重复调用

```openscad
module single_lego_brick(width, length, height) {
    // 现有的积木生成逻辑
    // 包括外壳、凸点、管道等所有组件
    union() {
        exterior_shell(width, length, height);
        top_studs(width, length);
        if (height > 1) {
            bottom_tubes(width, length, height);
        }
    }
}
```

### 4. 平铺渲染器 (TilingRenderer)

#### 主渲染逻辑
```openscad
module generate_tiling() {
    if (tile_units == 1) {
        // 单个积木模式
        single_lego_brick(width, length, height);
    } else {
        // 平铺模式
        grid_dims = calculate_grid_dimensions(tile_units, width, length);
        positions = calculate_brick_positions(
            grid_dims[0], grid_dims[1], 
            width, length, TileSpacing
        );
        
        // 尺寸验证和警告
        total_size = calculate_total_size(grid_dims, width, length);
        validate_tiling_size(total_size[0], total_size[1]);
        
        // 生成平铺积木
        for (i = [0 : len(positions)-1]) {
            translate(positions[i]) {
                single_lego_brick(width, length, height);
            }
        }
    }
}
```

## 数据模型

### 平铺参数模型
```openscad
// 输入参数
tile_units = 6;        // 用户输入的积木数量

// 计算得出的网格参数
grid_x = 3;           // X方向积木数量
grid_y = 2;           // Y方向积木数量

// 位置参数
brick_pitch_x = width * UnitSize + TileSpacing;   // X方向积木间距
brick_pitch_y = length * UnitSize + TileSpacing;  // Y方向积木间距

// 总体尺寸
total_width = (grid_x - 1) * brick_pitch_x + width * UnitSize;
total_length = (grid_y - 1) * brick_pitch_y + length * UnitSize;
```

### 位置计算模型
```openscad
// 积木位置数组
positions = [
    [x1, y1, 0],  // 第一个积木位置
    [x2, y2, 0],  // 第二个积木位置
    // ...
    [xn, yn, 0]   // 第n个积木位置
];

// 中心对称计算
center_offset_x = -total_width / 2;
center_offset_y = -total_length / 2;
```

## 错误处理

### 参数验证
1. **tile_units范围检查**: 确保1 ≤ tile_units ≤ 25
2. **网格计算验证**: 确保因数分解结果正确
3. **尺寸合理性检查**: 验证总体尺寸不会过大

### 几何验证
1. **位置计算验证**: 确保所有积木位置正确且不重叠
2. **间距验证**: 确保12mm间距正确应用
3. **中心对称验证**: 验证布局以原点为中心

### 警告系统
```openscad
module warning_system() {
    // 尺寸警告
    if (total_size > 256) {
        echo("警告: 模型尺寸过大，可能超出打印床范围");
    }
    
    // 性能警告
    if (tile_units > 16) {
        echo("提示: 积木数量较多，渲染可能需要较长时间");
    }
    
    // 信息输出
    echo(str("平铺配置: ", grid_x, "x", grid_y, " 排列"));
    echo(str("总尺寸: ", total_width, "x", total_length, "mm"));
}
```

## 测试策略

### 单元测试
1. **网格计算测试**: 验证不同积木尺寸和tile_units值的网格计算结果
   - 正方形积木(2x2, 4x4)的完全平方数配置: 1, 4, 9, 16, 25
   - 矩形积木(16x2, 8x1)的各种配置: 2, 3, 4, 5, 6, 8, 10, 12
   - 验证计算结果确实使总体尺寸最接近正方形
2. **位置计算测试**: 验证积木位置的正确性和中心对称性
3. **尺寸计算测试**: 验证总体尺寸计算的准确性

### 集成测试
1. **单个积木模式测试**: tile_units=1时保持原有功能
2. **小型平铺测试**: 2-6个积木的平铺排列
3. **大型平铺测试**: 16-25个积木的平铺排列
4. **边界条件测试**: 最小和最大tile_units值

### 兼容性测试
1. **现有参数兼容性**: 确保width、length、height参数正常工作
2. **MakerWorld兼容性**: 验证参数化界面正确显示
3. **STL导出测试**: 确保平铺模型可正确导出

### 性能测试
1. **渲染性能**: 测试不同积木数量的渲染时间
2. **内存使用**: 监控大型平铺的内存占用
3. **导出效率**: 测试STL导出的速度和文件大小

## 实现注意事项

### 代码组织
1. **模块化设计**: 将平铺功能封装为独立模块
2. **函数复用**: 最大化复用现有的积木生成代码
3. **清晰命名**: 使用描述性的变量和函数名

### 性能优化
1. **计算缓存**: 缓存重复的计算结果
2. **条件渲染**: 根据tile_units值选择渲染路径
3. **几何优化**: 避免不必要的几何操作

### 用户体验
1. **即时反馈**: 通过echo提供实时信息
2. **清晰文档**: 在代码中添加详细注释
3. **错误提示**: 提供有用的错误和警告信息