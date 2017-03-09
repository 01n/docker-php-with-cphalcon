# Nginx PHP Phalcon

[TOC]

Phalcon（[官方网站](https://phalconphp.com)）是一个C编写的轻量级PHP框架，实现了MVC、ORM等核心功能。详细内容请参阅[官方文档](https://docs.phalconphp.com/en/latest/index.html)。Github在[这里](https://github.com/phalcon/cphalcon)可以找到。

本Docker镜像基于```webdevops/php-nginx:ubuntu-16.04```，Github在[这里](https://github.com/webdevops/Dockerfile/tree/develop/docker/php-nginx)可以找到。

## 版本信息
| Tag | Nginx | PHP | Phalcon | Ubuntu |
|-----|-------|-----|---------|--------|
| php7.0 | 1.10.0 | 7.0 | 3.0.4 | 16.04 |

## 使用方法

在本镜像中，站点路径被定义在```/project/```，将站点文件加入到该文件夹下即可正常访问。增加了一个默认首页，输出```phpinfo();```的内容。

## 开发版本

**dev**分支和以**dev-**开头的TAG，是提供给开发工程师使用的本地开发镜像。

### PHPUnit 6.0

开发镜像安装了PHPUnit 5.7.15 和 6.0.8 的PHAR版本（参考[这里](https://phpunit.de/manual/current/en/installation.html)），路径：

```
/usr/local/bin/phpunit-6.0.8
/usr/local/bin/phpunit-6
/usr/local/bin/phpunit-5.7.15
/usr/local/bin/phpunit-5.7
```

推荐在项目镜像的Dockerfile中确定本项目使用哪个版本的PHPUnit：

```
RUN ln -s /usr/local/bin/phpunit-x /usr/local/bin/phpunit
```

### SSHD

方便通过PHPStorm运行容器内的PHPUnit，开发镜像启动了SSHD服务。登录账号：

```
用户名：root
密码：123456
```


