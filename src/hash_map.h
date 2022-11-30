#ifndef HASH_H
#define HASH_H

#define TABLE_SIZE 131 /**< prime number */

struct element
{
    char *key;
    /* data */
    long scope;
    enum {
        ARREGLO_T = 1 << 0,
        CONST_T = 1 << 1,
        PROCEDURE_T = 1 << 2,
        PROGRAM_T = 1 << 3,
        VARIABLE_T = 1 << 4
    } symb_type;
};

typedef struct list *list_ptr;
struct list
{
    struct element item;
    list_ptr link;
};

/**
 * string folding.
 */
int hash(char *);

struct element new_elem(char *, const long);

/**
 * chain insert.
 *
 * Try to insert a new element into the table.
 * @return pointer to the new element of the symbol table
 *  or NULL if the identifier already exists
 */
list_ptr map_insert(list_ptr [], const struct element);

/**
 * Search for element in table.
 * @return pointer to the element of the symbol table
 *  if exists or NULL
 */
list_ptr map_find(list_ptr [], const struct element);

void print_list(list_ptr table[]);

#endif // HASH_H