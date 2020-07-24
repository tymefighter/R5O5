#include "declarations.h"
#include "functions.h"

void diskInit(void) {
    uint32 status = 0;

    if(*RVIRT(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
        *RVIRT(VIRTIO_MMIO_VERSION) != 1 ||
        *RVIRT(VIRTIO_MMIO_DEVICE_ID) != 2 ||
        *RVIRT(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
        error("could not find virtio disk");
    }
  
    status |= VIRTIO_CONFIG_S_ACKNOWLEDGE;
    *RVIRT(VIRTIO_MMIO_STATUS) = status;

    status |= VIRTIO_CONFIG_S_DRIVER;
    *RVIRT(VIRTIO_MMIO_STATUS) = status;

    uint64 features = *RVIRT(VIRTIO_MMIO_DEVICE_FEATURES);
    features &= ~(1 << VIRTIO_BLK_F_RO);
    features &= ~(1 << VIRTIO_BLK_F_SCSI);
    features &= ~(1 << VIRTIO_BLK_F_CONFIG_WCE);
    features &= ~(1 << VIRTIO_BLK_F_MQ);
    features &= ~(1 << VIRTIO_F_ANY_LAYOUT);
    features &= ~(1 << VIRTIO_RING_F_EVENT_IDX);
    features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    *RVIRT(VIRTIO_MMIO_DRIVER_FEATURES) = features;

    status |= VIRTIO_CONFIG_S_FEATURES_OK;
    *RVIRT(VIRTIO_MMIO_STATUS) = status;

    status |= VIRTIO_CONFIG_S_DRIVER_OK;
    *RVIRT(VIRTIO_MMIO_STATUS) = status;

    *RVIRT(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;

    *RVIRT(VIRTIO_MMIO_QUEUE_SEL) = 0;
    uint32 max = *RVIRT(VIRTIO_MMIO_QUEUE_NUM_MAX);

    if(max == 0)
        error("virtio disk has no queue 0");

    if(max < NUM)
        error("virtio disk max queue too short");

    *RVIRT(VIRTIO_MMIO_QUEUE_NUM) = NUM;

    memset(disk.pages, 0, sizeof(disk.pages));
    *RVIRT(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;

    disk.desc = (struct VRingDesc *) disk.pages;
    disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    disk.used = (struct UsedArea *) (disk.pages + PGSIZE);

    for(int i = 0; i < NUM; i++)
        disk.free[i] = 1;
}

static int alloc_desc() {
    for(int i = 0; i < NUM; i++){
        if(disk.free[i]){
            disk.free[i] = 0;
            return i;
        }
    }
    return -1;
}

static void free_desc(int i) {
    if(i >= NUM)
        error("virtio_disk_intr 1");
    if(disk.free[i])
        error("virtio_disk_intr 2");
    disk.desc[i].addr = 0;
    disk.free[i] = 1;
}

static void free_chain(int i) {
    while(1){
        free_desc(i);
        if(disk.desc[i].flags & VRING_DESC_F_NEXT)
            i = disk.desc[i].next;
        else
            break;
    }
}

static int alloc3_desc(int *idx) {
    for(int i = 0; i < 3; i++){
        idx[i] = alloc_desc();
        if(idx[i] < 0){
            for(int j = 0; j < i; j++)
                free_desc(idx[j]);
            return -1;
        }
    }
    return 0;
}

void diskRW(Buffer *b, int write) {
    uint64 sector = b->blockno * (BSIZE / 512);

    int idx[3];
    while(1){
        if(alloc3_desc(idx) == 0) {
            break;
        }
    }

    struct virtio_blk_outhdr {
        uint32 type;
        uint32 reserved;
        uint64 sector;
    } buf0;

    if(write)
        buf0.type = VIRTIO_BLK_T_OUT;   // write the disk
    else
        buf0.type = VIRTIO_BLK_T_IN;    // read the disk
    buf0.reserved = 0;
    buf0.sector = sector;

    disk.desc[idx[0]].addr = (uint64) &buf0;
    disk.desc[idx[0]].len = sizeof(buf0);
    disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    disk.desc[idx[0]].next = idx[1];

    disk.desc[idx[1]].addr = (uint64) b->data;
    disk.desc[idx[1]].len = BSIZE;
    if(write)
        disk.desc[idx[1]].flags = 0;
    else
        disk.desc[idx[1]].flags = VRING_DESC_F_WRITE;
    disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    disk.desc[idx[1]].next = idx[2];

    disk.info[idx[0]].status = 0;
    disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    disk.desc[idx[2]].len = 1;
    disk.desc[idx[2]].flags = VRING_DESC_F_WRITE;
    disk.desc[idx[2]].next = 0;

    b->disk = 1;
    disk.info[idx[0]].b = b;

    disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    disk.avail[1] = disk.avail[1] + 1;

    *RVIRT(VIRTIO_MMIO_QUEUE_NOTIFY) = 0;

    intr_dev_on();
    asm("wfi");
    intr_all_off();

    disk.info[idx[0]].b = 0;
    free_chain(idx[0]);
}

void diskIntr() {
    while((disk.used_idx % NUM) != (disk.used->id % NUM)) {
        int id = disk.used->elems[disk.used_idx].id;

        if(disk.info[id].status != 0)
            error("diskIntr status");
        
        disk.info[id].b->disk = 0;   // disk is done with buf

        disk.used_idx = (disk.used_idx + 1) % NUM;
    }
}
