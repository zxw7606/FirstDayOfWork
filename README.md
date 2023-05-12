# FirstDayOfWork

[![Update Group And Speed-Up](https://github.com/zxw7606/FirstDayOfWork/actions/workflows/Update%20Group%20And%20Speed-Up.yml/badge.svg)](https://github.com/zxw7606/FirstDayOfWork/actions/workflows/Update%20Group%20And%20Speed-Up.yml)

---

![install java  kit example](./docs/install%20java%20%20kit%20example.gif)

## Introduction

项目是`Scoop`一个安装脚本, 将常用的软件进行分组，一键批量安装分组后的软件,节省了重复的安装软件的时间，软件的分组定义在`soft_group_define.json`文件中, 不需要强制定义版本，版本会跟随`Scoop`的仓库进行更新, 安装规则是根据 版本,bucket star数进行降序,数据来源于[https://rasa.github.ioscoop-directory/](https://rasa.github.ioscoop-directory/)

## CHANGELOG

- 2023-05-12 基本功能

## Feature

1. 批量安装软件
2. 加速下载

## QuickStart

### （如果你未安装Scoop）设置Scoop安装路径

```powershell
$env:SCOOP='D:\Applications\Scoop'
$env:SCOOP_GLOBAL='F:\GlobalScoopApps'
```

### 设置执行策略

`Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### 执行安装脚本

#### 国际版

`iwr -useb https://raw.githubusercontent.com/zxw7606/FirstDayOfWork/master/bin/install.ps1 | iex`

#### 国内版

`iwr -useb https://raw.fastgit.org/zxw7606/FirstDayOfWork/master/bin/install.speedup.ps1 | iex`

## 代理网站

- [https://fastgit.org/](https://fastgit.org/)
- [https://ghproxy.com/](https://ghproxy.com/)
