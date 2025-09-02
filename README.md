# 每日菜单查询系统

一个简洁实用的纯前端食堂菜单查询和管理系统，支持菜单展示、管理后台和数据导入功能。

## 功能特点

### 🍽️ 菜单展示
- **今日菜单**：快速查看当天的早、中、晚餐安排
- **明日预览**：提前了解明天的菜单
- **日期选择**：可查询任意日期的菜单（限当前日期前后一个月）
- **清晰分类**：早餐分为面条、粥类、点心三种；午餐为四菜一汤加水果
- **响应式设计**：完美适配手机、平板和电脑

### 🔧 管理后台
- **菜单管理**：添加、编辑、删除菜单
- **批量导入**：支持Excel和CSV格式的批量导入
- **模板下载**：提供标准的导入模板
- **数据统计**：查看菜单和用户统计信息

### 📱 推送管理
- **用户配置**：支持多个用户独立配置推送信息
- **推送开关**：灵活控制每个用户的推送状态
- **API Key管理**：安全的API密钥管理

## 技术栈

### 前端
- **Vue 3**：现代化的前端框架
- **Element Plus**：优雅的UI组件库
- **Vite**：快速的构建工具
- **LocalStorage**：本地数据存储

## 快速开始

### 环境要求
- Node.js 16+
- npm 或 yarn

### 安装步骤

1. **克隆项目**
```bash
git clone <repository-url>
cd weekmenu
```

2. **安装依赖**
```bash
cd frontend
npm install
```

3. **启动服务**
```bash
npm run dev
```

4. **访问应用**
- 应用地址：http://localhost:5173

## 项目结构

```
weekmenu/
├── frontend/                 # 前端项目
│   ├── src/
│   │   ├── components/      # 公共组件
│   │   ├── views/          # 页面组件
│   │   │   ├── Home.vue    # 首页菜单展示
│   │   │   └── Admin.vue   # 管理后台
│   │   ├── utils/          # 工具函数
│   │   │   ├── api.js      # API接口
│   │   │   ├── dataStorage.js # 数据存储
│   │   │   └── templateGenerator.js # 模板生成
│   │   └── router/         # 路由配置
│   ├── public/             # 静态资源
│   │   └── data/          # JSON数据文件
│   │       ├── menus.json # 菜单数据
│   │       └── users.json # 用户数据
│   └── package.json
└── README.md
```

## 数据结构

### 菜单数据格式
```json
{
  "id": 1,
  "date": "2025-08-08",
  "breakfast": {
    "noodles": "牛肉面",
    "porridge": "小米粥", 
    "snack": "鲜肉包子"
  },
  "lunch": {
    "dish1": "宫保鸡丁",
    "dish2": "麻婆豆腐",
    "dish3": "青椒土豆丝",
    "dish4": "红烧肉",
    "soup": "冬瓜排骨汤",
    "fruit": "苹果"
  },
  "dinner": {
    "content": ""
  }
}
```

### 用户数据格式
```json
{
  "id": 1,
  "name": "张三",
  "apiKey": "SCT123456789abcdef",
  "pushTime": "08:00",
  "enabled": true
}
```

## 批量导入

系统支持Excel和CSV格式的批量导入：

### 字段说明
- `date`: 日期（YYYY-MM-DD格式）
- `breakfast_noodles`: 早餐面条类（如牛肉面、鸡蛋面等）
- `breakfast_porridge`: 早餐粥类（如小米粥、白粥等）
- `breakfast_snack`: 早餐点心类（如包子、煎饺、蒸饺等）
- `lunch_dish1`: 午餐第一道菜（四菜中的第一道）
- `lunch_dish2`: 午餐第二道菜（四菜中的第二道）
- `lunch_dish3`: 午餐第三道菜（四菜中的第三道）
- `lunch_dish4`: 午餐第四道菜（四菜中的第四道）
- `lunch_soup`: 午餐汤类（四菜一汤中的汤）
- `lunch_fruit`: 午餐水果（餐后水果）
- `dinner_content`: 晚餐内容（暂时保留字段）

### 导入步骤
1. 在管理后台点击"批量导入"
2. 下载Excel或CSV模板
3. 按模板格式填写菜单数据
4. 选择文件并点击"开始导入"

## 数据存储

本系统采用纯前端方案：
- **LocalStorage**：用于存储菜单和用户数据
- **JSON文件**：提供初始数据和模板
- **无后端依赖**：完全在浏览器中运行

### 数据特点
- **自动清理**：只保存当前日期前后一个月的菜单数据
- **本地存储**：数据保存在浏览器本地存储中
- **即时生效**：所有操作立即生效，无需等待服务器响应

## 部署说明

### 开发环境
```bash
cd frontend
npm run dev
```

### 生产环境
```bash
cd frontend
npm run build
```

生成的`dist`目录可以直接部署到任何静态文件服务器，如：
- Nginx
- Apache
- GitHub Pages
- Vercel
- Netlify

## 注意事项

1. **数据范围**：系统只保存和显示当前日期前后一个月的菜单数据
2. **文件大小**：批量导入文件不超过5MB
3. **浏览器兼容**：支持现代浏览器，建议使用Chrome、Firefox、Safari等
4. **数据备份**：数据存储在浏览器LocalStorage中，清除浏览器数据会丢失所有信息
5. **跨设备同步**：不同设备间的数据不会自动同步

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request！