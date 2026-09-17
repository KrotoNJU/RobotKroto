# 每日学习记录

## 2026-09-18

### 把 VS Code 终端默认切换为 Git Bash

**问题现象**

在 VS Code 的集成终端里按 Tab 键无法自动补全 git 命令（例如 `git che` + Tab 不会补成 `git checkout`）。

**根本原因**

VS Code 终端默认用的 shell 是 **Command Prompt（cmd.exe）**，而 cmd.exe 的 Tab 补全只补全文件/文件夹名，不补全 git 命令。git 命令补全需要靠 bash（Git Bash 自带）或 PowerShell 的 posh-git 模块提供。

**解决办法：换成 Git Bash**（Git for Windows 自带，开箱即用，无需额外安装）

方法一（命令面板）：
1. `Ctrl+Shift+P`
2. 输入 `Terminal: Select Default Profile`
3. 选 `Git Bash`

方法二（终端面板临时切）：
- 点终端面板 `+` 号旁的下拉箭头，选 `Git Bash`

方法三（改 settings.json，一劳永逸）：
```json
"terminal.integrated.defaultProfile.windows": "Git Bash",
```

**验证**
- `git che` + Tab → `git checkout`
- `git checkout RK` + Tab → 补全出 `RKmain` / `RK0918` / `RKtest` 等分支名

**相关要点**
- cmd.exe 的 Tab 只能补全文件名，不能补全命令
- Git Bash 自带 git 补全、颜色、分支提示
- 若用 PowerShell 需安装 posh-git 并写入 profile，较麻烦，git 用户直接切 Git Bash 更省事

### 从生成 SSH Key 到本地/远程仓库关联的完整流程

**1. 生成 SSH Key**
```bash
ssh-keygen -t ed25519 -C "你的邮箱"
```
- 一路回车即可，默认生成在 `~/.ssh/id_ed25519`（私钥）和 `id_ed25519.pub`（公钥）
- 私钥自己留着，公钥 `.pub` 才放到 GitHub 上

**2. 复制公钥内容**
```bash
cat ~/.ssh/id_ed25519.pub
```

**3. 添加到 GitHub**
- GitHub → Settings → SSH and GPG keys → New SSH key
- 标题随便写，把公钥内容粘贴进去，保存

**4. 测试 SSH 连接**
```bash
ssh -T git@github.com
```
- 首次会问是否信任主机，输入 `yes`
- 成功会返回 `Hi 用户名! You've successfully authenticated...`（结尾 `exit:1` 是正常的，因为 GitHub 不提供 shell 登录）

**5. 本地初始化仓库**
```bash
git init
git add .
git commit -m "first commit"
```

**6. 在 GitHub 上创建远程仓库**
- 打开 `https://github.com/new`
- 填仓库名、选 Public/Private
- ⚠️ 若本地已有内容，不要勾选 README / .gitignore / license，否则会冲突

**7. 关联远程仓库（SSH 地址）**
```bash
git remote add origin git@github.com:用户名/仓库名.git
git remote -v    # 查看已关联的远程地址
git remote set-url origin git@github.com:用户名/仓库名.git   # 修改地址
```

**8. 首次推送并建立跟踪**
```bash
git push -u origin 分支名
```
- `-u` 会把本地分支和远程分支关联，之后直接 `git push` 即可

**补充要点**
- 远程地址分两种：SSH（`git@github.com:用户/仓库.git`）和 HTTPS（`https://github.com/用户/仓库.git`），配了 SSH key 就用 SSH 地址
- 推送前可用 `git ls-remote origin` 检查远程仓库是否存在；`Repository not found` 说明远程还没建或地址写错了
- 远程默认分支（`origin/HEAD`）可用 `git ls-remote --heads origin` 查看所有远程分支
