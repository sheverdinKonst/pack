//
// Created by sheverdin on 7/22/24.
//

#ifndef RTK_DIAG_MEMORY_H
#define RTK_DIAG_MEMORY_H

/*
 * Copyright (C) 2009-2016 Realtek Semiconductor Corp.
 * All Rights Reserved.
 *
 * This program is the proprietary software of Realtek Semiconductor
 * Corporation and/or its licensors, and only be used, duplicated,
 * modified or distributed under the authorized license from Realtek.
 *
 * ANY USE OF THE SOFTWARE OTHER THAN AS AUTHORIZED UNDER
 * THIS LICENSE OR COPYRIGHT LAW IS PROHIBITED.
 *
 * $Revision$
 * $Date$
 *
 * Purpose : Definition those APIs interface for separating OS depend system call.
 *           Let the RTK SDK call the layer and become OS independent SDK package.
 *
 * Feature : memory relative API
 *
 */

/*
 * Include Files
 */
#ifdef __BOOTLOADER__

#else
#include <common/rt_type.h>
//#include <common/rt_autoconf.h>
#endif
#include <include/common/type.h>

#if defined(CONFIG_SDK_KERNEL_LINUX_KERNEL_MODE) && !defined(__KERNEL__)
#include <stdlib.h>
  #define osal_alloc malloc
  #define osal_free free
#endif

/*
 * Symbol Definition
 */
#define MEM_DEV_NAME        "/dev/mem"

/*
 * Data Declaration
 */

/*
 * Macro Definition
 */

/*
 * Function Declaration
 */

#if defined(CONFIG_SDK_KERNEL_LINUX_KERNEL_MODE) && !defined(__KERNEL__)
#else
/* Function Name:
 *      osal_alloc
 * Description:
 *      Allocate memory based on user require size.
 * Input:
 *      size   - size of allocate memory
 * Output:
 *      None
 * Return:
 *      NULL   - failed
 *      others - pointer of the allocated memory area.
 * Note:
 *      Linux Kernel Mode -
 *               Implemented by using kmalloc with GFP_ATOMIC flag.
 *               The maximum size of memory allocated by kmalloc is 128Kbytes.
 *               kmalloc won't sleep with GFP_ATOMIC flag.
 */
extern void *
osal_alloc(uint32 size);

/* Function Name:
 *      osal_free
 * Description:
 *      Free the memory buffer
 * Input:
 *      pAddr - address of buffer that want to free
 * Output:
 *      None
 * Return:
 *      None
 * Note:
 *      None
 */
extern void
osal_free(void *pAddr);
#endif

/* Function Name:
 *      osal_mmap
 * Description:
 *      Map files or devices into memory
 * Input:
 *      addr   - physical offset address
 *      length - maps length bytes starting at offset address
 * Output:
 *      None
 * Return:
 *      Returns a pointer to the mapped area
 * Note:
 *      None
 */
extern void *
osal_mmap(char* dev, uintptr addr, uint32 length);

/* Function Name:
 *      osal_munmap
 * Description:
 *      Unmap files or devices in memory
 * Input:
 *      addr   - virtual offset address
 *      length - mapped length bytes starting at offset address
 * Output:
 *      None
 * Return:
 *      RT_ERR_OK
 *      RT_ERR_FAILED
 * Note:
 *      1. Deletes the mappings for the specified address range,
 *         and causes further references to addresses within the range
 *         to generate invalid memory references.
 *      2. The region is also automatically unmapped when the process is terminated.
 */
extern int32
osal_munmap(uintptr addr, uint32 length);


/* Function Name:
 *      osal_getAllocatedMem
 * Description:
 *      Get the total memory alllocated
 * Input:
 *      None
 * Output:
 *      None
 * Return:
 *      uint32: the size
 * Note:
 *      None
 */
extern uint32
osal_getAllocatedMem(void);

/* Function Name:
 *      osal_getAllocatedMemMax
 * Description:
 *      Get maximum value of the total memory ever alllocated
 * Input:
 *      None
 * Output:
 *      None
 * Return:
 *      uint32: the size
 * Note:
 *      None
 */
extern uint32
osal_getAllocatedMemMax(void);

#endif //RTK_DIAG_MEMORY_H
