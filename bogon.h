struct ip_mask {
    char base[4];
    char netmask[4];
};

extern struct ip_mask bogon_list[MAXBOGONS];

