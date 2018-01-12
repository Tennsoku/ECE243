
	
	movia r4, 0xffff 			#White
	
	movia r8, ADDR_VGA
	muli r9, r10, 2
	add r8, r8, r9
	muli r9, r7, 1024
	add r8, r8, r9
	sthio r4,0(r8) 				#pixel (r10,r7) offset is r8 = r2 + r10*2 + r7*1024