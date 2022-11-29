#ifndef HASH_H
#define HASH_H

#define TABLE_SIZE 131 /* prime number */

struct element
{
    char *key;
    /* data */
};

typedef struct list *list_ptr;
struct list
{
    struct element item;
    list_ptr link;
};

/**
 * string folding
 */
int hash(const char *);

struct element new_elem(const char *);

/**
 * chain insert
 *
 * try to insert a new identifier into the table.
 * @return pointer to the new element of the symbol table
 *  or NULL if the identifier already exists
 */
struct element *map_insert(list_ptr *, const char *);

struct element *map_find(list_ptr*, const char *);

#endif // HASH_H