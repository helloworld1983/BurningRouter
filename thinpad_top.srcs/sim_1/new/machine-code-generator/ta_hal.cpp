#include "ta_hal.h"

const uint32_t BUFFER_TAIL_ADDRESS = 0xBFD00400;
const uint32_t SEND_CONTROL_ADDRESS = 0xBFD00408;
const uint32_t SEND_STATE_ADDRESS = 0xBFD00404;
const uint32_t BUFFER_BASE_ADDRESS = 0x80600000;
const uint32_t ROUTER_TABLE_BASE = 0xBFD00410;

int Init(in_addr_t if_addrs[N_IFACE_ON_BOARD])
{
    return 0; // No IP binding routine now
}

uint64_t GetTicks()
{
    return 0; // To be implemented
}

int ReceiveIPPacket(int sys_index, uint8_t *buffer,
                    macaddr_t src_mac, macaddr_t dst_mac, int64_t timeout,
                    int *if_index)
{
    // volatile = could be changed by sb. outside this cpp program
    volatile uint32_t *BufferIndexPtr = (uint32_t *)BUFFER_TAIL_ADDRESS;
    uint64_t startTime = GetTicks();
    // 2^18 ms = 2^15 s \approx 2^9 days
    if (timeout == -1)
        timeout = ((uint64_t)timeout) >> 1;
    while (1)
    {
        if (GetTicks() - startTime >= timeout)
            return 0;
        if (*BufferIndexPtr != sys_index)
            break;
    }
    buffer = (uint8_t *)(BUFFER_BASE_ADDRESS + ((sys_index++) << 11)) + 4;
    // Note: the Ethernet header the cpu receives is different from that of a standard one.
    // In our implementation, src mac is ahead of dst mac.
    *(uint32_t *)src_mac = *(uint32_t *)(buffer); // Big-Endian
    *(uint16_t *)(src_mac + 4) = *(uint16_t *)(buffer + 4);
    *(uint32_t *)dst_mac = *(uint32_t *)(buffer + 6);
    *(uint16_t *)(dst_mac + 4) = *(uint16_t *)(buffer + 10);
    *(int *)if_index = *(uint8_t *)(buffer + 15) - 1;
    return *(int *)(buffer - 4);
}

int SendIPPacket(int if_index, uint8_t *buffer, size_t length,
                 macaddr_t my_mac)
{
    *(uint32_t *)(buffer) = *(uint32_t *)(buffer + 6) = *(uint32_t *)(my_mac);
    *(uint16_t *)(buffer + 4) = *(uint16_t *)(buffer + 10) = *(uint16_t *)(my_mac + 4);
    *(uint8_t *)(buffer + 15) = (*(int *)if_index) + 1;
    buffer -= 4;
    *(int *)(buffer) = length;
    volatile uint32_t *SendStatePtr = (uint32_t *)SEND_STATE_ADDRESS;
    while (1)
    {
        if ((*(uint32_t *)(SEND_STATE_ADDRESS)&1) == 0)
            break;
    }
    *(uint32_t *)SEND_CONTROL_ADDRESS = (uint32_t)buffer;
}