# Extranet Hosting Admin Portal 前端需求整合文档
## 文档概述
本文档整合原始功能规范文档 + 线上Portal实际界面截图，梳理**已实现功能、文档缺失功能点、标准操作流程、表单字段校验、权限体系**，区分「原始文档定义」「界面已落地实现」「待完善补充细节」三部分内容。
系统分为两大核心模块：
1. EH Application（外网托管网关应用配置）
2. Friendly URL（友好URL重定向映射）

---
## 一、系统整体页面导航结构
左侧菜单栏固定5个功能入口（界面截图落地，原始文档仅分功能场景，未整理导航树）
1. My Application（我的应用，界面可见，原始文档无描述）
2. Search Application（网关应用查询）
3. Create Application（新建网关应用）
4. Search Friendly URL（友好URL查询）
5. Create Friendly URL（新建友好URL）

> 文档缺失点：原始规范文档未提及 `My Application` 页面模块，界面已存在该菜单入口。

---
## 模块一：EH Application 外网托管网关应用
### 1.1 功能总览对比
| 功能场景 | 原始文档是否定义 | 界面是否落地实现 | 补充说明 |
| ---- | ---- | ---- | ---- |
| 新建EH应用 | ✅ 完整流程定义 | ✅ 完整多标签表单落地 | 7大配置标签页全部UI实现 |
| 查询EH应用 | ✅ 流程定义 | ✅ 域名+路径搜索列表页 | 列表展示完整元数据、支持排序 |
| 修改已有EH应用 | ✅ 流程定义 | ✅ Edit编辑全标签页 | Host Domain/Context Path 创建后只读 |
| 删除EH应用 | ✅ 流程定义 | ✅ Delete删除按钮 | 弹窗二次确认逻辑 |
| 版本管理/审计日志 | ✅ 标签页定义 | ✅ Version Management标签页 | 查看变更历史、对比版本 |

### 1.2 Search By Web Domain or Context Path（应用查询页面）
#### 1.2.1 页面UI（截图落地细节，原始文档部分缺失展示字段）
1. 搜索条件
    - Host Domain：下拉选择框（必填，示例值`int-eh-gateway-cname1.nomura.com`）
    - Context Path：文本输入框（可选模糊检索）
2. 结果列表表头（界面落地完整字段）
    - Context Path、CMDB、Environment、Last Updated、Updated By、Status
3. 列表特性
    - 列支持排序、状态视觉标绿（ACTIVE）
    - 每条行可点击进入编辑详情页
#### 1.2.2 文档缺失落地细节
1. 原始文档Advanced Search（高级搜索）标注TBD，当前界面未实现高级筛选项；
2. 原始文档提及「导出CSV/Excel」，界面无导出按钮，暂未落地；
3. 原始文档分页描述，截图未展示分页控件，待确认是否实现。

### 1.3 新建/编辑EH应用 多标签表单完整规范
#### 约束前置（文档+界面统一规则）
- Host Domain、Context Path **创建后只读，编辑不可修改**；
- 所有修改必须填写`Version Comment`变更备注，点击Update生成新版本；
- 全局校验：字段不符合规则标红提示，API失败弹窗返回错误原因。

##### 标签1：Basic 基础配置
1. 表单字段

| 字段名 | UI组件 | 输入约束 | 业务用途 |
| ---- | ---- | ---- | ---- |
| Application Instance(CMDB) | 可搜索下拉单选 | 必须存在有效CMDB条目 | 绑定资产用于审计治理 |
| Host Domain | 只读文本框（编辑态）/下拉（新建态） | 合法域名、禁止IP | 网关访问域名 |
| Context Path | 只读文本框（编辑态）/文本输入（新建态） | 不能以`/`开头、无非法字符 | 路由唯一路径前缀 |
| Application Status | 单选开关 | Enable/Disable | 启停该网关路由 |
| Keep Context Path Aligned | 单选Yes/No | 布尔 | 控制路径重写时是否保留原路径 |
| Access Point | 单选 | Public Outer / Public Inner | 区分内外网访问入口 |
| Business Description | 多行文本（选填） | 无强制校验 | 业务用途备注 |
2. 界面落地补充：底部操作按钮 Delete / Role Management / clone复制 / Update 保存更新
3. 文档缺失：原始文档未描述`Role Management`角色权限按钮、`clone`复制应用按钮，界面已实现。

##### 标签2：Backends 后端服务配置
1. 支持多后端条目增删，每条后端独立配置

| 字段 | UI | 约束 | 示例配置（截图实例） |
| ---- | ---- | ---- | ---- |
| Access Point | 下拉 | 必须和Basic标签Access Point一致 | Public Outer |
| Region | 下拉单选 | 数据中心地域列表 | UK |
| Data Center | 下拉单选 | 地域对应机房 | AHI |
| Endpoint | 文本 | 合法内网主机名 | jpn022935.nomura.com |
| Port | 数字输入 | 1-65535 | 8080 |
| Protocol | 下拉 | HTTP/HTTPS | HTTP |
| HTTP Version | 下拉 | 1.1 / 1.0 / 2.0(disable) | 1.1 |
| Host Rewrite | 单选Yes/No | 布尔 | No |
| Connection Timeout | 数字滑块输入 | 1000-30000ms | 4000 |
| Query Timeout | 数字滑块输入 | 1000-30000ms | 4000 |
| Enable Proxy | 单选Yes/No | 布尔 | No |
| Disable Backend | 单选Yes/No | 临时禁用后端不删除 | No |
2. 文档缺失：原始文档仅定义字段，界面增加单条后端独立Delete删除按钮，批量添加按钮；

##### 标签3：Cookie Management Cookie管理
1. 顶层默认策略单选：`Persist` / `Passthrough`（截图实例默认选Passthrough）
    - Passthrough：Cookie原样透传给后端；Persist：网关本地持久化
2. Excluded Cookies 例外Cookie列表（和默认策略反向执行）
    - 支持多行新增、删除条目
    - 每条配置：Cookie名称、`Starts With`前缀匹配复选框
    - 示例配置：`startWith`（前缀匹配）、`cookie-sample`（完整名称匹配）
3. 文档对齐：原始文档规则100%落地UI，无缺失

##### 标签4：Custom Headers 自定义请求响应头
分三大块：Cache-Control、Request Headers、Response Headers、CSP安全头
1. Cache-Control
    - 开关：Yes/No，匹配MIME类型设置缓存时长
2. Request Headers：动态增删键值对，网关转发给后端
3. Response Headers：动态增删键值对，网关返回给客户端
4. CSP Content-Security-Policy 安全头
    - 三模板快捷按钮：STRICT / BASIC / CUSTOM
    - 自定义指令键值对增删、Override Existed Value覆盖原有头复选框
    - 截图实例STRICT模板预置：`object-src 'none'`、`script-src nonce random strict-dynamic`等指令
5. 文档补充：原始文档定义CSP模板，界面可视化指令编辑，比文档描述更细化

##### 标签5：Limiter 限流&访问控制
1. Request Throttling 请求限流
    - Call Limit Type：Concurrent并发数 / Rate每秒频次
    - Maximum Concurrent Requests：最小1最大1000（示例配置5）
2. HTTP Methods 允许请求方法
    - 输入框添加+标签展示已选，可点X删除
    - 截图示例仅放行GET，POST/PUT/DELETE禁用
3. IP Access Control IP黑白名单
    - Disallowed Client IPs：禁止访问IP/CIDR段
    - Allowed Skip Limit Client IPs：白名单IP（不受限流约束）
    - 每条IP输入后点Add加入列表，支持删除
4. 文档对齐：规则完全落地，界面可视化黑白名单列表

##### 标签6：Body Decoration 页面装饰&错误掩码
1. 全局开关
    - Extranet Under Maintenance：Yes=开启维护页 / No=正常服务
    - Mask Exceptions：Yes=屏蔽后端原始错误栈，返回统一页面
2. 错误页面自定义配置：标题、联系邮箱、电话、标签、多语言配置
3. 文档对齐：原始文档字段全部UI落地

##### 标签7：Version Management 版本管理（仅编辑态可见）
1. 只读列表：Version History版本变更记录、Audit Log审计日志
2. 操作按钮：Compare对比两个版本、回滚部署状态
3. 文档缺失：原始文档仅描述用途，界面展示操作按钮，文档无按钮交互流程

### 1.4 删除EH应用流程（文档+界面统一）
1. 应用详情页点击左下角Delete按钮
2. 弹窗二次确认，展示风险信息：域名路径、流量影响、CMDB关联、用户影响
3. 输入删除原因、确认应用ID后执行API删除
4. 成功后列表移除条目/标记inactive

### 1.5 EH应用权限体系（文档定义，界面隐含Role Management按钮）
1. 角色分级：Super Admins、App Creator、普通组用户
2. 权限层级：VIEW只读 / Modification编辑 / Delete删除
3. 权限继承：应用绑定CMDB后，支持组内权限继承
4. 界面补充：每个应用详情页自带`Role Management`按钮，可配置分组权限，原始文档仅文字描述，未说明页面入口

---
## 模块二：Friendly URL 友好URL重定向映射
### 2.1 功能场景对比
| 功能 | 原始文档定义 | 界面落地 | 差异 |
| ---- | ---- | ---- | ---- |
| 新建友好URL | ✅ 完整流程 | ✅ 独立新建表单页 | 字段完全匹配文档 |
| 查询友好URL | ✅ 流程 | ✅ 专属Search页面 | 支持双维度检索、列表展示元数据 |
| 修改友好URL | ✅ 流程 | ✅ Edit编辑页 | Host Domain编辑态只读 |
| 删除友好URL | ✅ 流程 | ✅ Delete按钮 | 确认弹窗风险提示 |

### 2.2 Search Friendly URL 查询页面
1. 搜索条件
    - Host Domain 下拉必选
    - Keyword 模糊搜索框
    - 检索范围复选框：Friendly URL / Target URL 双匹配
2. 列表展示字段（界面落地，文档补充缺失列）
    - From Path(友好路径)、Target URL(目标地址)、Append Path(是否允许子路径拼接)、Linked CMDB(绑定资产)
3. 文档缺失点
    1. 原始文档提及API示例`GET /api/friendly-urls/search`，前端界面无API调试展示；
    2. 高级搜索TBD项（创建时间、重定向码、所有者UID）界面未实现；
    3. 导出CSV功能文档提及，界面无导出按钮；
4. 列表实例数据截图：
    - `/NNGTEST-home` Append Path=No
    - `/NNGTEST-home-rewrite` Append Path=Yes

### 2.3 Create New Friendly URL 新建表单页面
表单字段完整映射
| 字段 | UI组件 | 约束规则 | 默认值 |
| ---- | ---- | ---- | ---- |
| Host Domain | 下拉单选 | 合法域名，编辑态只读 | 必填无默认 |
| Friendly URL Name | 文本输入 | 合法URL路径 | 必填 |
| Target Full/Relative URL | 文本输入 | 完整URL或相对路径 | 必填 |
| Allow Appending Sub-Paths | 复选框布尔 | Yes/No | 默认勾选Yes |
| Redirection Status Code | 下拉单选 | 301/302/307/308 | 默认302(Found) |
| label.eh.friendly.mode | 下拉模式 | normal等模式 | label.eh.friendly.mode.normal |
| Associated Application Instance | CMDB可搜索下拉 | 有效CMDB资产 | 必填 |
底部操作按钮：Save保存 / Reset重置
> 文档完全匹配UI，无缺失字段

### 2.4 修改/删除Friendly URL流程
1. 修改：列表行点击Edit，Host Domain锁定只读，其余字段可编辑，填写变更备注后Update提交；
2. 删除：列表Delete唤起确认弹窗，展示域名、路径、关联应用、流量影响，确认后调用API移除；

### 2.5 Friendly URL业务价值（文档定义，界面无展示说明）
1. 简化对外访问路径、SEO优化；
2. 解耦前端访问路径和后端真实架构；
3. 系统平滑迁移，新旧路径共存兼容。

---
## 三、全局公共交互规则（文档+界面合并）
### 3.1 表单全局校验逻辑
1. 输入失焦/点击提交时实时校验；
2. 非法字段标红+悬浮提示文案；
3. 提交前全局校验汇总，弹窗展示所有错误项，全部修复才可提交；
4. 后端API异常：弹窗展示失败原因（权限、冲突、参数错误、服务异常）；
5. 并发编辑冲突：提示刷新页面拉取最新配置再编辑。

### 3.2 操作变更追溯
1. 所有Create/Update/Delete操作强制填写版本注释；
2. 每条变更生成独立版本快照，记录操作人、时间、修改前后值；
3. Version Management标签页支持跨版本对比差异。

### 3.3 按钮统一规范
1. 红色危险按钮：Delete删除、Reset重置；
2. 蓝色主操作按钮：Update保存、Save新建、Add新增条目；
3. 辅助功能按钮：Role Management权限、clone复制应用；

---
## 四、原始文档未覆盖、界面已实现的新增功能清单
1. **My Application** 左侧菜单独立页面（原始文档完全无定义）
2. EH应用详情页专属按钮：
    - `Role Management`：应用级权限配置弹窗
    - `clone`：一键复制当前应用配置生成新应用模板
    - 单条Backend后端独立删除按钮（文档只描述批量增删）
3. Friendly URL查询列表无导出按钮、高级搜索TBD未落地
4. EH应用查询列表无CSV导出、分页控件截图未呈现
5. Version Management标签页可视化版本对比按钮（文档仅文字描述）
6. Cookie管理前缀匹配`Starts With`可视化勾选控件（文档规则匹配UI）
7. CSP安全头三模板快捷一键填充（文档只区分模板类型，无快捷按钮描述）

## 五、待后续补充细化需求点
1. My Application页面完整功能需求、展示字段、筛选逻辑；
2. clone复制应用的字段继承规则、CMDB是否允许修改、版本注释自动填充规则；
3. Role Management权限弹窗的用户/组选择树、权限勾选UI细节；
4. 分页控件每页条数、页码跳转、批量操作逻辑；
5. CSV导出文件列模板、下载弹窗、权限控制；
6. 高级搜索（TBD）排期与UI交互原型；
7. 维护页面、错误掩码页面的自定义HTML模板上传能力（当前仅文本配置）；
8. 操作日志全局导出、审计报表页面需求。

## 六、标准操作流程示例（NNGTEST-Dynamic-Template实例）
### 示例：编辑现有EH应用完整步骤
1. 左侧菜单打开`Search Application`
2. Host Domain选择`int-eh-gateway-cname1.nomura.com`，点击搜索
3. 列表找到`NNGTEST-Dynamic-Template`行，点击进入详情编辑页
4. 切换各标签修改配置：
    - Backends：调整超时时间/新增后端节点
    - Cookie Management：新增例外Cookie前缀
    - Limiter：调整并发上限、放行POST方法
    - Custom Headers：更新CSP安全指令
5. 填写底部Version Comment变更说明
6. 点击Update按钮提交
7. 系统校验通过生成新版本，Version Management标签页可查看本次变更记录
8. 如需回滚：进入Version Management选择旧版本执行回滚操作

### 示例：创建Friendly URL映射
1. 左侧`Create Friendly URL`打开新建表单
2. Host Domain选择`int-eh-gateway-cname1.nomura.com`
3. Friendly URL Name填写对外路径 `/new-test-path`
4. Target URL填写后端真实上下文 `/NNGTEST-Dynamic-Template/api`
5. 勾选Allow Appending Sub-Paths，重定向码保持302
6. 绑定对应DashWorks - AS QA CMDB实例
7. 点击Save保存，保存后可在Search Friendly URL列表检索到这条映射

---
## Markdown文件使用说明
1. 本文档可直接复制保存为 `ExtranetHosting_AdminPortal_Req.md`；
2. 可拆分模块分给前端、测试、后端对照排期；
3. 「文档缺失」「待补充」标记项可作为迭代需求任务拆分；
4. 实例基于截图中`int-eh-gateway-cname1.nomura.com` QA环境模板配置。