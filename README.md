# 参数化乐高基础模块 / Parametric LEGO Basic Module

一个使用OpenSCAD创建的参数化乐高兼容积木3D模型，支持自定义尺寸并针对3D打印进行了优化。

A parametric LEGO-compatible brick 3D model created with OpenSCAD, supporting custom dimensions and optimized for 3D printing.

## 🎯 特性 / Features

- **完全兼容** - 与真实乐高积木100%兼容
- **参数化设计** - 轻松调整长度、宽度、高度
- **3D打印优化** - 考虑了打印精度和结构强度
- **标准规格** - 严格遵循乐高官方尺寸标准
- **开源免费** - MIT许可证，自由使用和修改

- **Fully Compatible** - 100% compatible with real LEGO bricks
- **Parametric Design** - Easily adjust length, width, height
- **3D Print Optimized** - Considers printing precision and structural strength
- **Standard Specifications** - Strictly follows official LEGO dimensions
- **Open Source** - MIT license, free to use and modify

## 🚀 快速开始 / Quick Start

### 1. 下载和打开 / Download and Open

```bash
git clone https://github.com/tomcatzh/StandardLEGOBlock.git
cd StandardLEGOBlock
```

用OpenSCAD打开 `lego_basic_module.scad` 文件。

Open `lego_basic_module.scad` file with OpenSCAD.

### 2. 自定义参数 / Customize Parameters

在文件顶部修改这些参数：

Modify these parameters at the top of the file:

```scad
// 积木宽度（单位数量）- Block width in units
Width = 6;

// 积木长度（单位数量）- Block length in units  
Length = 2;

// 积木高度（层数）- Block height in layers
Height = 3;
```

### 3. 预览和渲染 / Preview and Render

- 按 `F5` 预览模型 / Press `F5` to preview
- 按 `F6` 完整渲染 / Press `F6` for full render
- 导出STL文件用于3D打印 / Export STL for 3D printing

## 📐 技术规格 / Technical Specifications

### 乐高标准尺寸 / LEGO Standard Dimensions

| 参数 Parameter | 值 Value | 说明 Description |
|---|---|---|
| LayerSize | 3.2mm | 每层高度 / Height per layer |
| UnitSize | 8mm | 单位尺寸 / Unit size |
| StudDiameter | 4.8mm | 凸点直径 / Stud diameter |
| StudHeight | 1.8mm | 凸点高度 / Stud height |

### 3D打印优化 / 3D Printing Optimization

| 参数 Parameter | 值 Value | 说明 Description |
|---|---|---|
| CLEARANCESize | 0.2mm | 配合间隙 / Fitting clearance |
| WallThickness | 1.6mm | 壁厚 / Wall thickness |
| TubeInnerDiameter | 4.8mm | 内管直径 / Inner tube diameter |
| TubeOuterDiameter | 6.5mm | 外管直径 / Outer tube diameter |

## 🖨️ 3D打印建议 / 3D Printing Recommendations

### 推荐设置 / Recommended Settings

- **层高 Layer Height**: 0.2mm
- **填充率 Infill**: 15-20%
- **壁厚 Wall Thickness**: 3-4层 / 3-4 walls
- **支撑 Support**: 通常不需要 / Usually not needed
- **底板附着 Bed Adhesion**: 建议使用 / Recommended

### 材料建议 / Material Recommendations

- **PLA**: 易打印，适合初学者 / Easy to print, good for beginners
- **PETG**: 更强韧，更好的层间附着 / Stronger, better layer adhesion
- **ABS**: 最接近真实乐高材质 / Closest to real LEGO material

## 📁 项目结构 / Project Structure

```
StandardLEGOBlock/
├── README.md                           # 项目说明 / Project documentation
├── LICENSE                            # MIT许可证 / MIT license
├── lego_basic_module.scad            # 主要OpenSCAD文件 / Main OpenSCAD file
└── .kiro/specs/lego-basic-module/    # 项目规格文档 / Project specifications
    ├── requirements.md               # 需求文档 / Requirements document
    ├── design.md                    # 设计文档 / Design document
    └── tasks.md                     # 任务列表 / Task list
```

## 🔧 自定义和扩展 / Customization and Extension

### 常见尺寸示例 / Common Size Examples

```scad
// 2x4 标准积木 / 2x4 standard brick
Width = 4; Length = 2; Height = 3;

// 2x2 方形积木 / 2x2 square brick  
Width = 2; Length = 2; Height = 3;

// 1x8 长条积木 / 1x8 long brick
Width = 8; Length = 1; Height = 3;

// 2x4 薄片 / 2x4 plate
Width = 4; Length = 2; Height = 1;
```

### 高级自定义 / Advanced Customization

文件中包含了完整的参数化函数，你可以：

The file includes complete parametric functions, you can:

- 修改间隙参数以适应不同打印机精度 / Adjust clearance for different printer precision
- 调整壁厚以改变强度 / Modify wall thickness for different strength
- 自定义管道结构 / Customize tube structure

## 🤝 贡献 / Contributing

欢迎提交问题报告、功能请求或拉取请求！

Welcome to submit issue reports, feature requests, or pull requests!

1. Fork 这个项目 / Fork the project
2. 创建功能分支 / Create a feature branch
3. 提交更改 / Commit your changes
4. 推送到分支 / Push to the branch
5. 打开拉取请求 / Open a pull request

## 📄 许可证 / License

本项目采用MIT许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 致谢 / Acknowledgments

- 感谢乐高集团创造了这个令人惊叹的积木系统 / Thanks to The LEGO Group for creating this amazing building system
- 感谢OpenSCAD社区提供的优秀工具 / Thanks to the OpenSCAD community for the excellent tools
- 感谢所有3D打印爱好者的贡献和反馈 / Thanks to all 3D printing enthusiasts for contributions and feedback

## 📞 联系 / Contact

如果你有任何问题或建议，请通过以下方式联系：

If you have any questions or suggestions, please contact via:

- 提交GitHub Issue / Submit a GitHub Issue
- 发送邮件至 / Send email to: i@zxf.io

---

**免责声明 / Disclaimer**: 本项目与乐高集团无关。LEGO®是乐高集团的注册商标。

**Disclaimer**: This project is not affiliated with The LEGO Group. LEGO® is a registered trademark of The LEGO Group.