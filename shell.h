#ifndef _SHELL_
#define _SHELL_

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>


struct cmd;
enum type { INT, STRING, SWITCH };


struct arg
{
    struct cmd * parent;
    struct arg *next,*prev,
    char *name;
    char *value;
    enum type
};

struct cmd {
    struct cmd *prev,*next,*parent,*child;
    struct arg *args;
};



struct arg* new_arg(char *name,enum type)
{
    struct arg* a = (struct arg*) malloc(sizeof(struct arg));
    if( a == NULL ) return NULL;
    a->name = name;
    a->type = type;
    a->value = NULL;
    a-> parent = NULL;
    a->next = NULL;
    a->prev = NULL;

    return a;
}

struct cmd* new_cmd(char *name){
    struct cmd* c = (struct cmd*)malloc(sizeof(struct cmd));
    if( c == NULL ) return NULL;
    c->arg = NULL;
    c->prev = c->next = c->parent = c->child = NULL;
    return c;
}

void add_arg(struct cmd* c, struct arg * a){
    if( c == NULL ) return;
    if( a == NULL ) return;

    if(  c->args == NULL ) {
	c->args = a;
	a->parent = c;
	a->next = NULL;
	a->prev = NULL;
    }else{
	struct arg * n = c->args;
	n->prev = a;
	a->next = n;
	a->parent = c;
	c->args = a;
	a->prev = NULL;
    }
}

void add_cmd(struct cmd *parent, struct cmd* child){
    if( (parent == NULL) || (child == NULL )) return;
    if( parent->child == NULL ) {
	parent->child = child;
	child->parent = parent;
	child->next = NULL;
	child->prev = NULL;
    }else{
	struct cmd * n = parent->child;
	child->next = n;
	n->prev = child;
	parent->child = child;
	child->prev = NULL;
    }
}



#endif 
