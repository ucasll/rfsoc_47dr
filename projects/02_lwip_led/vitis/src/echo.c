/*
 * Copyright (C) 2009 - 2019 Xilinx, Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 */

#include <stdio.h>
#include <string.h>

// add for vivado project
#include "xil_io.h"         // Xil_Out32
#include "xparameters.h"    //

// according to Vivado project
// xparameters.h  AXI LED IP
#define AXI_LED_BASE_ADDR   XPAR_CUS_AXI_GPIO_0_BASEADDR
// -----------------------------------------------------------------

#include "lwip/err.h"
#include "lwip/tcp.h"
#if defined (__arm__) || defined (__aarch64__)
#include "xil_printf.h"
#endif

int transfer_data() {
	return 0;
}

void print_app_header()
{
#if (LWIP_IPV6==0)
	xil_printf("\n\r\n\r-----lwIP TCP echo server ------\n\r");
#else
	xil_printf("\n\r\n\r-----lwIPv6 TCP echo server ------\n\r");
#endif
	xil_printf("TCP packets sent to port 6001 will be echoed back\n\r");
}

//err_t recv_callback(void *arg, struct tcp_pcb *tpcb,
//                               struct pbuf *p, err_t err)
//{
//	/* do not read the packet if we are not in ESTABLISHED state */
//	if (!p) {
//		tcp_close(tpcb);
//		tcp_recv(tpcb, NULL);
//		return ERR_OK;
//	}
//
//	/* indicate that the packet has been received */
//	tcp_recved(tpcb, p->len);
//
//	/* echo back the payload */
//	/* in this case, we assume that the payload is < TCP_SND_BUF */
//	if (tcp_sndbuf(tpcb) > p->len) {
//		err = tcp_write(tpcb, p->payload, p->len, 1);
//	} else
//		xil_printf("no space in tcp_sndbuf\n\r");
//
//	/* free the received pbuf */
//	pbuf_free(p);
//
//	return ERR_OK;
//}

err_t recv_callback(void *arg, struct tcp_pcb *tpcb,
                    struct pbuf *p, err_t err)
{
    /* do not read the packet if we are not in ESTABLISHED state */
    if (!p) {
        // 如果 p 为 NULL，表示连接断开或关闭
        tcp_close(tpcb);
        tcp_recv(tpcb, NULL);
        xil_printf("Connection closed.\n\r"); // **【新增】** 打印连接关闭信息
        return ERR_OK;
    }

    /* indicate that the packet has been received */
    tcp_recved(tpcb, p->len);

    // ************************************************************
    // ** 【核心修改】替换 Echo 逻辑为 AXI IP 控制逻辑 **
    // ************************************************************

    // 1. 获取接收到的数据指针和长度
    char *recv_data = p->payload;
    int len = p->len;

//    // 2. 检查数据并控制 AXI IP
//    if (len > 0) {
//        // 假设上位机发送 '1' 来开灯，发送 '0' 来关灯
//        if (recv_data[0] == '1') {
//            // 写入 AXI IP 寄存器：例如，写入 1 (打开所有 LED)
//            Xil_Out32(AXI_LED_BASE_ADDR, 0x1);
//            xil_printf("Received '1'. LED ON.\r\n");
//
//        } else if (recv_data[0] == '0') {
//            // 写入 AXI IP 寄存器：例如，写入 0 (关闭所有 LED)
//            Xil_Out32(AXI_LED_BASE_ADDR, 0x0);
//            xil_printf("Received '0'. LED OFF.\r\n");
//
//        } else {
//            xil_printf("Received unknown command: %c\r\n", recv_data[0]);
//        }
//    }

    //
    if (len > 0) {
    	u32 led_value = 0;

    	// 方案 A (推荐)：将接收到的字符串解析为整数
        // 例如，上位机发送 "15" -> 解析为整数 15 (0xF)
        // 上位机发送 "5" -> 解析为整数 5 (0x5)

        // 使用 strtol 来安全地将字符串转换为长整型 (支持十进制或十六进制)
        // 约定：上位机发送纯数字字符串 (例如 "15", "10", "3")
        led_value = (u32)strtol(recv_data, NULL, 10);

        // 确保值在 0 到 15 (0xF) 之间，只控制低四位
        if (led_value > 15) {
            led_value = 15;
        }

        // 写入 AXI GPIO 的数据寄存器
        // 这一步将 led_value 写入 LED
        Xil_Out32(AXI_LED_BASE_ADDR, led_value);

        xil_printf("Received string: %s. Writing value: %lu (0x%lX) to LED.\r\n",
        		recv_data, led_value, led_value);
    }

    // 3. 移除原始的 tcp_write (Echo 回传) 逻辑
    // 4. 释放接收到的 pbuf
    pbuf_free(p);

    return ERR_OK;
}

err_t accept_callback(void *arg, struct tcp_pcb *newpcb, err_t err)
{
	static int connection = 1;

	/* set the receive callback for this connection */
	tcp_recv(newpcb, recv_callback);

	/* just use an integer number indicating the connection id as the
	   callback argument */
	tcp_arg(newpcb, (void*)(UINTPTR)connection);

	/* increment for subsequent accepted connections */
	connection++;

	return ERR_OK;
}


int start_application()
{
	struct tcp_pcb *pcb;
	err_t err;
//	unsigned port = 7;
	unsigned port = 6001;


	/* create new TCP PCB structure */
	pcb = tcp_new_ip_type(IPADDR_TYPE_ANY);
	if (!pcb) {
		xil_printf("Error creating PCB. Out of Memory\n\r");
		return -1;
	}

	/* bind to specified @port */
	err = tcp_bind(pcb, IP_ANY_TYPE, port);
	if (err != ERR_OK) {
		xil_printf("Unable to bind to port %d: err = %d\n\r", port, err);
		return -2;
	}

	/* we do not need any arguments to callback functions */
	tcp_arg(pcb, NULL);

	/* listen for connections */
	pcb = tcp_listen(pcb);
	if (!pcb) {
		xil_printf("Out of memory while tcp_listen\n\r");
		return -3;
	}

	/* specify callback to use for incoming connections */
	tcp_accept(pcb, accept_callback);

//	xil_printf("TCP echo server started @ port %d\n\r", port);
	xil_printf("TCP LED control server started @ port %d\n\r", port);

	return 0;
}
