## 重映射PageUp/Dn, Home,End,Del

![image-20210114131050304](Guide.assets/image-20210114131050304.png)![image-20210114133815406](Guide.assets/image-20210114133815406.png)

在`~/.Xmodmap`中

```
keycode 122 = Page_Down
keycode 123 = Page_Up
keycode 173 = Home
keycode 171 = End
keycode 225 = Delete
```

运行`xmodmap ~/.Xmodmap`

---

在`~/.xinitrc中

```
if [ -f $HOME/.Xmodmap ]; then
    /usr/bin/xmodmap $HOME/.Xmodmap
fi
```

然后 `chmod +x ~/.xinitrc`、

然后修改 /etc/xdg/lxsession/LXDE-pi/autostart

添加一行`@bash /home/pi/.xinitrc`

