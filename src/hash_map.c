#include "hash_map.h"
#include <string.h>
#include <stdlib.h>

int hash(const char *key)
{
    size_t size = strlen(key);
    long sum = 0;
    long mul = 1;
    for (size_t i = 0; i < size; i++)
    {
        mul = (i % 4 == 0) ? 1 : mul << 8;
        sum = sum + key[i] * mul;
    }
    return (int)(sum % TABLE_SIZE);
}

struct element *map_insert(list_ptr *table, const char *key)
{
    int hash_value = hash(key);
    list_ptr ptr,
        trail = NULL,
        lead = table[hash_value];
    while (lead)
    {
        if (!strcmp(lead->item.key, key))
        {
            /* duplicate key */
            return NULL;
        }

        trail = lead;
        lead = lead->link;
    }
    ptr = (list_ptr)malloc(sizeof(struct list));
    ptr->item = new_elem(key);
    ptr->link = NULL;
    if (trail)
        trail->link = ptr;
    else
        table[hash_value] = ptr;
}

struct element *map_find(list_ptr *table, const char *key)
{
    int hash_value = hash(key);
    list_ptr ptr,
        trail = NULL,
        lead = table[hash_value];
    while (lead)
    {
        if (!strcmp(lead->item.key, key))
        {
            /* key exists */
            return &(lead->item);
        }
        trail = lead;
        lead = lead->link;
    }
    return NULL;
}
