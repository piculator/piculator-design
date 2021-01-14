# 安装中文支持软件包

From : [Raspbian系统中文化（中文支持、中文字体、中文输入法） · Raspberry Pi (gitbooks.io)](https://nintendoboy.gitbooks.io/raspberry-pi/content/raspbianxi-tong-zhong-wen-hua-ff08-zhong-wen-zhi-chi-3001-zhong-wen-zi-ti-3001-zhong-wen-shu-ru-fa-ff09.html)

## 输入法

```bash
sudo apt -y install scim-pinyin
```

安装完后重启

## 中文字体

```bash
sudo apt -y install fonts-wqy-zenhei fonts-wqy-microhei
sudo fc-cache
```

## 设置系统语言为中文

```bash
sudo dpkg-reconfigure locales
# 选择zh_CN.UTF-8 UTF-8
# 选择方式是用上下方向键移动,按空格选中
# 然后按TAB键 , 回车确定
# 然后选 zh_CN.UTF-8
# 然后按TAB键 , 回车确定
# 重启系统生效
```

