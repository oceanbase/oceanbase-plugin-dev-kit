# 简介
<div align="left">

[![Chinese Doc](https://img.shields.io/badge/文档-简体中文-blue)](https://oceanbase.github.io/oceanbase-plugin-dev-kit/)

</div>

随着数据库技术的发展和业务需求的不断变化，灵活性和可扩展性已成为现代数据库系统的核心要求。为了满足用户对高效、灵活的功能扩展需求，OceanBase 推出了插件机制，使得扩展 OceanBase 的功能变得更加轻松和高效。 OceanBase 插件机制的主要特点包括：

**简化扩展：**通过插件机制，用户可以轻松地为 OceanBase 添加新的功能模块，无需修改核心代码。这种模块化设计使得功能扩展变得更加方便和直观。

**高效更新：**插件机制支持快速迭代更新，用户可以及时获取和应用最新的功能改进和修复。这种快速响应的能力，确保了系统能够始终处于最佳状态，满足不断变化的业务需求。

**定制化功能：**插件机制允许用户根据自身业务需求定制特定功能，提高系统的灵活性和适应性。用户可以选择性地加载或卸载插件，确保系统始终运行需要的功能模块。

**社区和生态支持：**通过插件机制，OceanBase 用户可以共享和发布自定义插件，促进社区的交流与合作，丰富插件生态系统。这样不仅提升了 OceanBase 的功能多样性，还推动了整个社区的发展。

**实验室特性：**目前，OceanBase 插件机制仍属于实验室特性阶段，且仅支持分词器插件。这意味着插件功能正在不断优化和扩展中，用户可以提前体验这些新特性并提供反馈，帮助完善系统功能。

总之，OceanBase 的插件机制使得数据库系统的功能扩展和更新更加高效、灵活和可控。无论是增加新的功能模块，还是定制专属应用，都可以通过插件轻松实现。通过这一机制，OceanBase 能够更好地满足用户的多样化需求，助力企业实现业务的快速增长和创新。

本仓库维护OceanBase的插件开发包：
- 插件开发包打包（开发头文件位于[OceanBase](https://github.com/oceanbase/oceanbase)源码[src/plugin/include/oceanbase](https://github.com/oceanbase/oceanbase/tree/master/src/plugin/include/oceanbase)下）；
- 示例代码。参考 src/examples 目录；
- 插件开发文档。

# 文档
为了方便用户使用插件和开发者开发插件，我们提供了必要的文档：

- [使用手册](https://oceanbase.github.io/oceanbase-plugin-dev-kit/user-guide/)：介绍如何安装卸载插件；
- [开发手册](https://oceanbase.github.io/oceanbase-plugin-dev-kit/how-to-dev/)：介绍如何开发一个插件；
- [API 手册](https://oceanbase.github.io/oceanbase-plugin-dev-kit/doxy/html/index.html)；
- [新增插件](https://oceanbase.github.io/oceanbase-plugin-dev-kit/add-new-plugin/)：如何给OceanBase新增一个类型的插件。

如果有任何问题或建议，欢迎提[Issue](https://github.com/oceanbase/oceanbase-plugin-dev-kit/issues)。
