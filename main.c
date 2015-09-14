#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <inttypes.h>
#include <stdint.h>
#include <string.h>


#include "page_slab.h"
#include "page.h"
#include "debug.h"
#include "core.h"
#include "cpu.h"
#include "control.h"


#define VERSION "0.1"
#define AUTHOR "Hans Schweisser"

#define STRMAX 5000

#define string(x) char x[STRMAX];memset(x,0,sizeof(x))
#define ifsf(s,f) if( strcmp(cmd,s) == 0 ) f(args) 
#define ifs(x) if( strcmp(cmd,x) == 0 ) 
#define ifv(x,v) if( strcmp(x,v) == 0 )
#define parse() sscanf(buff,"%s %[^\n]", cmd,args) 
#define init() string(cmd);string(args);memset(cmd,0,sizeof(cmd));memset(args,0,sizeof(args));parse()
#define arg1(s) string(s); do { string(empty); sscanf(buff,"%s", s); } while(0)
#define arg2(s) string(s); do { string(empty); sscanf(buff,"%s %s", empty, s); } while(0)
#define arg3(s) string(s); do { string(empty); sscanf(buff,"%s %s %s", empty, empty, s);}while(0)
#define empty(s) ( strcmp(s,"") == 0 ? 1 :0 )

vbyte strtovbyte(char *c){
    vbyte byte = 0;
    sscanf(c,"%" PRIx64, &byte );
    return byte;
}

void vshow_stats(char *buff) {
    init();
    
    
}

void vshow_var(char *buff) {
    init();

    ifs("") {
	printf("Usage:\n\tvar slabcount\n\tvar pagecount\n");
    }
    ifs("slabcount") {
	int i=0;
	struct page_slab *p = global_page_slab_list;
	while( p ) { 
	    ++i;
	    if( p->next == NULL ) break;
	    p=p->next;
	}
	printf("%d\n",i);
    }
    ifs("pagecount") {
	struct page* p = global_page_list;
	int i=0;
	while(p) { 
	    ++i;
	    if( p->next == NULL ) break;
	    p=p->next;
	}
	printf("%d\n",i);
    }
        
}

void vshow_usage(){
    printf("Usage:\n    show \n    show help\n    show var ..\n    show stats ...\n");
}
void vshow_help(){
    printf("No help yet\n");
}

void vshow_page_index(char* buff){
    arg1(index);
    int n = strtovbyte(index);
    int i=0;

    struct page* p = global_page_list;
    while( p ) {
	if( n == i ) {
	    show_page(p);
	}
	if( p->next == NULL ) break;
	++i;
	p=p->next;
    }
}

void vshow_page_all(char *buff){
    dump_all_pages();
}

void vshow_page(char *buff){
    init();
    ifs("") { printf("Usage:\n\t index $n\n");}
    ifsf("index", vshow_page_index);
    ifsf("all", vshow_page_all);
}

void vshow(char *buff) {
    init();
    ifsf("", vshow_usage);
    ifsf("help", vshow_help);
    ifsf("var",vshow_var);
    ifsf("stats",vshow_stats);    
    ifsf("page", vshow_page);
}

void vwrite_mem(char *buff){
    arg1(address);
    arg2(value);

    if( !(empty(address) || empty(value)  )) { 
	write_vbyte(strtovbyte(address), strtovbyte(value));        
    }
    
}

void vwrite_reg(char *buff) {
    arg1(reg);
    arg2(value);
    if( empty(reg) ) { printf("Usage:\n\t$reg $value\n"); return;}
    if( empty(value) ) return;

    ifv(reg,"ep") { ep = strtovbyte(value); }
}

void vread_mem(char *buff){
    arg1(address);
    if( empty(address) ) return;
    vbyte byte = read_vbyte(strtovbyte(address));
    printf("%016" PRIx64 "\n", byte);
}

void vread_reg(char *buff){
    arg1(reg);
    
    if(empty(reg)) { printf("List of registers\n\tep\n"); return;}
    printf("%016" PRIx64 "\n", ep);
}



void vwrite(char *buff){
    init();
    ifs("") { printf("Usage\n\tmem $address $value\n");}
    ifsf("mem", vwrite_mem);
    ifsf("reg" , vwrite_reg);
}

void vread(char *buff){
    init();
    ifs("") { printf("Usage:\n\t mem $address $value\n");}
    ifsf("mem", vread_mem);    
    ifsf("reg", vread_reg);
}

void vload_file_raw(char *buff){
    arg1(file);
    arg2(address);
    
    if( empty(file) ) return;
    if( empty(address) ) return;
    
    load_data(file,strtovbyte(address));
}

void vload_file(char *buff){
    init();
    ifs("") { printf("Usage:\n\t raw\n"); }
    ifsf("raw", vload_file_raw);
}

void vload(char *buff){
    init();
    
    ifsf("file", vload_file);
}

void vsave_page_to_file_index(char *buff){
    arg1(index);
    arg2(file);
    if( empty(index) ) return;
    if( empty(file) ) return;
    int iindex = strtovbyte(index);

    FILE *f = fopen( file, "w" );
    if( f == NULL ) { printf("Cannot open file %s\n",file); return;}
    
    struct page* page = find_page_index(iindex);
    if( page == NULL ) { printf("Cannot find page %i\n", iindex); return; }
    for(int i=0;i<(1<<PAGE_SIZE); ++i) {
	fprintf(f,"%016" PRIx64 " ", *(page->p + i ));
    }
    fclose(f);
    

}

void vsave_page_to_file(char*buff){
    init();
    ifsf("index", vsave_page_to_file_index);
}

void vsave_page_to(char *buff){
    init();
    ifsf("file", vsave_page_to_file);
}

void vsave_page(char *buff){
    init();
    ifsf("to", vsave_page_to);
}

void vsave(char *buff){
    init();
    ifsf("page", vsave_page);
}

void vrun_times(char *buff){
    arg1(n);
    if( empty(n) ) { return; }
    execute_cmd_n( strtovbyte(n) );
}

void vrun(char *buff){
    init();
    ifs("") { printf("Usage:\n\tonce\n"); return;}
    ifs("once") { execute_cmd_once(); }
    ifsf("times",vrun_times); 
}

int main(int argc, char **argv) {
    
    printf("Simplexvm %s, by %s\n",VERSION, AUTHOR);
    while(1) {
	string(cmd);
	string(args);
	string(buff);
	
	memset(cmd,0,sizeof(cmd));
	memset(args,0,sizeof(args));
	memset(buff,0,sizeof(buff));


	printf("> ");
	fgets(buff,5000,stdin);

	parse();
	ifs("quit") break;
	ifs("exit") break;
	ifs("version") {
	    printf("Spimpexvm %s, by %s\n", VERSION, AUTHOR);
	}
	ifsf("show",vshow);
	ifsf("write",vwrite);	
	ifsf("read", vread);
	ifsf("load", vload);
	ifsf("run", vrun);
	ifsf("save", vsave);
	
    }

    
    return 0;
}