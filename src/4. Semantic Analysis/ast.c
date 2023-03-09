
void printInorder(node *tree) {
	int i;
	if (tree->left) {
		printInorder(tree->left);
	}
	printf("%s, ", tree->token);
	if (tree->right) {
		printInorder(tree->right);
	}
}

void levelTree(node* root, int space)
{
    if(root == NULL){
        return;
    } 
    space += 10;
    levelTree(root->right, space);
    for(int i = 10; i < space; i++)
    {
        printf(" ");
    }
    printf("%s\n", root->token);
    levelTree(root->left, space);

}

node* make_node(node* left, node* right, char *token)
{
    node *newNode = (node*) malloc (sizeof(node));
    char* newToken = (char*) malloc(strlen(token)+1);
    strcpy(newToken, token);
    newNode->left = left;
    newNode->right = right;
    newNode->token = newToken;

    return newNode;
}