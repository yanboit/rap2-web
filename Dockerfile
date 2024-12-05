# 使用适配 ARM 架构的 Node 镜像
FROM arm64v8/node:lts-alpine AS builder

WORKDIR /app

COPY . ./

# 安装缺失的 Babel 插件
RUN npm install --save-dev @babel/plugin-proposal-private-property-in-object

# 替换后端端口地址配置文件
COPY docker/config.prod.ts ./src/config/config.prod.ts

# 安装其他依赖、全局安装 typescript、并运行构建
RUN npm install && \
    npm install typescript -g && \
    npm run lint && \
    npm run build

# 使用适配 ARM 架构的 Nginx 镜像
FROM arm64v8/nginx:stable-alpine

COPY --from=builder app/build /dolores
RUN rm /etc/nginx/conf.d/default.conf
COPY docker/nginx.conf /etc/nginx/conf.d/
