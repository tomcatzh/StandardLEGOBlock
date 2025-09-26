// 我们将在此演示 参数化模型定制器支持的大部分语法。
// 此文件并非用于演示 OpenSCAD 的语法。请参阅官方文档以获取更多详细信息：
// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual

////////////////////////////////////////
// 简介
////////////////////////////////////////

// 使用 /* [name] */ 来创建一个新的标签页。
// 这可以用于将您的参数组织到不同的标签页中。
/* [Parameters] */

// 对于每个参数，您可以使用以下语法：

NoDesc = 1;

// 您还可以通过在参数的前一行添加注释来为每个参数添加描述。

// 注释将显示为参数的描述。
WithDesc = 1;

// 在接下来的部分中，我们将演示不同类型的参数。

////////////////////////////////////////
// 下拉菜单
////////////////////////////////////////
/* [Dropdown] */
// 要定义一个下拉框，您可以使用以下语法：
// parameterName = value; // [value1, value2, value3]

// 数字的下拉菜单
NumberDropdown = 2; // [0, 1, 2, 3]

// 字符串的下拉菜单
StringDropdown = "foo"; // [foo, bar, baz]


// 您还可以使用以下语法为每个值添加标签，
// 以便下拉框显示标签而不是值：
// parameterName = value; // [value1:label1, value2:label2, value3:label3]

// 带标签的数字下拉菜单
Labeled_values = 10; // [10:L, 20:M, 30:XL]

// 带标签的字符串下拉菜单
Labeled_value = "S"; // [S:Small, M:Medium, L:Large]


////////////////////////////////////////
// 滑动条
////////////////////////////////////////
/* [ Slider ] */

// 要定义一个滑动条，您可以使用以下语法：
// parameterName = value; // [min:max]
// 您还可以使用以下语法向滑动条添加步长：
// parameterName = value; // [min:step:max]

// 带有最小值和最大值的滑动条
slider = 34; // [10:100]

// 带有最小值、最大值和步长的步进滑动条
stepSlider = 2; //[0:5:100]

// 小数的步进滑动条
decimalSlider = 2; //[0:0.1:100]

////////////////////////////////////////
// 开关
////////////////////////////////////////
/* [Checkbox] */
// 要定义一个开关，您可以使用以下语法（value 为 true 或 false）：
// parameterName = value;

// 布尔值的开关
checkbox1 = true;


////////////////////////////////////////
// 微调框
////////////////////////////////////////
/* [Spinbox] */
// 要定义一个微调框，您可以使用以下语法（value 是一个数字）：
// parameterName = value;

// 步长为 1 的微调框
SpinboxForInt = 5;
// 步长为 0.1 的微调框
SpinboxForDecimal = 5.0;


////////////////////////////////////////
// 文本框
////////////////////////////////////////
/* [Textbox] */
// 要定义一个文本框，您可以使用以下语法（value 是一个字符串）：
// parameterName = value;

// 字符串的文本框
stringTextbox = "hello";

////////////////////////////////////////
// 数组
////////////////////////////////////////
/* [Vector] */
// 我们可以定义一个数字数组。用户可以使用微调框调整每个值。
// 您可以使用以下语法（value 是数字）：
// parameterName = [value1, value2, value3];

// 具有单个值的向量
VectorSingleValue = [1];
// 具有多个值的向量
VectorMultipleValues = [12, 34, 46, 24];

// 您还可以使用以下语法定义范围和步长：
// parameterName = [value1, value2, value3]; // [min:step:max]

// 具有范围和步长的向量
VectorRGB = [128, 23, 231]; //[0:1:255]

// 步长为 0.1 的向量
VectorWithStep = [ 12, 34 ]; //[:0.1:]

////////////////////////////////////////
// 文件
////////////////////////////////////////
/* [File] */
// 参数化模型定制器允许用户上传 PNG、SVG 和 STL 文件。

// 请求一个 PNG 文件。该值必须是 "default.png"。
filenamePNG1 = "default.png";
// 您可以请求多个具有相同类型的文件
filenamePNG2 = "default.png";

// 请求一个 SVG 文件。该值必须是 "default.svg"。
filenameSVG = "default.svg";

// 请求一个 STL 文件。该值必须是 "default.stl"。
filenameSTL = "default.stl";

////////////////////////////////////////
// 颜色
////////////////////////////////////////
/* [Color] */
// 参数化模型定制器可以生成多色模型。
// 用户可以使用颜色选择器选择颜色，语法如下（value 必须是十六进制格式的颜色）：
// parameterName = "#000000"; //color

color = "#FF0000"; // color


////////////////////////////////////////
// 字体
////////////////////////////////////////
/* [Font] */
// 参数化模型定制器集成了大多数 Google 字体。
// 参数化模型定制器还提供了一个字体选择器供用户选择字体。
// 用户可以使用以下语法选择字体：
// parameterName = "Arial"; //font

font = "HarmonyOS Sans SC:style=Black"; //font

// 如果您想隐藏某些参数，可以使用 hidden 标签。
/* [Hidden] */
hiddenParam = false;

////////////////////////////////////////
// 多盘
////////////////////////////////////////
// 注意：使用此功能，用户无法下载 STL 文件。建议提供两个版本的 SCAD 文件。
// 参数化模型定制器支持生成多盘模型。为此，您应该为每个盘定义 module。module 的名称应为：
// mw_plate_1(), mw_plate_2() 等。
module mw_plate_1() {
    color("#FF0000") cube([10, 10, 10]);
}

module mw_plate_2() {
    color("#00FF00") cube([10, 10, 10]);
}

// 允许其中一些盘生成空模型。您可以使用此功能使您的代码更具适应性。
// 例如，如果您的模型包含多个零件，您可以通过代码，判断一个盘是否能够容纳所有模型，不可以的时候，
// 才做分盘。
module mw_plate_3() {
    // empty
}

// 您还可以定义一个特定的 module 供用户预览装配视图。module 命名应为：
// mw_assembly_view()。
module mw_assembly_view() {
    mw_plate_1();
    translate([0, 0, 10]) mw_plate_2();
}