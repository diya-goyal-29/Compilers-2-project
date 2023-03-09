typedef struct node {
    struct node *left;
    struct node* right;
    char *token;
}node;

node* head;

void printInorder(node *);
void levelTree(node*, int);
node* make_node(node *left, node *right, char *token);