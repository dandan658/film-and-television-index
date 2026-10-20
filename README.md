# Film and Television Index · 液态玻璃版

基于 NAStools v2.9.1 的独立媒体整理版，修改日期：2026-10-20。源码仓库：https://github.com/dandan658/film-and-television-index 。镜像由 GitHub Actions 构建，通过容器启动及登录检查后发布至 GHCR。

## 保留功能

| 板块 | 内容 |
| --- | --- |
| 媒体整理 | 文件管理、手动识别、历史记录、TMDB 缓存 |
| 服务 | 下载完成文件整理、目录同步、整理缓存清理、名称识别测试、规则测试、网络测试、备份恢复 |
| 设置 | 基础设置、用户管理、媒体库、目录同步、消息通知、过滤规则、自定义识别词、索引器、下载器、媒体服务器、字幕、豆瓣 |

移除探索、资源搜索、站点管理、订阅管理、下载管理的导航和页面入口；顶部资源搜索入口也已移除。对应旧 URL、获取资源的操作命令和 API 分组被禁用。站点签到、站点统计刷新、RSS 订阅、订阅搜索、刷流、自动删种及豆瓣自动触发订阅不再启动。

索引器、下载器、豆瓣的设置和底层客户端保留，保证媒体识别、下载完成文件整理、字幕等功能的依赖兼容；这不等于恢复资源搜索、订阅和下载管理。默认进入有权限的第一个保留页面，管理员默认进入文件管理。

## 飞牛本地构建（可选）

1. 将整个 ZIP 解压到飞牛的一个**新目录**，例如 `docker/film-and-television-index`。目录中必须同时存在 `compose.yaml`、`Dockerfile`、`app`、`web` 等文件，不能只上传 YAML。
2. 复制 `.env.example` 为 `.env`，将 `MEDIA_ROOT` 改为实际媒体父目录。例如 `MEDIA_ROOT=/vol1/1000/media`。也可以直接在 `compose.yaml` 中把 `${MEDIA_ROOT:-./media}:/media` 改为 `/你的真实媒体父目录:/media`。
3. 建议一次映射同时包含待整理文件和媒体库的共同父目录，避免硬链接跨挂载失败。容器内用 `/media/待整理` 和 `/media/影视库` 等路径配置目录同步和媒体库。
4. 飞牛 Docker → Compose → 新建项目，项目名称填 `film-and-television-index`，路径选上述解压目录，选择该目录中的 `compose.yaml`，执行构建。
5. 打开 `http://飞牛IP:18510`。全新配置的默认账号为 `admin`，默认密码为 `password`；登录后在基础设置中修改。
6. 配置 TMDB、媒体库、目录同步和媒体服务器。默认映射 `./media` 是新建的空目录，只有把 `MEDIA_ROOT` 改为真实路径后才能看到 NAS 媒体。

终端部署命令（在项目目录运行）：

```sh
docker compose build
docker compose up -d
docker compose logs --tail=100 film-and-television-index
```

首次构建会拉取所指定的 `19970688/nastools-bt` 固定镜像，之后在本地生成 `film-and-television-index:local`。此处为本地构建方式；直接拉取已发布镜像请使用下方的 `compose.nas.yaml`。 所指定基础镜像实际为 `linux/amd64`，本项目据此面向 x86-64 飞牛 NAS。

## 数据与更新

- 数据持久化到本项目 `./data/config`，与原 NAStools、百度自动转存项目分开；端口使用 18510。
- 默认使用新配置，不要将旧容器的数据目录同时挂载给两个运行中的实例。需要迁移时，先停止旧实例并复制其配置到新目录。
- 底层识别、整理、字幕、媒体服务器代码保留；配置文件及数据库格式沿用 2.9.1，没有主动删除旧任务或历史数据。旧的获取资源任务即使存在，也不会在这个版本自动运行。
- 容器入口强制关闭上游自动更新，避免上游覆盖精简修改。更新本地源码后执行 `docker compose up -d --build`。

## 验证范围

已通过 Python 源码编译、9 项本地测试以及实际导航配置的 JavaScript 检查：保留全部 17 个页面入口，移除其他导航，禁用对应 URL 和命令，保留整理调度且不改写配置。测试使用临时样例，不连接 NAS 或真实网盘。

GitHub Actions 已通过真实 linux/amd64 镜像构建、容器启动、默认账号登录、全部 17 个保留页面 HTTP 检查和源码包下载校验。真实 NAS 文件整理、目录监控以及第三方服务连接仍需在你的环境验证。

本地测试：

```sh
python -m unittest discover -s tests -p test_media_profile.py -v
node scripts/check_navigation.cjs
```

## 源码与许可

上游为 [NAStools v2.9.1 源码存档](https://github.com/NewBeesX/nas-tools-v2.9.1/tree/e3a43d4f0896db49de02e9a9201ef2e5877af56f)，基础镜像为 [19970688/nastools-bt](https://hub.docker.com/r/19970688/nastools-bt)。版本和摘要记录在 `UPSTREAM.json`。原项目说明见 `README_UPSTREAM.md`，原版权及 AGPL-3.0 许可保留在 `LICENSE.md`。

本修改版本继续以 AGPL-3.0 提供，无担保。构建时生成仅包含项目源文件的源码包，运行界面底部版本链接可下载 `/project-source.zip`；不会打包挂载的配置、媒体或 `.env`。运行依赖复用固定基础镜像，第三方子模块引用见 `.gitmodules` 与 `THIRD_PARTY.lock.json`。

## 液态玻璃界面（v1.1.0）

保留媒体整理与设置页面的原版模板、表单字段、弹窗、提交事件和后台接口。共享样式覆盖登录、导航、表格、表单、弹窗、通知和深浅色主题；窄屏表格横向滚动，弹窗内容独立滚动。保留减少动态效果系统偏好。模糊仅用于导航和浮层，列表行不使用模糊，避免大量记录重复合成。

这次修改是界面换肤，不新增云盘或文件处理引擎。原版功能仍需要有效的 TMDB、NAS 路径和客户端配置。真实 NAS 转移、同步和第三方服务连接尚未验证。

## 直接拉取部署

NAS 使用 `compose.nas.yaml`，镜像为 `ghcr.io/dandan658/film-and-television-index:latest`，适用 x86-64 NAS。将媒体父目录映射改为实际路径，配置目录 `./data/config` 更新时保留。端口为 `18510`。`pull_policy: always` 会在部署/重建时检查最新镜像，运行中的容器不会自行更新。也可 `docker compose -f compose.nas.yaml pull && docker compose -f compose.nas.yaml up -d`。本地构建仍使用 `compose.yaml`。
