/*
 * =====================================================================================
 *
 *       Filename:  heap.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  08.03.10
 *       Revision:  
 *       Compiler:  GCC 4.4.3
 *
 *         Author:  Yang Zhang, imyeyeslove@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#include <stdlib.h>
#include <heap.h>

static void set_header_footer(PTR, BOOL, size_t);
/* static header_t unify_left($private(Heap), header_t); */
static header_t unify_right_left($private(Heap), header_t);


$dclmethod(OBJ, ctor, $arg(va_list));
$dclmethod(PTR, alloc, $arg(size_t, BOOL));
$dclmethod(void, free, $arg(PTR));

heap_t * heap_create(void)
{
	heap_t *heap = kmalloc(sizeof(heap_t));
	memset(heap, 0, sizeof(heap_t));
	return heap;
}

void * heap_init(heat_t *heap, bintree_t *bintree,
		 PTR start, PTR end, PTR max, int spr, int ro)
{
	assert(!((int) start % 0x1000));
	heap->bintree_t = bintree;
	heap->start = start;
	heap->end = end;
	heap->max = max;
	heap->spr = spr;
	heap->ro = ro;
	return NULL;
}
/*
 *--------------------------------------------------------------------------------------
 *      Method:  getter_end
 *   Parameter:  
 * Description:  get the end addr of the heap
 *--------------------------------------------------------------------------------------
 */
PTR heap_get_end(heat_t *heap)
{
	return heap->end;
}

/*
 *--------------------------------------------------------------------------------------
 *      Method:  ctor
 *   Parameter:  
 * Description:  1st. init private_Heap
 * 		 2nd. set the 1st header & footer
 * 		 3rd. add the node to the tree
 *--------------------------------------------------------------------------------------
 */
struct heap *heap_create()
{
	me->tree = (PTR) gnew(Bintree);                 /* make a Bintree */
	PTR start = va_arg(_arg, PTR);

	me->start = start;
	me->end = va_arg(_arg, PTR);
	me->max = va_arg(_arg, PTR);
	me->spr = va_arg(_arg, int);
	me->rdonly = va_arg(_arg, int);

	size_t heap_size = me->end - start;

        set_header_footer(start, 1, heap_size);                /* end - start */

	$do(($pri(Bintree)) me->tree, add, $arg(Hnode, heap_size, start));
	return (OBJ) me;
}

/*
 *--------------------------------------------------------------------------------------
 *      Method:  alloc
 *   Parameter:  size; align flag
 * Description:  block size == header + apply + footer
 * 		 delete a fit node in the tree
 * 		 if there's enough room left, subtract and add a new one to the tree
 *--------------------------------------------------------------------------------------
 */
$defmethod(PTR, alloc, Heap, $arg(size_t size, BOOL is_align))
	$pri(Bintree) tree = (PTR) me->tree;
	size_t total_size = size + HEAP_SIZE;           /* a whole block size */

	/* total_size, not size. got the fit node */
	$pri(Hnode) node = (PTR) $do(tree, first_fit, $arg(total_size));

	size_t node_size = $do(node, getter_x);         /* node info */
	size_t left_size = node_size - total_size;
	PTR header = $do(node, getter_node);

        $do(tree, del, $arg(node_size));                /* del node from the tree */

	/*-----------------------------------------------------------------------------
	 *  split control-flow
	 *
	 *  if split, set 2 pairs of header-footer, one is USED the other is FREE
	 *  if not, just 1 pair, USED
	 *-----------------------------------------------------------------------------*/
	if (left_size - HEADER_SIZE) {                  /* split */
		PTR header_split = header + total_size;
		set_header_footer(header, 0, total_size);      /* USED */

		set_header_footer(header_split, 1, left_size); /* FREE */

		/* split one starts at the end of the allocated one */
		$do(tree, add, $arg(Hnode, left_size, header_split));
	} else {
		/* give user a little more than requested */
                set_header_footer(header, 0, node_size);       /* not total_size */
	}

        return header + HEADER_SIZE;                    /* don't forget the header */
}

/*
 *--------------------------------------------------------------------------------------
 *      Method:  free
 *   Parameter:  
 * Description:  not at a header
 *--------------------------------------------------------------------------------------
 */
$defmethod(void, free, Heap, $arg(PTR addr))
	header_t header = addr - HEADER_SIZE;           /* posit it's header */
	assert(*(u32 *) header == HEAP_MAGIC);

	/*-----------------------------------------------------------------------------
	 *  as Hnode in bin-tree just holds PTR addr, not including space size
	 *  so if a free Hnode remains the addr pointer, no need to delete it
	 *-----------------------------------------------------------------------------*/
	$pri(Bintree) tree = me->tree;

	/*-----------------------------------------------------------------------------
	 *  NEW could be the same as header, 
	 *  or it's header_left if unify_left() happened
	 *
	 *  so here, add a new node, new's SIZE and new's ADDR
	 *-----------------------------------------------------------------------------*/
	header_t new = unify_right_left(kheap, header);
	$do(tree, add, $arg(Hnode,
                            new->size,                  /* space len */
                            new                         /* it's header addr */));
}

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  set_header_footer
 *  Description:  set header & footer at the same time 
 *  		  be patient that it receives a PTR addr of the header, 
 *  		  not the user available space start addr
 * =====================================================================================
 */
static void set_header_footer(PTR addr, BOOL is_free, size_t total_size)
{
	/* set header */
	header_t header = addr;
	header->magic = HEAP_MAGIC;
	header->free = is_free;
	header->size = total_size;

	/* set footer */
	footer_t footer = addr + total_size - FOOTER_SIZE; /* posit */
	footer->magic = HEAP_MAGIC;
	footer->header = addr;
}

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  unify_left
 *  Description:  only could delete RIGHT's node in the tree
 * =====================================================================================
 */
//static header_t unify_left($private(Heap) heap, header_t header)
//{
//}

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  unify_right
 *  Description:  1st - left -- 2nd - right
 *  		  if unified, delete LEFT's node
 * =====================================================================================
 */
static header_t unify_right_left($private(Heap) heap, header_t header)
{
	/*-----------------------------------------------------------------------------
	 *  no matter what, the current one should set to free
	 *  so unify_left would do it agian
	 *-----------------------------------------------------------------------------*/
	header->free = 1;
	footer_t footer = (PTR) header + header->size - FOOTER_SIZE;
	header_t header_right = (PTR) footer + FOOTER_SIZE;
	footer_t footer_left = (PTR) header - FOOTER_SIZE;

	if (!(header_right->magic == 0x19881014) || !(header_right->free)) {
		goto unify_left;
	}

	footer_t footer_right = (PTR) header_right + header_right->size - FOOTER_SIZE;
	assert(*(u32 *)(footer_right) == HEAP_MAGIC);
	
	/*-----------------------------------------------------------------------------
	 *  not the last one in the heap & free flag set
	 *  1st. unify
	 *  2nd. del node in the tree
	 *-----------------------------------------------------------------------------*/
	header->size = header->size + header_right->size;
	footer_right->header = header;
	$do(($pri(Bintree)) heap->tree, del, $arg(header_right->size));

unify_left :
	if (!(footer_left->magic == 0x19881014)) {
		return header; 
	}

	header_t header_left = footer_left->header;
	assert(*(u32 *)(header_left) == HEAP_MAGIC);

	if (!header_left->free) {
		return header;
	}

	/*-----------------------------------------------------------------------------
	 *  not the first one in the heap & free flag set
	 *  1st. unify
	 *  2nd. del node in the tree
	 *-----------------------------------------------------------------------------*/
	header_left->size = header_left->size + header->size;
	footer->header = header_left;
	header_left->free = 1;
	$do(($pri(Bintree)) heap->tree, del, $arg(header_left->size));
	return header_left;
}

$defclass(Heap, Class,
	4,
	$write(ctor),
	$write(getter_end),
	$write(alloc),
	$write(free),
	0);
