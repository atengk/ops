# Conda 虚拟环境创建与管理文档

https://www.anaconda.com/download/success

## 目录
1. 创建虚拟环境
2. 查看虚拟环境列表
3. 激活虚拟环境
4. 安装必要的包
5. 打包虚拟环境
6. 在其他主机上解压与使用虚拟环境

---

### 1. 创建虚拟环境
使用以下命令创建一个名为 `qijiang` 的虚拟环境，并指定 Python 版本为 3.9.0：
```bash
conda create -n qijiang python=3.9.0
```
**说明**：该命令创建一个新的虚拟环境，可以隔离不同项目所需的依赖，避免冲突。

### 2. 查看虚拟环境列表
要查看当前所有的虚拟环境，可以使用：
```bash
conda env list
```
**说明**：此命令将列出所有已创建的虚拟环境及其路径，便于管理。

### 3. 激活虚拟环境
激活 `qijiang` 虚拟环境：
```bash
conda activate qijiang
```
**说明**：激活环境后，命令行将进入该环境状态，所有安装和运行的包都将针对该环境。

### 4. 安装必要的包
在激活的环境中安装所需的包，例如 `onnxruntime` 和 `opencv`：
```bash
conda install onnxruntime opencv
```
**说明**：可以根据项目需求安装其他包，确保环境具备必要的功能。

### 5. 打包虚拟环境
打包虚拟环境以便于迁移到其他主机：
```bash
conda pack -n qijiang -o C:\envs\my_conda_qijiang.tar.gz
```
**说明**：此命令将当前虚拟环境打包成一个 `.tar.gz` 文件，方便在其他机器上使用。

### 6. 在其他主机上解压与使用虚拟环境
在目标主机上解压打包的虚拟环境：
```bash
conda create -n qijiang-test --clone C:\envs\my_conda_qijiang.tar.gz --offline
```
激活新的虚拟环境：
```bash
conda activate qijiang-test
```
检查 Python 版本以确认环境正确：
```bash
python --version
```
**说明**：此过程确保在新主机上成功迁移并使用之前创建的虚拟环境。

---

## 注意事项
- 确保目标主机上已安装 Conda。
- 检查依赖包的兼容性以避免运行时错误。

此文档提供了使用 Conda 创建和管理虚拟环境的基本步骤，可以根据实际项目需求进行调整。