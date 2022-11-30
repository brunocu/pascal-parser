#include "hash_map.h"
#include <string.h>
#include <stdlib.h>

int hash(char *key)
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

struct element new_elem(char *key, const long scope)
{
    struct element new_element;
    new_element.key = key;
    new_element.scope = scope;
    return new_element;
}

list_ptr map_insert(list_ptr table[], const struct element item)
{
    int hash_value = hash(item.key);
    list_ptr ptr,
        trail = NULL,
        lead = table[hash_value];
    while (lead)
    {
        if (!strcmp(lead->item.key, item.key) && lead->item.scope == item.scope)
        {
            /* duplicate key */
            return NULL;
        }

        trail = lead;
        lead = lead->link;
    }
    ptr = (list_ptr)malloc(sizeof(struct list));
    ptr->item = item;
    ptr->link = NULL;
    if (trail)
        trail->link = ptr;
    else
        table[hash_value] = ptr;
    return ptr;
}

list_ptr map_find(list_ptr table[], const struct element item)
{
    int hash_value = hash(item.key);
    list_ptr ptr,
        trail = NULL,
        lead = table[hash_value];
    while (lead)
    {
        if (!strcmp(lead->item.key, item.key) && lead->item.scope == item.scope)
        {
            /* key exists */
            return lead;
        }
        trail = lead;
        lead = lead->link;
    }
    return NULL;
}
