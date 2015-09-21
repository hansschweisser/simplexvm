#ifndef _TREE_
#define _TREE_

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

struct node {
    struct node * parent;
    struct node * child;
    struct node * next;
    struct node * prev;
    
    char * name;    
    char * prompt;
    char * help;
    char * helpline;
    
    void (*f)(char *buff);

};




struct node * new_node(char *name){
    struct node * node = (struct node*)malloc(sizeof(struct node));
    if( node == NULL ) {
	printf("error cannot malloc strut node\n");
	return NULL;
    }
    node->name=name;
    node->parent = NULL;
    node->child = NULL;
    node->next = NULL;
    node->prev = NULL;

    node->prompt = NULL;
    node->help = NULL;
    node->helpline = NULL;

    node->f = NULL;
    return node;
}

void node_add_child(struct node * parent, struct node *child){
    struct node *p;
    if( parent->child == NULL ) {	
	parent->child = child;
	child->parent = parent;
    }else{
	p = parent->child;
	while( 1 ){
	    if( p->next ) 
		p=p->next;
	    else
		break;
	}
	p->next = child;
	child->prev = p;
	child->parent = parent;
	child->next = NULL;
	
    }
}

void node_show_current(struct node *curr, char *cmd){
    struct node *p = curr->child;
    while(p) {
	if( strncmp(cmd,p->name,strlen(cmd)) == 0 ){
	    printf("\t%s - %s\n", p->name , (p->helpline? p->helpline : "?" ) );
	}

	p = p->next;
	    
    }
}


struct node* node_find(struct node *curr, char *name){
    if( curr == NULL ) return NULL;
    struct node *p = curr->child;
    while(p){
	if( strcmp(name,p->name) == 0 ) {
	    return p;
	}
	p=p->next;
    }
    return NULL;
}













#endif
