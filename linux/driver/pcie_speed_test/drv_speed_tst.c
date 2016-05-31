/*
 *  file:   drv_speed_tst.c
 *  date:   31.05.2016 11:12:43
 *  authors:
 */

#include <linux/init.h>
#include <linux/module.h>

// local functions -------------------------------------------------------------

static int __init hello_init(void)
static void __exit hello_exit(void)

// kernel routine (bind functions) ---------------------------------------------

module_init(module_start);
module_exit(module_stop);

// local variables -------------------------------------------------------------


// implementation --------------------------------------------------------------

static int __init hello_init(void)
{
 printk(KERN_ALERT "Hello, world\n");
 return 0;
}
static void __exit hello_exit(void)
{
 printk(KERN_ALERT "Goodbye, cruel world\n");
}

