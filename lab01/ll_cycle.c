#include <stddef.h>
#include "ll_cycle.h"

// Solution1
// int ll_has_cycle(node *head) {
//     /* your code here */
//     node *tortoise = head;
//     node *hare = head;

//     while (hare != NULL && hare->next != NULL){
//         hare = hare->next->next;
//         tortoise = tortoise->next;

//         if (hare == tortoise) return 1;
//     }

//     return 0;
// }

// Solution2
int ll_has_cycle(node *head) {
    /* your code here */
    node *tortoise = head;
    node *hare = head;

    do {
        if (hare == NULL || hare->next == NULL) return 0;

        hare = hare->next->next;
        tortoise = tortoise->next;
    } while (hare != tortoise);

    return 1;
}