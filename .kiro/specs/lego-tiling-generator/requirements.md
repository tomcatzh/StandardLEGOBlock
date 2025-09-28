# 需求文档

## 介绍

本项目旨在为现有的LEGO基础模块项目增加平铺生成功能。该功能将允许用户生成多个LEGO积木的平铺排列，支持不同的排列模式、间距设置和布局配置。这将使用户能够一次性生成多个积木用于批量3D打印，或创建复杂的积木组合结构。

## 需求

### 需求 1

**用户故事：** 作为一个3D打印爱好者，我希望能够生成多个LEGO积木的平铺排列，以便我可以在一次打印中制作多个积木，提高打印效率。

#### 验收标准

1. WHEN 用户设置tile_units参数 THEN 系统 SHALL 根据积木实际尺寸计算最优的X和Y方向积木数量
2. WHEN 计算排列方式 THEN 系统 SHALL 考虑积木的width和length尺寸，使整体平铺尽可能接近正方形
3. WHEN 积木为正方形（width=length）且tile_units为完全平方数 THEN 系统 SHALL 生成正方形排列（如9个积木排成3x3）
4. WHEN 积木为矩形或tile_units为非完全平方数 THEN 系统 SHALL 计算使总体尺寸最接近正方形的排列方式
5. WHEN 生成平铺排列 THEN 系统 SHALL 使用固定的12mm间距，与积木尺寸无关
6. IF tile_units未设置 THEN 系统 SHALL 默认使用1个积木（单个积木模式）
7. WHEN 应用间距 THEN 系统 SHALL 确保所有积木之间保持一致的12mm安全距离
8. WHEN 生成平铺 THEN 系统 SHALL 确保所有积木使用相同的width、length、height参数
9. WHEN 生成平铺排列 THEN 系统 SHALL 以坐标原点(0,0)为中心对称排列积木

### 需求 2

**用户故事：** 作为一个批量生产用户，我希望系统能够智能优化平铺的布局和间距，以便最大化打印床利用率和打印质量。

#### 验收标准

1. WHEN 系统计算间距 THEN 系统 SHALL 使用固定的12mm间距，与积木大小无关
2. WHEN 生成平铺 THEN 系统 SHALL 在所有积木之间保持一致的12mm间距
3. WHEN 12mm间距应用时 THEN 系统 SHALL 确保足够的空间用于打印质量和后处理
4. WHEN 生成平铺布局 THEN 系统 SHALL 计算并显示总体尺寸信息
5. WHEN 总体尺寸超过常见打印床尺寸(256x256mm) THEN 系统 SHALL 在控制台输出警告信息
6. WHEN 生成平铺 THEN 系统 SHALL 以原点为中心对称排列积木，确保布局平衡

### 需求 3

**用户故事：** 作为一个OpenSCAD用户，我希望平铺功能能够与现有的LEGO基础模块无缝集成，以便我可以轻松在单个积木和平铺模式之间切换。

#### 验收标准

1. WHEN tile_units设置为1 THEN 系统 SHALL 生成单个积木（保持原有功能）
2. WHEN tile_units设置为大于1 THEN 系统 SHALL 生成对应数量的平铺排列积木
3. WHEN 切换tile_units数值 THEN 系统 SHALL 保持所有现有的积木参数（width、length、height等）
4. WHEN 使用平铺模式 THEN 系统 SHALL 保持与原有积木相同的质量和精度
5. WHEN 修改积木参数 THEN 系统 SHALL 自动更新整个平铺阵列
6. WHEN 平铺功能使用 THEN 系统 SHALL 不影响原有的MakerWorld参数化支持

### 需求 4

**用户故事：** 作为一个3D打印优化用户，我希望平铺功能考虑到3D打印的特殊要求，以便生成的平铺模型具有良好的打印成功率。

#### 验收标准

1. WHEN 生成平铺模型 THEN 系统 SHALL 使用固定的12mm间距确保支撑材料移除和打印质量
2. WHEN 应用12mm间距 THEN 系统 SHALL 确保这个距离适用于所有积木尺寸
3. WHEN 生成大型平铺 THEN 系统 SHALL 考虑打印床附着力和翘曲风险
4. WHEN 计算积木位置 THEN 系统 SHALL 确保所有积木都在同一Z平面上
5. WHEN 导出STL THEN 系统 SHALL 生成单一连续的网格模型
6. WHEN 平铺数量较多 THEN 系统 SHALL 提供渲染性能优化建议

### 需求 5

**用户故事：** 作为MakerWorld平台的用户，我希望平铺功能也能通过网页界面进行配置，以便我可以直接在平台上生成批量积木模型。

#### 验收标准

1. WHEN 用户在MakerWorld上访问模型 THEN 系统 SHALL 提供tile_units的滑块控件，范围为1-25（最大5x5排列）
2. WHEN tile_units设置为1 THEN 系统 SHALL 显示单个积木
3. WHEN tile_units设置为大于1 THEN 系统 SHALL 自动计算并应用最优排列和12mm间距
4. WHEN 用户调整tile_units THEN 系统 SHALL 根据积木尺寸自动计算并显示实际的排列尺寸（如"4x1排列，总尺寸XXxYYmm"）
5. WHEN 用户调整平铺参数 THEN 系统 SHALL 实时更新模型预览
6. WHEN 平铺参数组合可能导致过大模型 THEN 系统 SHALL 在控制台输出警告信息