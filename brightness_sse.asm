
global brightness_sse


section .data align=16

vec0: align 16
dd 0.0, 0.0, 0.0, 0.0

vec255: align 16
dd 255.0, 255.0, 255.0, 255.0

vecn128: align 16
dd -128.0, -128.0, -128.0, -128.0

vec_yuvconst1: align 16
dd 1.13983, 1.13983, 1.13983, 1.13983

vec_yuvconst2: align 16
dd -0.39466, -0.39466, -0.39466, -0.39466

vec_yuvconst3: align 16
dd -0.58060, -0.58060, -0.58060, -0.58060

vec_yuvconst4: align 16
dd 2.03211, 2.03211, 2.03211, 2.03211

blah: align 16
dd 0,0,0,0

vecy: align 16
dd 0, 0, 0, 0

vecu: align 16
dd 0, 0, 0, 0

vecv: align 16
dd 0, 0, 0, 0


section .bss

section .code
bits 32

; void brightness_sse(unsigned char *image, int len, int v)

brightness_sse:
  push ebp
  push edi
  mov ebp, esp
  mov edi, [ebp+12]   ; unsigned char *image
  mov ecx, [ebp+16]   ; int len
  mov eax, [ebp+20]   ; int v

  test eax, 0x80000000 ; check if v is negative
  jz bright_not_neg
  xor al, 255         ; make al abs(v)
  inc al

bright_not_neg:

  shr ecx, 4          ; count = count / 16

  mov ah, al          ; make xmm1 =  (v,v,v,v ,v,v,v,v, ,v,v,v,v, v,v,v,v)
  pinsrw xmm1, ax, 0
  pinsrw xmm1, ax, 1
  pinsrw xmm1, ax, 2
  pinsrw xmm1, ax, 3
  pinsrw xmm1, ax, 4
  pinsrw xmm1, ax, 5
  pinsrw xmm1, ax, 6
  pinsrw xmm1, ax, 7

  test eax, 0xff000000    ; if v was negative, make it darker by abs(v)
  jnz dark_loop

bright_loop:
  movdqa xmm0, [edi]     ; for every 16 byte chunks, add v to all 16 bytes
  paddusb xmm0, xmm1     ; paddusb adds each 16 bytes of xmm0 by v but
  movdqa [edi], xmm0     ; if the byte overflows (more than 255) set to 255

  add edi, 16            ; ptr=ptr+16
  loop bright_loop       ; while (count>0)
  jmp bright_exit

dark_loop:
  movdqa xmm0, [edi]     ; same as above but subtract v from each of the
  psubusb xmm0, xmm1     ; 16 bytes that make up xmm0.  if a byte will
  movdqa [edi], xmm0     ; become negative, set it to 0 (saturation)

  add edi, 16            ; ptr=ptr+16
  loop dark_loop         ; while (count>0)

bright_exit:

  pop edi
  pop ebp
  ret                    ; return



