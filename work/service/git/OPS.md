# Git命令使用



## **基础操作**

1. **初始化仓库**

    ```bash
    git init
    ```

2. **克隆远程仓库**

    ```bash
    git clone <仓库地址>
    ```

## **提交代码**

1. **查看当前仓库状态**

    ```bash
    git status
    ```

2. **添加文件到暂存区**

    ```bash
    git add <文件名>  # 添加指定文件
    git add .         # 添加所有修改的文件
    ```

3. **提交代码**

    ```bash
    git commit -m "提交说明"
    ```

4. **修改最后一次提交（慎用）**

    ```bash
    git commit --amend -m "新的提交说明"
    ```

## **分支管理**

1. **查看分支**

    ```bash
    git branch  # 查看本地分支
    git branch -r  # 查看远程分支
    ```

2. **创建新分支**

    ```bash
    git branch <分支名>
    ```

3. **切换分支**

    ```bash
    git checkout <分支名>
    git switch <分支名>  # Git 2.23+ 推荐
    ```

4. **创建并切换分支**

    ```bash
    git checkout -b <分支名>
    git switch -c <分支名>  # Git 2.23+ 推荐
    ```

5. **合并分支**

    ```bash
    git merge <分支名>  # 合并指定分支到当前分支
    ```

6. **删除分支**

    ```bash
    git branch -d <分支名>  # 删除本地分支
    git push origin --delete <分支名>  # 删除远程分支
    ```

## **推送与拉取**

1. **查看远程仓库**

    ```bash
    git remote -v
    ```

2. **添加远程仓库**

    ```bash
    git remote add origin <仓库地址>
    ```

3. **推送代码**

    ```bash
    git push origin <分支名>
    ```

4. **拉取远程最新代码**

    ```bash
    git pull origin <分支名>
    ```

5. **同步远程代码（获取但不合并）**

    ```bash
    git fetch origin
    ```

## **撤销修改**

1. **撤销未提交的修改**

    ```bash
    git checkout -- <文件名>
    ```

2. **撤销暂存区的修改**

    ```bash
    git reset HEAD <文件名>
    ```

3. **回退到上一个提交**（慎用）

    ```bash
    git reset --hard HEAD^
    ```

## **查看历史**

1. **查看提交日志**

    ```bash
    git log
    git log --oneline --graph --all --decorate  # 简洁显示
    ```

2. **查看某个文件的修改记录**

    ```bash
    git blame <文件名>
    ```

## **标签管理**

1. **创建标签**

    ```bash
    git tag <标签名>
    ```

2. **推送标签到远程**

    ```bash
    git push origin <标签名>
    ```

3. **删除标签**

    ```bash
    git tag -d <标签名>  # 删除本地标签
    git push origin --delete <标签名>  # 删除远程标签
    ```

## **其他**

1. **查看当前分支与远程的差异**

    ```bash
    git diff origin/<分支名>
    ```

2. **解决冲突（手动编辑后执行）**

    ```bash
    git add .
    git commit -m "解决冲突"
    ```

