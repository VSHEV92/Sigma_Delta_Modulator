#include <linux/module.h>
#include <linux/of_platform.h>
#include <linux/of_device.h>
#include <linux/clk.h>
#include <linux/slab.h>
#include <linux/miscdevice.h>
#include <linux/uaccess.h>
#include <linux/io.h>
#include <linux/ioctl.h>
#include <linux/string.h>	

#define SIGMADELTA_ENABLE_OFFSET   (0x0)
#define SIGMADELTA_VALUE_OFFSET    (0x4)

/**
 * Структура с описанием параметров модулятора
 */
struct sigma_delta_instance {
	struct clk *clk;
	struct miscdevice miscdev;
	void __iomem *regs;
};

struct sigma_delta_data {
	unsigned int enable;
	unsigned int value;
};

#define IOCTL_MAGIC 'c'
#define IOCTL_READ_REGS  _IOR(IOCTL_MAGIC, 1, struct sigma_delta_data*) // чтение регистров
#define IOCTL_WRITE_REGS _IOW(IOCTL_MAGIC, 2, struct sigma_delta_data*) // запись регистров

/**
 * Запись в атрибут
 */
static ssize_t sigma_delta_attr_write(struct device* dev, struct device_attribute* attr, const char* buf, size_t count){
	unsigned long data;
	struct sigma_delta_instance * ip = container_of(dev_get_drvdata(dev), struct sigma_delta_instance, miscdev);

	if(!sscanf(buf,"%lu",&data))
		return count;

	if (strcmp(attr->attr.name,"value") == 0){
		if (data>255)
			iowrite32(255, ip->regs + SIGMADELTA_VALUE_OFFSET);
		else
			iowrite32(data, ip->regs + SIGMADELTA_VALUE_OFFSET);
	}

	if (strcmp(attr->attr.name,"enable") == 0){
		if (data)
			iowrite32(1, ip->regs + SIGMADELTA_ENABLE_OFFSET); 
		else
			iowrite32(0, ip->regs + SIGMADELTA_ENABLE_OFFSET);
	}
	
	return count;
}

/**
 * Чтение из атрибута
 */
static ssize_t sigma_delta_attr_read(struct device* dev, struct device_attribute* attr, char *buf){
	unsigned long data;
	struct sigma_delta_instance * ip = container_of(dev_get_drvdata(dev), struct sigma_delta_instance, miscdev);

	if (strcmp(attr->attr.name,"value") == 0)
		data = ioread32(ip->regs + SIGMADELTA_VALUE_OFFSET);
	
	if (strcmp(attr->attr.name,"enable") == 0)
		data = ioread32(ip->regs + SIGMADELTA_ENABLE_OFFSET);

	return sprintf(buf, "%lu\n", data);
}

static DEVICE_ATTR(enable, 0660, sigma_delta_attr_read, sigma_delta_attr_write);
static DEVICE_ATTR(value, 0660, sigma_delta_attr_read, sigma_delta_attr_write);

/**
 * Открытие файла
 */
static int sigma_delta_open(struct inode *inode, struct file *file){
    return 0;
}

/**
 * Закрытие файла
 */
static int sigma_delta_close(struct inode *inodep, struct file *filp){
    return 0;
}

/**
 * Запись в файл
 */
static ssize_t sigma_delta_write(struct file *file, const char __user *buf, size_t len, loff_t *ppos){
	char* kbuf;
	long val;
	
	// получаем дискриптор модуялтора
	struct sigma_delta_instance * ip = container_of(file->private_data, struct sigma_delta_instance, miscdev);

	// выделяем память для буфера записи
	if((kbuf = kmalloc(len + 1, GFP_KERNEL)) == 0){
        pr_err("Cannot allocate memory in kernel\n");
    	return -1;
    }

	// получаем данные от пользлвателя
	if( copy_from_user(kbuf, buf, len) ){
		pr_err("Cannot copy from user\n");
		kfree(kbuf);
		return -1;
    }

	// перевод строки в целое число
	kbuf[len] = '\0';
	if (kstrtol(kbuf, 0, &val)){
		pr_err("Cannot convert write buffer to integer\n");
		kfree(kbuf);
		return -1;
	}

	// запись значения в регистр	
	iowrite32(1, ip->regs + SIGMADELTA_ENABLE_OFFSET);
	if (val>255)
		iowrite32(255, ip->regs + SIGMADELTA_VALUE_OFFSET);
	else
		iowrite32(val, ip->regs + SIGMADELTA_VALUE_OFFSET);
		
	// удаляем буфер записи
	kfree(kbuf);
            
    return len; 
}

/**
 * системный вызов ioctl
 */ 
static long sigma_delta_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
    struct sigma_delta_data data;

	// получаем дискриптор модуялтора
	struct sigma_delta_instance * ip = container_of(file->private_data, struct sigma_delta_instance, miscdev);

	switch(cmd) {
		// запись регистров
		case IOCTL_WRITE_REGS:
				if (copy_from_user(&data, (struct sigma_delta_data __user *)arg, sizeof(data))){
					pr_err("Cannot copy from user\n");
					return -1;
				}
				// включение ядро
				if (data.enable)
					iowrite32(1, ip->regs + SIGMADELTA_ENABLE_OFFSET); 
	            else
					iowrite32(0, ip->regs + SIGMADELTA_ENABLE_OFFSET);
				// значение для модулятора
				if (data.value > 255)
					iowrite32(255, ip->regs + SIGMADELTA_VALUE_OFFSET);
				else
					iowrite32(data.value, ip->regs + SIGMADELTA_VALUE_OFFSET);
				break;
		// чтение регистров		
		case IOCTL_READ_REGS:
				data.enable = ioread32(ip->regs + SIGMADELTA_ENABLE_OFFSET);
				data.value = ioread32(ip->regs + SIGMADELTA_VALUE_OFFSET);
				if (copy_to_user((struct sigma_delta_data __user *)arg, &data, sizeof(data))){
					pr_err("Cannot copy to user\n");
					return -1;
	       		}
				break;
	}
	return 0;
}

/**
 * Оперции над дескриптором файла
 */
static const struct file_operations fops = {
    .owner          = THIS_MODULE,
    .write          = sigma_delta_write,
    .open           = sigma_delta_open,
    .release        = sigma_delta_close,
	.unlocked_ioctl = sigma_delta_ioctl,
};

/**
 * добавление модуля в ядро
 */
static int sigma_delta_probe(struct platform_device *pdev){
	int status = 0;
	struct resource *res;
	struct sigma_delta_instance *ip_core;
	struct device_node *np = pdev->dev.of_node;
	
	dev_info(&pdev->dev, "Module Probe Function\n");

	// выделение памяти для структуры модулятора
	ip_core = devm_kzalloc(&pdev->dev, sizeof(*ip_core), GFP_KERNEL);
	if (!ip_core)
		return -ENOMEM;
	
	// получить адрес модулятора
	ip_core->regs = devm_platform_ioremap_resource(pdev, 0);
	if (IS_ERR(ip_core->regs)) {
		dev_err(&pdev->dev, "Failed to ioremap memory resource\n");
		return PTR_ERR(ip_core->regs);
	}

	// получения источника тактового сигнала
	ip_core->clk = devm_clk_get_optional(&pdev->dev, NULL);
	if (IS_ERR(ip_core->clk))
		return dev_err_probe(&pdev->dev, PTR_ERR(ip_core->clk), "input clock not found.\n");

	// включение тактового сигнала
	status = clk_prepare_enable(ip_core->clk);
	if (status < 0) {
		dev_err(&pdev->dev, "Failed to prepare clk\n");
		return status;
	}

	// регистрация misc device
	ip_core->miscdev.minor=MISC_DYNAMIC_MINOR;
	ip_core->miscdev.name=pdev->name;
	ip_core->miscdev.fops=&fops; 

	status = misc_register(&ip_core->miscdev);
    if (status) {
        pr_err("Failed to register misc device !!!\n");
	    return status;
    }
	
	// создание атрибутов класса
	status = device_create_file(ip_core->miscdev.this_device, &dev_attr_enable);
    if (status < 0)
        pr_warn("failed to create write /sys endpoint - continuing without\n");
    
    status = device_create_file(ip_core->miscdev.this_device, &dev_attr_value);
    if (status < 0)
        pr_warn("failed to create reset /sys endpoint - continuing without\n");
    
	platform_set_drvdata(pdev, ip_core);
	
	return 0;
}

/**
 * удаление модуля из ядра
 */
static int sigma_delta_remove(struct platform_device *pdev){
	struct sigma_delta_instance *ip = platform_get_drvdata(pdev);

	dev_info(&pdev->dev, "Module Remove Function\n");
	clk_disable_unprepare(ip->clk);
	device_remove_file(ip->miscdev.this_device, &dev_attr_enable);
    device_remove_file(ip->miscdev.this_device, &dev_attr_value);
    
	misc_deregister(&ip->miscdev);
	
    return 0;
}

/**
 * таблица совместимости драйвера
 */
static const struct of_device_id sigma_delta_of_match[] = {
	{.compatible = "xlnx,Sigma-Delta-Modulator-1.0"},
	{}
};
MODULE_DEVICE_TABLE(of, sigma_delta_of_match);

/**
 * misc драйвер для управления модулятором 
 */
static struct platform_driver sigma_delta_driver = {
	.driver = {
		.name = "sigma_delta_driver",
		.of_match_table = sigma_delta_of_match,
	},
	.probe = sigma_delta_probe,
	.remove = sigma_delta_remove,
};
module_platform_driver(sigma_delta_driver);

MODULE_AUTHOR("VSHEV92");
MODULE_DESCRIPTION("Misc driver for Sigma Delta Modulator IP Core");
MODULE_LICENSE("GPL");
