# 需求文档

## 介绍

本项目旨在使用OpenSCAD创建一个参数化的乐高基础模块3D模型。该模型将符合乐高官方规格，支持3D打印，并可发布到MakerWorld等模型共享平台。模型将具有可配置的长度、宽度和高度参数，同时保持与真实乐高积木的兼容性。

## 需求

### 需求 1

**用户故事：** 作为一个3D打印爱好者，我希望能够生成不同尺寸的乐高兼容积木，以便我可以打印出符合我项目需要的定制积木。

#### 验收标准

1. WHEN 用户设置Width参数 THEN 系统 SHALL 生成对应宽度单位数量的乐高积木模型
2. WHEN 用户设置Length参数 THEN 系统 SHALL 生成对应长度单位数量的乐高积木模型  
3. WHEN 用户设置Height参数 THEN 系统 SHALL 生成对应层数的乐高积木模型
4. IF Width参数未设置 THEN 系统 SHALL 默认使用4个单位宽度
5. IF Length参数未设置 THEN 系统 SHALL 默认使用2个单位长度
6. IF Height参数未设置 THEN 系统 SHALL 默认使用3层（9.6mm）
7. WHEN Height设置为1 THEN 系统 SHALL 生成单层积木模型

### 需求 2

**用户故事：** 作为一个乐高爱好者，我希望3D打印的积木能够与真实乐高积木完美兼容，以便我可以将它们混合使用在我的乐高作品中。

#### 验收标准

1. WHEN 生成积木模型 THEN 系统 SHALL 使用LayerSize = 3.2mm作为每层高度
2. WHEN 生成积木模型 THEN 系统 SHALL 使用UnitSize = 8mm作为单位尺寸
3. WHEN 生成积木模型 THEN 系统 SHALL 使用StudDiameter = 4.8mm作为凸点直径
4. WHEN 生成积木模型 THEN 系统 SHALL 使用StudHeight = 1.8mm作为凸点高度
5. WHEN 生成积木模型 THEN 系统 SHALL 使用StudMargin = 4mm作为凸点边距

### 需求 3

**用户故事：** 作为一个3D打印用户，我希望模型考虑到3D打印的特殊要求，以便打印出的积木具有良好的配合精度和结构强度。

#### 验收标准

1. WHEN 生成积木模型 THEN 系统 SHALL 应用CLEARANCESize = 0.2mm的间隙调整
2. WHEN 计算积木边缘 THEN 系统 SHALL 收缩0.2mm以确保配合精度
3. WHEN 计算实际边缘尺寸 THEN 系统 SHALL 减去CLEARANCESize/2
4. WHEN 生成积木壁厚 THEN 系统 SHALL 使用WallThickness = 1.6mm（针对3D打印优化）
5. WHEN 生成内部管道结构 THEN 系统 SHALL 使用TubeInnerDiameter = 4.8mm
6. WHEN 生成内部管道结构 THEN 系统 SHALL 使用TubeOuterDiameter = 6.5mm
7. WHEN 计算管道边距 THEN 系统 SHALL 使用TubeMargin = 8.0mm并减去CLEARANCESize/2

### 需求 4

**用户故事：** 作为一个OpenSCAD用户，我希望能够轻松修改模型参数，以便快速生成不同规格的积木而无需修改复杂的代码。

#### 验收标准

1. WHEN 打开OpenSCAD文件 THEN 系统 SHALL 在文件顶部提供清晰的参数定义区域
2. WHEN 用户修改Width、Length或Height参数 THEN 系统 SHALL 自动重新生成对应的模型
3. WHEN 用户需要了解参数含义 THEN 系统 SHALL 提供清晰的注释说明每个参数的作用
4. IF 用户不修改默认参数 THEN 系统 SHALL 使用Width=4, Length=2, Height=3作为默认值
5. WHEN 使用默认参数 THEN 系统 SHALL 生成4x2的常见乐高积木规格

### 需求 5

**用户故事：** 作为一个模型分享者，我希望生成的模型文件适合发布到MakerWorld等平台，以便其他用户可以轻松使用和修改。

#### 验收标准

1. WHEN 生成OpenSCAD文件 THEN 系统 SHALL 包含清晰的文档注释
2. WHEN 生成模型 THEN 系统 SHALL 确保模型结构适合STL导出
3. WHEN 导出STL文件 THEN 系统 SHALL 生成无错误的可打印网格
4. WHEN 其他用户使用模型 THEN 系统 SHALL 提供易于理解的参数说明

### 需求 6

**用户故事：** 作为MakerWorld平台的用户，我希望能够通过网页界面自定义乐高积木的尺寸参数，以便我可以直接在平台上生成所需规格的积木模型。

#### 验收标准

1. WHEN 用户在MakerWorld上访问模型 THEN 系统 SHALL 提供width和length的滑块控件，范围为1-31
2. WHEN 用户在MakerWorld上访问模型 THEN 系统 SHALL 提供height的带标签下拉菜单，High对应3，Low对应1
3. WHEN 用户调整参数 THEN 系统 SHALL 隐藏所有内部技术参数（如$fn、常量等）在/* [Hidden] */标签下
4. WHEN 用户设置width或length为31 THEN 系统 SHALL 生成约250mm尺寸的模型（适合大部分256mm×256mm打印机）
5. WHEN 用户选择High高度 THEN 系统 SHALL 生成3层高度的积木
6. WHEN 用户选择Low高度 THEN 系统 SHALL 生成1层高度的积木
7. WHEN 模型在MakerWorld上显示 THEN 系统 SHALL 按照拓竹Bambulab的参数化注释规范格式化所有参数