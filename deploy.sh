#!/bin/bash

# 每日菜单查询系统 - 容器化部署脚本
# 适用于Debian服务器

set -e

echo "🚀 开始部署每日菜单查询系统..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker未安装，正在安装...${NC}"
        install_docker
    else
        echo -e "${GREEN}✅ Docker已安装${NC}"
    fi
}

# 检查Docker Compose是否安装
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose未安装，正在安装...${NC}"
        install_docker_compose
    else
        echo -e "${GREEN}✅ Docker Compose已安装${NC}"
    fi
}

# 安装Docker
install_docker() {
    echo -e "${BLUE}📦 安装Docker...${NC}"
    
    # 更新包索引
    sudo apt-get update
    
    # 安装必要的包
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # 添加Docker官方GPG密钥
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # 设置稳定版仓库
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # 安装Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # 启动Docker服务
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # 将当前用户添加到docker组
    sudo usermod -aG docker $USER
    
    echo -e "${GREEN}✅ Docker安装完成${NC}"
}

# 安装Docker Compose
install_docker_compose() {
    echo -e "${BLUE}📦 安装Docker Compose...${NC}"
    
    # 下载Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    
    # 添加执行权限
    sudo chmod +x /usr/local/bin/docker-compose
    
    echo -e "${GREEN}✅ Docker Compose安装完成${NC}"
}

# 创建数据目录
create_data_directory() {
    echo -e "${BLUE}📁 创建数据目录...${NC}"
    
    if [ ! -d "./data" ]; then
        mkdir -p ./data
        echo -e "${GREEN}✅ 数据目录创建完成${NC}"
    else
        echo -e "${YELLOW}⚠️  数据目录已存在${NC}"
    fi
}

# 构建和启动容器
deploy_containers() {
    echo -e "${BLUE}🔨 构建和启动容器...${NC}"
    
    # 停止现有容器（如果存在）
    docker-compose down 2>/dev/null || true
    
    # 构建镜像
    echo -e "${BLUE}📦 构建Docker镜像...${NC}"
    docker-compose build --no-cache
    
    # 启动容器
    echo -e "${BLUE}🚀 启动容器...${NC}"
    docker-compose up -d
    
    # 等待容器启动
    echo -e "${BLUE}⏳ 等待容器启动...${NC}"
    sleep 10
    
    # 检查容器状态
    if docker-compose ps | grep -q "Up"; then
        echo -e "${GREEN}✅ 容器启动成功${NC}"
    else
        echo -e "${RED}❌ 容器启动失败${NC}"
        docker-compose logs
        exit 1
    fi
}

# 显示部署信息
show_deployment_info() {
    echo -e "\n${GREEN}🎉 部署完成！${NC}"
    echo -e "${BLUE}📋 部署信息：${NC}"
    echo -e "  • 应用地址: ${YELLOW}http://localhost:8080${NC}"
    echo -e "  • 应用地址: ${YELLOW}http://$(hostname -I | awk '{print $1}'):8080${NC}"
    echo -e "  • API地址: ${YELLOW}http://localhost:8080/api${NC}"
    echo -e "  • 容器名称: ${YELLOW}weekmenu-app${NC}"
    echo -e "  • 数据目录: ${YELLOW}./data${NC}"
    
    echo -e "\n${BLUE}🔧 常用命令：${NC}"
    echo -e "  • 查看容器状态: ${YELLOW}docker-compose ps${NC}"
    echo -e "  • 查看日志: ${YELLOW}docker-compose logs -f${NC}"
    echo -e "  • 停止服务: ${YELLOW}docker-compose down${NC}"
    echo -e "  • 重启服务: ${YELLOW}docker-compose restart${NC}"
    echo -e "  • 更新应用: ${YELLOW}./deploy.sh${NC}"
    
    echo -e "\n${BLUE}📱 功能说明：${NC}"
    echo -e "  • 首页: 查看每日菜单"
    echo -e "  • 管理后台: /admin (菜单管理、批量导入、推送配置)"
    echo -e "  • 推送功能: 在开发环境中可用，生产环境需要额外配置"
}

# 主函数
main() {
    echo -e "${BLUE}🍽️  每日菜单查询系统 - 容器化部署${NC}"
    echo -e "${BLUE}=====================================${NC}\n"
    
    # 检查系统环境
    check_docker
    check_docker_compose
    
    # 创建必要目录
    create_data_directory
    
    # 部署容器
    deploy_containers
    
    # 显示部署信息
    show_deployment_info
    
    echo -e "\n${GREEN}🎊 部署完成！请访问应用地址查看效果。${NC}"
}

# 如果脚本被直接执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi