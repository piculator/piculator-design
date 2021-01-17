# 传感器

## 温湿度传感器

元件型号：https://item.taobao.com/item.htm?id=618784075763

参考链接：https://blog.csdn.net/qq_46042542/article/details/107306948

### 1、硬件接线

> sht30的vcc对应树莓派的1号口pwr
> sht30的gnd对应树莓派的6号口gnd
> sht30的sda对应树莓派的3号口sda
> sht30的scl对应树莓派的5号口

1号口pwr将提供3.3 V的电压

还需要打开树莓派的i2c接口：

1. 在命令行输入：sudo raspi-config
2. 上下方向键选择选项，左右方向键选择Select和Finish，我们选择第5个interfacing options
3. 选择P5 i2c接口，然后点YES
4. 最后重启树莓派，则i2c接口打开

### 2、获取温湿度



> After the sensor has completed the measurement, the master can read the measurement results (pair of RH&T) by sending a START condition followed by an I2C read header. The sensor will acknowledge the reception of the read header and send two bytes of data (temperature) followed by one byte CRC checksum and another two bytes of data (relative humidity) followed by one byte CRC checksum. Each byte must be acknowledged by the microcontroller with an ACK condition for the sensor to continue sending data. If the sensor does not receive an ACK from the master after any byte of data, it will not continue sending data.
> The sensor will send the temperature value first and then the relative humidity value. After having received the checksum for the humidity value a NACK and stop condition should be sent (see Table 8). The I2C master can abort the read transfer with a NACK condition after any data byte if it is not interested in subsequent data, e.g. the CRC byte or the second measurement result, in order to save time. In case the user needs humidity and temperature data but does not want to process CRC data, it is recommended to read the two temperature bytes of data with the CRC byte (without processing the CRC data); after having read the two humidity bytes, the read transfer can be aborted with a with a NACK.



在Single shot这种模式下，一个发出的测量命令触发一个数据对的采集。每个数据对由一个16  位温度，和一个16位湿度值(按此顺序)组成。在传输过程中，每个数据值总是紧跟着一个CRC校验和，可以选择不同的测量命令。16  位命令如表8所示。它们与可重复性(低、中、高)和时钟拉伸(启用或禁用)不同。传感器完成测量后，主程序可以通过发送一个START条件和一个I2C读取头来读取测量结果(RH&  T对)。传感器将接收读头的接收，并发送两个字节的数据(温度)，接着是一个字节的CRC校验和另外两个字节的数据(相对湿度)，然后是一个字节的CRC校验和。每个字节必须承认微控制器与ACK条件传感器继续发送数据。如果传感器在任何字节的数据之后没有从主程序接收到ACK，它就不会继续发送数据。传感器将首先发送温度值，然后发送相对湿度值。在收到湿度值的校验和后，就应该发送一个NACK和停止条件。

获取温湿度的后，传感器将会给我们6个字节的数据，前面三个字节为温度两个字节后面跟着一个crc码，后面三个字节为湿度两个字节后面跟着一个crc码。

而获取到的原始数据为线性化数据，并考虑了供给电压的影响，需要按下列公式计算出实际温湿度：
$$
t(^\circ {C})=-45+175\bullet\frac{S_t}{2^{16}-1}\\
h=100\bullet\frac{S_h}{2^{16}-1}
$$


### 3、程序

（均来自上面的CSDN）

查看传感器地址

` sudo i2cdetect -y -a 1`

0x44就是sht30的通信地址，之后我们就要打开上面我们看到的文件i2c-1

```c
int sht_open(int i2c_addr, uint8_t sht_addr)
{
    char    i2c_filename[10];
    int     fd = -1;
    int     rv = -1;

    snprintf(i2c_filename, 19, "/dev/i2c-%d", i2c_addr);
    fd=open(i2c_filename, O_RDWR);
    if(fd < 0)
    {
        printf("open %s fialeure\n", i2c_filename);
        return -1;
    }

    return fd;
}

```

打开文件记得给读写的权限，然后开始往i2c设备也就是sht30传感器写入命令，我们要注意的是，sht30的通信方式是一个字节一个字节的传输的，而我们获取温度的命令地址为16位的，所以我们需要将它拆分，并且通信的时候是高地址为先传送的。我们需要将地址简单处理下

```c
 send[0]=(read_model>>8) & 0xff;
    send[1]=read_model & 0xff;
```

利用ioctl函数之前我们得了解下下面的结构体

```c
 struct i2c_rdwr_ioctl_data {

             struct i2c_msg __user *msgs; /* pointers to i2c_msgs */

             __u32 nmsgs; /* number of i2c_msgs */

         };

         struct i2c_msg {

             _ _u16 addr; /* slave address */

             _ _u16 flags; /* 标志（读、写） */

             _ _u16 len; /* msg length */

             _ _u8 *buf; /* pointer to msg data */

         };
```

这结构体就是存储着树莓派向传感器同行的所有信息，和i2c设备通信就是通过修改结构体的内容来实现的，将对应的参数写入然后掉要ioctl函数

```c
data.nmsgs = 1;//消息的数目
    msgs.len = sendsize;//写入目标的字节数
    msgs.addr = sht_addr;//i2c设备地址  
    msgs.flags = 0;//flags为0:表示写;为1:表示读 
    msgs.buf = send;//发送的数据
    data.msgs = &msgs;
    rv=ioctl(fd, I2C_RDWR, &data);
```

获取温湿度的后，传感器将会给我们6个字节的数据，前面三个字节为温度两个字节后面跟着一个crc码，后面三个字节为湿度两个字节后面跟着一个crc码，中间可以使用定时函数延时下，等待温度获取成功

```c
在这里插入代码data.nmsgs =1;
    msgs.len = readsize;
    msgs.addr = sht_addr;
    msgs.flags = 1;
    msgs.buf = buf;
    data.msgs = &msgs;
    rv=ioctl(fd, I2C_RDWR, &data);片
```

温度获取成功后我们可以进行crc的校检，看看数据是否正确然后利用官方提供的说明对温湿度的值进行加工。

## 心率血氧传感器

参考：https://www.bilibili.com/read/cv4749063/

元件：https://item.taobao.com/item.htm?id=618784075763

### 1、接线

![](https://i0.hdslb.com/bfs/article/6c0a84214536ec775f7c9321c516e6ff78841c6e.jpg@1320w_962h.jpg)

3.3 —— VIN

I2C_SDA1 - SDA

I2C_SCL1 - SCL

PIN7 - INT

GND - GND 

 



