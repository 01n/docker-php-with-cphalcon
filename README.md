# Nginx PHP Phalcon

[TOC]

Phalcon（[官方网站](https://phalconphp.com)）是一个C编写的轻量级PHP框架，实现了MVC、ORM等核心功能。详细内容请参阅[官方文档](https://docs.phalconphp.com/en/latest/index.html)。Github在[这里](https://github.com/phalcon/cphalcon)可以找到。

本Docker镜像基于```webdevops/php-nginx:ubuntu-16.04```，Github在[这里](https://github.com/webdevops/Dockerfile/tree/develop/docker/php-nginx)可以找到。

## 版本信息
| Tag | Nginx | PHP | Phalcon | Ubuntu |
|-----|-------|-----|---------|--------|
| php7.0 | 1.10.0 | 7.0 | 3.0.4 | 16.04 |

## 开发版本

**dev**分支和以**dev-**开头的TAG，是提供给开发工程师使用的本地开发镜像。

## 使用方法

在开发时，推荐在代码根目录下创建目录：`docker-compose/development/`（详细的配置方法见后文），用来存放本地开发使用的Docker容器配置信息，配置完成后，就可以使用下面命令直接启动：

```bash
docker-compose -f docker-compose/development/docker-compose.yml up -d --build
```

在本镜像中，站点路径被定义在```/project/```，将站点文件加入到该文件夹下即可正常访问。增加了一个默认首页，输出```phpinfo();```的内容。

## 本地开发镜像的配置方法

建议将本地开发镜像的配置文件都放置在`docker-compose/development/`目录下。

一般而言，该目录下包含两个文件：

* docker-compose.yml
* Dockerfile

docker-compose.yml的例子：

```
version: '2'
services:
  web:
    build:
      context: ../../
      dockerfile: docker-compose/development/Dockerfile
    image: php-development
    container_name: php-development
    ports:
    - "10022:22"
    - "10080:80"
    - "10443:443"
    volumes:
    - ../../source:/project
```

Dockerfile的例子：

```
FROM daocloud.io/we_are_01n/docker-php-with-cphalcon:dev-nginx-php7.0-phalcon3.0.4-v1.1.1

## 设置默认站点根目录
ENV WEB_DOCUMENT_ROOT="/project/public"

## 设置Rewrite
ADD docker-config/10-location-root.conf /opt/docker/etc/nginx/vhost.common.d/10-location-root.conf

## 删除默认的首页
RUN rm /project/index.php

## 确定PHPUnit的版本
RUN ln -s /usr/local/bin/phpunit-5.7 /usr/local/bin/phpunit

VOLUME ["/project"]
WORKDIR /project
```

### PHPUnit

开发镜像安装了PHPUnit 5.7.15 和 6.0.8 的PHAR版本（参考[这里](https://phpunit.de/manual/current/en/installation.html)），路径：

```
/usr/local/bin/phpunit-6.0.8
/usr/local/bin/phpunit-6
/usr/local/bin/phpunit-5.7.15
/usr/local/bin/phpunit-5.7
```

推荐在项目镜像的Dockerfile中确定本项目使用哪个版本的PHPUnit：

```
RUN ln -s /usr/local/bin/phpunit-{版本号} /usr/local/bin/phpunit
```

## 其它信息

### SSHD

方便通过PHPStorm运行容器内的PHPUnit，开发镜像启动了SSHD服务。登录账号：

```
用户名：root
密码：123456
```


