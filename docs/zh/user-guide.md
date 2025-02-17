---
title: 用户手册
---

**修订记录**

| **版本** | **日期** | **作者/评审者** | **变更内容** | **变更原因** |
| --- | --- | --- | --- | --- |
| 1.0 | 2024-12-12 | 王运来 | | 创建 |


# 1 插件安装
OceanBase 目前支持使用 C/C++ 编写的动态链接库插件。为了让插件在 OceanBase 系统中生效，用户需要按照以下步骤进行安装和配置：

**1. 准备动态链接库**

首先，准备好 C/C++ 动态链接库插件。例如，你的动态链接库文件名可能为 `libob_jieba_ftparser.so` 和 `libexample_ftparser.so`。

**2. 分发动态链接库**

将动态链接库文件复制到每个 OceanBase observer 进程的 `plugin_dir` 目录下。这个目录在 observer 运行时工作目录中。

```bash
# 假设 plugin_dir 为 /path/to/plugin_dir
scp libob_jieba_ftparser.so user@observer_node1:/path/to/plugin_dir/
scp libexample_ftparser.so user@observer_node2:/path/to/plugin_dir/
```

> scp 是一个基于ssh方便在两台机器之间传输文件的命令，你也可以使用其它方式传输文件。

注意，如果某个插件有其它依赖内容，需要按照具体插件的要求操作。

**3. 配置插件加载**

可以通过命令行参数或配置项来指定在启动进程时加载的插件。需要注意的是，命令行参数会覆盖配置文件中的配置。

+ **命令行参数**：`-L` 或 `--plugins_load`
+ **配置项**：`plugins_load`

参数格式均为 `"libob_jieba_ftparser.so:on,libexample_ftparser.so:off"`，其中 `libob_jieba_ftparser.so` 和 `libexample_ftparser.so` 是动态链接库的名字，`on` 和 `off` 是加载选项，分别表示加载和不加载某个动态链接库，`on` 是默认值。

多个动态链接库用 `,` 分隔。

**通过命令行参数加载插件**

在启动 observer 进程时，可以使用 `-L` 或 `--plugins_load` 参数来指定要加载的插件。例如：

``` bash
observer -L "libob_jieba_ftparser.so:on,libexample_ftparser.so:off"
# 或者
observer --plugins_load "libob_jieba_ftparser.so:on,libexample_ftparser.so:off"
```

**通过配置文件加载插件**

在 OceanBase 中修改配置项 `plugins_load`。例如：

``` sql
alter system set plugins_load='libob_jieba_ftparser.so:on,libexample_ftparser.so:off';
```

系统重启后将会加载 `libob_jieba_ftparser.so`。

需要注意的是，配置项修改需要在`sys`租户执行，并且需要重新启动 observer 进程才能生效。

**4. 确保每个节点都配置正确**

请确保在 OceanBase 集群中，每个 observer 节点的 `plugin_dir` 目录下都放置了相应的动态链接库文件。此外，如果使用命令行参数设置，需要保证每个进程的参数都是相同的。

**5. 重启 observer 进程**

如果通过修改配置项来指定插件加载，需要重新启动 observer 进程使配置生效：

``` bash
# 重新启动 observer 进程
killall observer
# 进入observer的工作目录
cd /path/to/observer
# 启动observer进程。
./bin/observer
```

> observer 进程启动时，会记住上次启动时指定的参数，除非你使用参数修改某一项。

**6. 检查确认安装成功**

任意租户的用户登录 OceanBase，执行下面的语句可以检查确认插件是否安装成功。

``` sql
select * from oceanbase.GV$OB_PLUGINS;
```

结果示例

``` sql
obclient> select * from oceanbase.GV$OB_PLUGINS;
+-----------+----------+-------------------+--------+----------+-------------------------+-----------------+-------------------+-------------------+-----------------------+---------------+---------------------------------------------+
| SVR_IP    | SVR_PORT | NAME              | STATUS | TYPE     | LIBRARY                 | LIBRARY_VERSION | LIBRARY_REVISION | INTERFACE_VERSION | AUTHOR                | LICENSE       | DESCRIPTION                                 |
+-----------+----------+-------------------+--------+----------+-------------------------+-----------------+------------------+-------------------+-----------------------+---------------+---------------------------------------------+
| 127.0.0.1 |    55801 | ngram             | READY  | FTPARSER | NULL                    | 1.0.0           | NULL             | 0.1.0             | OceanBase Corporation | Mulan PubL v2 | This is a ngram fulltext parser plugin.     |
| 127.0.0.1 |    55801 | beng              | READY  | FTPARSER | NULL                    | 1.0.0           | NULL             | 0.1.0             | OceanBase Corporation | Mulan PubL v2 | This is a basic english parser plugin.      |
| 127.0.0.1 |    55801 | ob_jieba_ftparser | READY  | FTPARSER | libob_jieba_ftparser.so | 0.1.0           |                  | 0.1.0             | OceanBase Corporation | Mulan PSL v2  | jieba full text parser for oceanbase(demo). |
| 127.0.0.1 |    55801 | space             | READY  | FTPARSER | NULL                    | 1.0.0           | NULL             | 0.1.0             | OceanBase Corporation | Mulan PubL v2 | This is a default whitespace parser plugin. |
+-----------+----------+-------------------+--------+----------+-------------------------+-----------------+------------------+-------------------+-----------------------+---------------+---------------------------------------------+
4 rows in set (0.09 sec)
```

插件加载失败，不会在表中展示。

注意表中会展示一些内置插件，内置插件的 `LIBRARY` 字段为 `NULL`。

通过上述步骤，你可以成功地在 OceanBase 中安装和配置动态链接库插件，从而扩展 OceanBase 的功能。记住，命令行参数会覆盖配置文件中的设置，确保配置一致性和正确性，保证插件功能的正常加载和运行。

# 2 插件卸载
用户通过命令行参数或配置项来控制observer加载哪些插件，那插件卸载的方法是一样的，在命令行参数或配置项中去掉想要卸载的插件，再重新启动进程即可。

下面以配置项为例说明如何卸载插件。

假设当前系统中已经安装了`libob_jieba_ftparser.so`插件，我们要卸载。

**1. 修改配置项**

```sql
alter system set plugins_load='libob_jieba_ftparser.so:off';
-- 或
alter system set plugins_load='';
```

**2. 重启进程**

**3. 检查确认**

``` sql
select * from oceanbase.GV$OB_PLUGINS;
```

可能会看到

``` sql
obclient> select * from oceanbase.GV$OB_PLUGINS;
+-----------+----------+-------+--------+----------+---------+-----------------+------------------+-------------------+-----------------------+---------------+---------------------------------------------+
| SVR_IP    | SVR_PORT | NAME  | STATUS | TYPE     | LIBRARY | LIBRARY_VERSION | LIBRARY_REVISION | INTERFACE_VERSION | AUTHOR                | LICENSE       | DESCRIPTION                                 |
+-----------+----------+-------+--------+----------+---------+-----------------+------------------+-------------------+-----------------------+---------------+---------------------------------------------+
| 127.0.0.1 |    55801 | ngram | READY  | FTPARSER | NULL    | 1.0.0           | NULL             | 0.1.0             | OceanBase Corporation | Mulan PubL v2 | This is a ngram fulltext parser plugin.     |
| 127.0.0.1 |    55801 | beng  | READY  | FTPARSER | NULL    | 1.0.0           | NULL             | 0.1.0             | OceanBase Corporation | Mulan PubL v2 | This is a basic english parser plugin.      |
| 127.0.0.1 |    55801 | space | READY  | FTPARSER | NULL    | 1.0.0           | NULL             | 0.1.0             | OceanBase Corporation | Mulan PubL v2 | This is a default whitespace parser plugin. |
+-----------+----------+-------+--------+----------+---------+-----------------+------------------+-------------------+-----------------------+---------------+---------------------------------------------+
3 rows in set (0.14 sec)
```

# 3 插件使用
插件的使用方法取决于它实现的功能，不能直接对插件做操作。下面以分词器插件为例，说明插件的使用。

假设系统中安装了 `libob_jieba_ftparser.so`，那么我们在创建带有全文索引的表时，就会用到这个插件。

执行下面的语句创建使用 `jieba` 分词器的全文索引

``` sql
create table t_jieba(c1 int, c2 varchar(200), c3 text, fulltext index (c2, c3) with parser ob_jieba_ftparser);
```

其中 `ob_jieba_ftparser`是 `libob_jieba_ftparser.so`提供的分词器名称。

向表中插入数据

``` sql
INSERT INTO t_jieba (c1, c2, c3) VALUES(1, '测试一', '这是一个测试文本，用于测试结巴分词器的功能。');
```

得到结果

``` sql
obclient> select * from t_jieba where  match(c2, c3) against ('测试')>0;
+------+-----------+--------------------------------------------------------------------+
| c1   | c2        | c3                                                                 |
+------+-----------+--------------------------------------------------------------------+
|    1 | 测试一    | 这是一个测试文本，用于测试结巴分词器的功能。                       |
+------+-----------+--------------------------------------------------------------------+
1 row in set (0.05 sec)
```

查询测试

``` sql
select * from t_jieba where  match(c2, c3) against ('测试')>0;
```

查询匹配分数

``` sql
select c1, match (c2, c3) against ('今天的天气不错') as score,c2,c3 from t_jieba;
```

得到结果

``` sql
obclient> select c1, match (c2, c3) against ('今天的天气不错') as score,c2,c3 from t_jieba;
+------+--------------------+-----------+--------------------------------------------------------------------+
| c1   | score              | c2        | c3                                                                 |
+------+--------------------+-----------+--------------------------------------------------------------------+
|    1 | 0.2075471698113208 | 测试一    | 这是一个测试文本，用于测试结巴分词器的功能。                       |
+------+--------------------+-----------+--------------------------------------------------------------------+
1 row in set (0.01 sec)
```

# 4 插件升级
插件升级时，需要将对应的插件库替换为新版本的链接库，然后重启进程加载。建议在集群环境对observer进程依次重启并替换插件。

## 4.1 插件升级示例
下面以一个observer进程的插件替换升级为例介绍。

1. **停止observer进程**

``` bash
killall observer
```

2. **将新版本动态链接库放到 **`**plugin_dir**`**目录**

``` bash
# /path/to/plugin_dir/ 是插件链接库目录
scp libob_jieba_ftparser.so user@observer_node1:/path/to/plugin_dir/
```

3. **重新启动进程**

``` bash
cd /path/to/observer
./bin/observer
```

注意，在进程停止之前，**不要替换动态链接库**，否则可能会出现不可预知的错误。

## 4.2 使用链接库版本号，让升级更安全
由于我们不能直接覆盖正在运行进程使用的动态链接库，我们可以给动态链接库增加版本号，结合软链接的方式可以更加安全地升级。

假设我们现在系统中正在使用动态链接库 `libob_jieba_ftparser.so.1.0.0`，在 observer `plugin_dir`目录下：

``` bash
bash > ls -l libob_jieba_ftparser.so*
lrwxrwxrwx 1 user users       29 Dec 13 14:57 libob_jieba_ftparser.so -> libob_jieba_ftparser.so.1.0.0
-rwxr-xr-x 1 user users 14366880 Dec 12 20:17 libob_jieba_ftparser.so.1.0.0
```

其中 `libob_jieba_ftparser.so.1.0.0` 是真实动态链接库，`libob_jieba_ftparser.so` 是指向 `libob_jieba_ftparser.so.1.0.0`的软连接。

现在假设需要升级 `libob_jieba_ftparser.so.1.0.0`为 `libob_jieba_ftparser.so.1.1.0`，先将软连接指向新的链接库：

``` bash
# 创建软链接
bash > ln -sf libob_jieba_ftparser.so.1.1.0 libob_jieba_ftparser.so
# 查看软链接
bash > ls -l libob_jieba_ftparser.so*
lrwxrwxrwx 1 user users       29 Dec 13 14:59 libob_jieba_ftparser.so -> libob_jieba_ftparser.so.1.1.0
-rwxr-xr-x 1 user users 14366880 Dec 12 20:17 libob_jieba_ftparser.so.1.0.0
-rwxr-xr-x 1 user users 14366880 Dec 13 14:59 libob_jieba_ftparser.so.1.1.0
```

操作完成后，我们直接重启 observer 进程即可。

# 5 常见问题
## 5.1 进程启动后没有安装的插件
使用配置项或命令行参数指定加载某个插件，但是进程启动后通过 DBA_OB_PLUGINS 视图看不到这个插件的信息，说明插件安装失败。可以在日志目录下查看 alter 日志，具体位置是 `log/alert/alert.log`。在日志中搜索 `OB_SERVER_LOAD_DYNAMIC_PLUGIN_FAIL`，可以看到具体失败的原因，比如：

``` bash
2024-12-13 10:56:05.929903|WARN|SHARE|OB_SERVER_LOAD_DYNAMIC_PLUGIN_FAIL|-4000|0|60777|observer|Y0-0000000000000001-0-0|load_dynamic_plugins|ob_plugin_mgr.cpp:501|"install dynamic library failed or init plugin failed: libob_not_exist_ftparser.so"
```

示例日志中的原因是动态链接库不存在，需要检查此链接库确实放在了对应的 `plugin_dir`目录中。

如果 alert.log 中的原因不是很明确，可以通过 `trace id`在日志目录中搜索，这里的 `trace id`是 `Y0-0000000000000001-0-0`，那么就可以在 `log`目录下搜索该日志确认更明确的原因。

``` bash
grep Y0-0000000000000001-0-0 observer.log*
```

