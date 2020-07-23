
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00011117          	auipc	sp,0x11
    80000004:	e7010113          	addi	sp,sp,-400 # 80010e70 <SystemStack>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	6ac000ef          	jal	ra,800006c2 <main>

000000008000001a <junk>:
    8000001a:	a001                	j	8000001a <junk>

000000008000001c <consputc>:
void
consputc(int c)
{
  extern volatile int panicked; // from printf.c

  if(panicked){
    8000001c:	00012797          	auipc	a5,0x12
    80000020:	e5c7a783          	lw	a5,-420(a5) # 80011e78 <panicked>
    80000024:	c391                	beqz	a5,80000028 <consputc+0xc>
    for(;;)
    80000026:	a001                	j	80000026 <consputc+0xa>
{
    80000028:	1141                	addi	sp,sp,-16
    8000002a:	e406                	sd	ra,8(sp)
    8000002c:	e022                	sd	s0,0(sp)
    8000002e:	0800                	addi	s0,sp,16
      ;
  }

  if(c == BACKSPACE){
    80000030:	10000793          	li	a5,256
    80000034:	00f50a63          	beq	a0,a5,80000048 <consputc+0x2c>
    // if the user typed backspace, overwrite with a space.
    uartputc('\b'); uartputc(' '); uartputc('\b');
  } else {
    uartputc(c);
    80000038:	00000097          	auipc	ra,0x0
    8000003c:	45a080e7          	jalr	1114(ra) # 80000492 <uartputc>
  }
}
    80000040:	60a2                	ld	ra,8(sp)
    80000042:	6402                	ld	s0,0(sp)
    80000044:	0141                	addi	sp,sp,16
    80000046:	8082                	ret
    uartputc('\b'); uartputc(' '); uartputc('\b');
    80000048:	4521                	li	a0,8
    8000004a:	00000097          	auipc	ra,0x0
    8000004e:	448080e7          	jalr	1096(ra) # 80000492 <uartputc>
    80000052:	02000513          	li	a0,32
    80000056:	00000097          	auipc	ra,0x0
    8000005a:	43c080e7          	jalr	1084(ra) # 80000492 <uartputc>
    8000005e:	4521                	li	a0,8
    80000060:	00000097          	auipc	ra,0x0
    80000064:	432080e7          	jalr	1074(ra) # 80000492 <uartputc>
    80000068:	bfe1                	j	80000040 <consputc+0x24>

000000008000006a <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    8000006a:	1101                	addi	sp,sp,-32
    8000006c:	ec06                	sd	ra,24(sp)
    8000006e:	e822                	sd	s0,16(sp)
    80000070:	e426                	sd	s1,8(sp)
    80000072:	e04a                	sd	s2,0(sp)
    80000074:	1000                	addi	s0,sp,32
  switch(c){
    80000076:	47d5                	li	a5,21
    80000078:	08f50063          	beq	a0,a5,800000f8 <consoleintr+0x8e>
    8000007c:	84aa                	mv	s1,a0
    8000007e:	07f00793          	li	a5,127
    80000082:	0cf50163          	beq	a0,a5,80000144 <consoleintr+0xda>
    80000086:	47a1                	li	a5,8
    80000088:	0af50e63          	beq	a0,a5,80000144 <consoleintr+0xda>
      cons.e--;
      consputc(BACKSPACE);
    }
    break;
  default:
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000008c:	c571                	beqz	a0,80000158 <consoleintr+0xee>
    8000008e:	00009717          	auipc	a4,0x9
    80000092:	b7a70713          	addi	a4,a4,-1158 # 80008c08 <cons>
    80000096:	08872783          	lw	a5,136(a4)
    8000009a:	08072703          	lw	a4,128(a4)
    8000009e:	9f99                	subw	a5,a5,a4
    800000a0:	07f00713          	li	a4,127
    800000a4:	0af76a63          	bltu	a4,a5,80000158 <consoleintr+0xee>
      c = (c == '\r') ? '\n' : c;
    800000a8:	47b5                	li	a5,13
    800000aa:	0cf50963          	beq	a0,a5,8000017c <consoleintr+0x112>

      // echo back to the user.
      consputc(c);
    800000ae:	00000097          	auipc	ra,0x0
    800000b2:	f6e080e7          	jalr	-146(ra) # 8000001c <consputc>

      // store for consumption by consoleread().
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800000b6:	00009797          	auipc	a5,0x9
    800000ba:	b5278793          	addi	a5,a5,-1198 # 80008c08 <cons>
    800000be:	0887a703          	lw	a4,136(a5)
    800000c2:	0017061b          	addiw	a2,a4,1
    800000c6:	0006069b          	sext.w	a3,a2
    800000ca:	08c7a423          	sw	a2,136(a5)
    800000ce:	07f77713          	andi	a4,a4,127
    800000d2:	97ba                	add	a5,a5,a4
    800000d4:	00978023          	sb	s1,0(a5)

      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    800000d8:	47a9                	li	a5,10
    800000da:	0cf48863          	beq	s1,a5,800001aa <consoleintr+0x140>
    800000de:	4791                	li	a5,4
    800000e0:	0cf48563          	beq	s1,a5,800001aa <consoleintr+0x140>
    800000e4:	00009797          	auipc	a5,0x9
    800000e8:	ba47a783          	lw	a5,-1116(a5) # 80008c88 <cons+0x80>
    800000ec:	0807879b          	addiw	a5,a5,128
    800000f0:	06f69463          	bne	a3,a5,80000158 <consoleintr+0xee>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800000f4:	86be                	mv	a3,a5
    800000f6:	a855                	j	800001aa <consoleintr+0x140>
    while(cons.e != cons.w &&
    800000f8:	00009717          	auipc	a4,0x9
    800000fc:	b1070713          	addi	a4,a4,-1264 # 80008c08 <cons>
    80000100:	08872783          	lw	a5,136(a4)
    80000104:	08472703          	lw	a4,132(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000108:	00009497          	auipc	s1,0x9
    8000010c:	b0048493          	addi	s1,s1,-1280 # 80008c08 <cons>
    while(cons.e != cons.w &&
    80000110:	4929                	li	s2,10
    80000112:	04f70363          	beq	a4,a5,80000158 <consoleintr+0xee>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000116:	37fd                	addiw	a5,a5,-1
    80000118:	07f7f713          	andi	a4,a5,127
    8000011c:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000011e:	00074703          	lbu	a4,0(a4)
    80000122:	03270b63          	beq	a4,s2,80000158 <consoleintr+0xee>
      cons.e--;
    80000126:	08f4a423          	sw	a5,136(s1)
      consputc(BACKSPACE);
    8000012a:	10000513          	li	a0,256
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	eee080e7          	jalr	-274(ra) # 8000001c <consputc>
    while(cons.e != cons.w &&
    80000136:	0884a783          	lw	a5,136(s1)
    8000013a:	0844a703          	lw	a4,132(s1)
    8000013e:	fcf71ce3          	bne	a4,a5,80000116 <consoleintr+0xac>
    80000142:	a819                	j	80000158 <consoleintr+0xee>
    if(cons.e != cons.w){
    80000144:	00009717          	auipc	a4,0x9
    80000148:	ac470713          	addi	a4,a4,-1340 # 80008c08 <cons>
    8000014c:	08872783          	lw	a5,136(a4)
    80000150:	08472703          	lw	a4,132(a4)
    80000154:	00f71863          	bne	a4,a5,80000164 <consoleintr+0xfa>
      }
    }
    break;
  }

}
    80000158:	60e2                	ld	ra,24(sp)
    8000015a:	6442                	ld	s0,16(sp)
    8000015c:	64a2                	ld	s1,8(sp)
    8000015e:	6902                	ld	s2,0(sp)
    80000160:	6105                	addi	sp,sp,32
    80000162:	8082                	ret
      cons.e--;
    80000164:	37fd                	addiw	a5,a5,-1
    80000166:	00009717          	auipc	a4,0x9
    8000016a:	b2f72523          	sw	a5,-1238(a4) # 80008c90 <cons+0x88>
      consputc(BACKSPACE);
    8000016e:	10000513          	li	a0,256
    80000172:	00000097          	auipc	ra,0x0
    80000176:	eaa080e7          	jalr	-342(ra) # 8000001c <consputc>
    8000017a:	bff9                	j	80000158 <consoleintr+0xee>
      consputc(c);
    8000017c:	4529                	li	a0,10
    8000017e:	00000097          	auipc	ra,0x0
    80000182:	e9e080e7          	jalr	-354(ra) # 8000001c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000186:	00009797          	auipc	a5,0x9
    8000018a:	a8278793          	addi	a5,a5,-1406 # 80008c08 <cons>
    8000018e:	0887a703          	lw	a4,136(a5)
    80000192:	0017061b          	addiw	a2,a4,1
    80000196:	0006069b          	sext.w	a3,a2
    8000019a:	08c7a423          	sw	a2,136(a5)
    8000019e:	07f77713          	andi	a4,a4,127
    800001a2:	97ba                	add	a5,a5,a4
    800001a4:	4729                	li	a4,10
    800001a6:	00e78023          	sb	a4,0(a5)
        cons.w = cons.e;
    800001aa:	00009797          	auipc	a5,0x9
    800001ae:	aed7a123          	sw	a3,-1310(a5) # 80008c8c <cons+0x84>
}
    800001b2:	b75d                	j	80000158 <consoleintr+0xee>

00000000800001b4 <consoleinit>:

void
consoleinit(void)
{
    800001b4:	1141                	addi	sp,sp,-16
    800001b6:	e406                	sd	ra,8(sp)
    800001b8:	e022                	sd	s0,0(sp)
    800001ba:	0800                	addi	s0,sp,16
  uartinit();
    800001bc:	00000097          	auipc	ra,0x0
    800001c0:	2a0080e7          	jalr	672(ra) # 8000045c <uartinit>
}
    800001c4:	60a2                	ld	ra,8(sp)
    800001c6:	6402                	ld	s0,0(sp)
    800001c8:	0141                	addi	sp,sp,16
    800001ca:	8082                	ret

00000000800001cc <printint>:
#include "declarations.h"
#include "functions.h"

static void
printint(uint64 xx, int base, int sign)
{
    800001cc:	7179                	addi	sp,sp,-48
    800001ce:	f406                	sd	ra,40(sp)
    800001d0:	f022                	sd	s0,32(sp)
    800001d2:	ec26                	sd	s1,24(sp)
    800001d4:	e84a                	sd	s2,16(sp)
    800001d6:	1800                	addi	s0,sp,48
  uint x;

  if(sign && (sign = xx < 0))
    x = -xx;
  else
    x = xx;
    800001d8:	2501                	sext.w	a0,a0
    800001da:	fd040693          	addi	a3,s0,-48

  i = 0;
    800001de:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800001e0:	00003817          	auipc	a6,0x3
    800001e4:	e2080813          	addi	a6,a6,-480 # 80003000 <digits>
    800001e8:	863a                	mv	a2,a4
    800001ea:	2705                	addiw	a4,a4,1
    800001ec:	02b577bb          	remuw	a5,a0,a1
    800001f0:	1782                	slli	a5,a5,0x20
    800001f2:	9381                	srli	a5,a5,0x20
    800001f4:	97c2                	add	a5,a5,a6
    800001f6:	0007c783          	lbu	a5,0(a5)
    800001fa:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800001fe:	0005079b          	sext.w	a5,a0
    80000202:	02b5553b          	divuw	a0,a0,a1
    80000206:	0685                	addi	a3,a3,1
    80000208:	feb7f0e3          	bgeu	a5,a1,800001e8 <printint+0x1c>

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
    8000020c:	02064663          	bltz	a2,80000238 <printint+0x6c>
    80000210:	fd040793          	addi	a5,s0,-48
    80000214:	00c784b3          	add	s1,a5,a2
    80000218:	fff78913          	addi	s2,a5,-1
    8000021c:	9932                	add	s2,s2,a2
    8000021e:	1602                	slli	a2,a2,0x20
    80000220:	9201                	srli	a2,a2,0x20
    80000222:	40c90933          	sub	s2,s2,a2
    consputc(buf[i]);
    80000226:	0004c503          	lbu	a0,0(s1)
    8000022a:	00000097          	auipc	ra,0x0
    8000022e:	df2080e7          	jalr	-526(ra) # 8000001c <consputc>
  while(--i >= 0)
    80000232:	14fd                	addi	s1,s1,-1
    80000234:	ff2499e3          	bne	s1,s2,80000226 <printint+0x5a>
}
    80000238:	70a2                	ld	ra,40(sp)
    8000023a:	7402                	ld	s0,32(sp)
    8000023c:	64e2                	ld	s1,24(sp)
    8000023e:	6942                	ld	s2,16(sp)
    80000240:	6145                	addi	sp,sp,48
    80000242:	8082                	ret

0000000080000244 <panic>:

}

void
panic(char *s)
{
    80000244:	1101                	addi	sp,sp,-32
    80000246:	ec06                	sd	ra,24(sp)
    80000248:	e822                	sd	s0,16(sp)
    8000024a:	e426                	sd	s1,8(sp)
    8000024c:	1000                	addi	s0,sp,32
    8000024e:	84aa                	mv	s1,a0
  printf("panic: ");
    80000250:	00002517          	auipc	a0,0x2
    80000254:	db050513          	addi	a0,a0,-592 # 80002000 <ret_to_user+0x918>
    80000258:	00000097          	auipc	ra,0x0
    8000025c:	02e080e7          	jalr	46(ra) # 80000286 <printf>
  printf(s);
    80000260:	8526                	mv	a0,s1
    80000262:	00000097          	auipc	ra,0x0
    80000266:	024080e7          	jalr	36(ra) # 80000286 <printf>
  printf("\n");
    8000026a:	00002517          	auipc	a0,0x2
    8000026e:	0e650513          	addi	a0,a0,230 # 80002350 <ret_to_user+0xc68>
    80000272:	00000097          	auipc	ra,0x0
    80000276:	014080e7          	jalr	20(ra) # 80000286 <printf>
  panicked = 1; // freeze other CPUs
    8000027a:	4785                	li	a5,1
    8000027c:	00012717          	auipc	a4,0x12
    80000280:	bef72e23          	sw	a5,-1028(a4) # 80011e78 <panicked>
  for(;;)
    80000284:	a001                	j	80000284 <panic+0x40>

0000000080000286 <printf>:
{
    80000286:	7171                	addi	sp,sp,-176
    80000288:	f486                	sd	ra,104(sp)
    8000028a:	f0a2                	sd	s0,96(sp)
    8000028c:	eca6                	sd	s1,88(sp)
    8000028e:	e8ca                	sd	s2,80(sp)
    80000290:	e4ce                	sd	s3,72(sp)
    80000292:	e0d2                	sd	s4,64(sp)
    80000294:	fc56                	sd	s5,56(sp)
    80000296:	f85a                	sd	s6,48(sp)
    80000298:	f45e                	sd	s7,40(sp)
    8000029a:	f062                	sd	s8,32(sp)
    8000029c:	ec66                	sd	s9,24(sp)
    8000029e:	e86a                	sd	s10,16(sp)
    800002a0:	1880                	addi	s0,sp,112
    800002a2:	e40c                	sd	a1,8(s0)
    800002a4:	e810                	sd	a2,16(s0)
    800002a6:	ec14                	sd	a3,24(s0)
    800002a8:	f018                	sd	a4,32(s0)
    800002aa:	f41c                	sd	a5,40(s0)
    800002ac:	03043823          	sd	a6,48(s0)
    800002b0:	03143c23          	sd	a7,56(s0)
  if (fmt == 0)
    800002b4:	c915                	beqz	a0,800002e8 <printf+0x62>
    800002b6:	89aa                	mv	s3,a0
  va_start(ap, fmt);
    800002b8:	00840793          	addi	a5,s0,8
    800002bc:	f8f43c23          	sd	a5,-104(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800002c0:	00054503          	lbu	a0,0(a0)
    800002c4:	16050e63          	beqz	a0,80000440 <printf+0x1ba>
    800002c8:	4481                	li	s1,0
    if(c != '%'){
    800002ca:	02500a13          	li	s4,37
    switch(c){
    800002ce:	4ad1                	li	s5,20
    800002d0:	00002917          	auipc	s2,0x2
    800002d4:	11090913          	addi	s2,s2,272 # 800023e0 <ret_to_user+0xcf8>
      for(; *s; s++)
    800002d8:	02800c93          	li	s9,40
  consputc('x');
    800002dc:	4c41                	li	s8,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800002de:	00003b17          	auipc	s6,0x3
    800002e2:	d22b0b13          	addi	s6,s6,-734 # 80003000 <digits>
    800002e6:	a025                	j	8000030e <printf+0x88>
    panic("null fmt");
    800002e8:	00002517          	auipc	a0,0x2
    800002ec:	d2850513          	addi	a0,a0,-728 # 80002010 <ret_to_user+0x928>
    800002f0:	00000097          	auipc	ra,0x0
    800002f4:	f54080e7          	jalr	-172(ra) # 80000244 <panic>
      consputc(c);
    800002f8:	00000097          	auipc	ra,0x0
    800002fc:	d24080e7          	jalr	-732(ra) # 8000001c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000300:	2485                	addiw	s1,s1,1
    80000302:	009987b3          	add	a5,s3,s1
    80000306:	0007c503          	lbu	a0,0(a5)
    8000030a:	12050b63          	beqz	a0,80000440 <printf+0x1ba>
    if(c != '%'){
    8000030e:	ff4515e3          	bne	a0,s4,800002f8 <printf+0x72>
    c = fmt[++i] & 0xff;
    80000312:	2485                	addiw	s1,s1,1
    80000314:	009987b3          	add	a5,s3,s1
    80000318:	0007c783          	lbu	a5,0(a5)
    8000031c:	00078b9b          	sext.w	s7,a5
    if(c == 0)
    80000320:	12078063          	beqz	a5,80000440 <printf+0x1ba>
    switch(c){
    80000324:	0f478d63          	beq	a5,s4,8000041e <printf+0x198>
    80000328:	f9c7871b          	addiw	a4,a5,-100
    8000032c:	0ff77713          	andi	a4,a4,255
    80000330:	0eeaed63          	bltu	s5,a4,8000042a <printf+0x1a4>
    80000334:	f9c7879b          	addiw	a5,a5,-100
    80000338:	0ff7f713          	andi	a4,a5,255
    8000033c:	0eeae763          	bltu	s5,a4,8000042a <printf+0x1a4>
    80000340:	00271793          	slli	a5,a4,0x2
    80000344:	97ca                	add	a5,a5,s2
    80000346:	439c                	lw	a5,0(a5)
    80000348:	97ca                	add	a5,a5,s2
    8000034a:	8782                	jr	a5
      printint(va_arg(ap, int), 10, 1);
    8000034c:	f9843783          	ld	a5,-104(s0)
    80000350:	00878713          	addi	a4,a5,8
    80000354:	f8e43c23          	sd	a4,-104(s0)
    80000358:	4605                	li	a2,1
    8000035a:	45a9                	li	a1,10
    8000035c:	4388                	lw	a0,0(a5)
    8000035e:	00000097          	auipc	ra,0x0
    80000362:	e6e080e7          	jalr	-402(ra) # 800001cc <printint>
      break;
    80000366:	bf69                	j	80000300 <printf+0x7a>
      printint(va_arg(ap, int), 16, 1);
    80000368:	f9843783          	ld	a5,-104(s0)
    8000036c:	00878713          	addi	a4,a5,8
    80000370:	f8e43c23          	sd	a4,-104(s0)
    80000374:	4605                	li	a2,1
    80000376:	85e2                	mv	a1,s8
    80000378:	4388                	lw	a0,0(a5)
    8000037a:	00000097          	auipc	ra,0x0
    8000037e:	e52080e7          	jalr	-430(ra) # 800001cc <printint>
      break;
    80000382:	bfbd                	j	80000300 <printf+0x7a>
      printptr(va_arg(ap, uint64));
    80000384:	f9843783          	ld	a5,-104(s0)
    80000388:	00878713          	addi	a4,a5,8
    8000038c:	f8e43c23          	sd	a4,-104(s0)
    80000390:	0007bd03          	ld	s10,0(a5)
  consputc('0');
    80000394:	03000513          	li	a0,48
    80000398:	00000097          	auipc	ra,0x0
    8000039c:	c84080e7          	jalr	-892(ra) # 8000001c <consputc>
  consputc('x');
    800003a0:	07800513          	li	a0,120
    800003a4:	00000097          	auipc	ra,0x0
    800003a8:	c78080e7          	jalr	-904(ra) # 8000001c <consputc>
    800003ac:	8be2                	mv	s7,s8
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800003ae:	03cd5793          	srli	a5,s10,0x3c
    800003b2:	97da                	add	a5,a5,s6
    800003b4:	0007c503          	lbu	a0,0(a5)
    800003b8:	00000097          	auipc	ra,0x0
    800003bc:	c64080e7          	jalr	-924(ra) # 8000001c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800003c0:	0d12                	slli	s10,s10,0x4
    800003c2:	3bfd                	addiw	s7,s7,-1
    800003c4:	fe0b95e3          	bnez	s7,800003ae <printf+0x128>
    800003c8:	bf25                	j	80000300 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    800003ca:	f9843783          	ld	a5,-104(s0)
    800003ce:	00878713          	addi	a4,a5,8
    800003d2:	f8e43c23          	sd	a4,-104(s0)
    800003d6:	4605                	li	a2,1
    800003d8:	45a9                	li	a1,10
    800003da:	6388                	ld	a0,0(a5)
    800003dc:	00000097          	auipc	ra,0x0
    800003e0:	df0080e7          	jalr	-528(ra) # 800001cc <printint>
      break;
    800003e4:	bf31                	j	80000300 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    800003e6:	f9843783          	ld	a5,-104(s0)
    800003ea:	00878713          	addi	a4,a5,8
    800003ee:	f8e43c23          	sd	a4,-104(s0)
    800003f2:	0007bb83          	ld	s7,0(a5)
    800003f6:	000b8e63          	beqz	s7,80000412 <printf+0x18c>
      for(; *s; s++)
    800003fa:	000bc503          	lbu	a0,0(s7)
    800003fe:	d109                	beqz	a0,80000300 <printf+0x7a>
        consputc(*s);
    80000400:	00000097          	auipc	ra,0x0
    80000404:	c1c080e7          	jalr	-996(ra) # 8000001c <consputc>
      for(; *s; s++)
    80000408:	0b85                	addi	s7,s7,1
    8000040a:	000bc503          	lbu	a0,0(s7)
    8000040e:	f96d                	bnez	a0,80000400 <printf+0x17a>
    80000410:	bdc5                	j	80000300 <printf+0x7a>
        s = "(null)";
    80000412:	00002b97          	auipc	s7,0x2
    80000416:	bf6b8b93          	addi	s7,s7,-1034 # 80002008 <ret_to_user+0x920>
      for(; *s; s++)
    8000041a:	8566                	mv	a0,s9
    8000041c:	b7d5                	j	80000400 <printf+0x17a>
      consputc('%');
    8000041e:	8552                	mv	a0,s4
    80000420:	00000097          	auipc	ra,0x0
    80000424:	bfc080e7          	jalr	-1028(ra) # 8000001c <consputc>
      break;
    80000428:	bde1                	j	80000300 <printf+0x7a>
      consputc('%');
    8000042a:	8552                	mv	a0,s4
    8000042c:	00000097          	auipc	ra,0x0
    80000430:	bf0080e7          	jalr	-1040(ra) # 8000001c <consputc>
      consputc(c);
    80000434:	855e                	mv	a0,s7
    80000436:	00000097          	auipc	ra,0x0
    8000043a:	be6080e7          	jalr	-1050(ra) # 8000001c <consputc>
      break;
    8000043e:	b5c9                	j	80000300 <printf+0x7a>
}
    80000440:	70a6                	ld	ra,104(sp)
    80000442:	7406                	ld	s0,96(sp)
    80000444:	64e6                	ld	s1,88(sp)
    80000446:	6946                	ld	s2,80(sp)
    80000448:	69a6                	ld	s3,72(sp)
    8000044a:	6a06                	ld	s4,64(sp)
    8000044c:	7ae2                	ld	s5,56(sp)
    8000044e:	7b42                	ld	s6,48(sp)
    80000450:	7ba2                	ld	s7,40(sp)
    80000452:	7c02                	ld	s8,32(sp)
    80000454:	6ce2                	ld	s9,24(sp)
    80000456:	6d42                	ld	s10,16(sp)
    80000458:	614d                	addi	sp,sp,176
    8000045a:	8082                	ret

000000008000045c <uartinit>:
#include "declarations.h"
#include "functions.h"

void
uartinit(void)
{
    8000045c:	1141                	addi	sp,sp,-16
    8000045e:	e422                	sd	s0,8(sp)
    80000460:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteRegUART(IER, 0x00);
    80000462:	100007b7          	lui	a5,0x10000
    80000466:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteRegUART(LCR, 0x80);
    8000046a:	f8000713          	li	a4,-128
    8000046e:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteRegUART(0, 0x03);
    80000472:	470d                	li	a4,3
    80000474:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteRegUART(1, 0x00);
    80000478:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteRegUART(LCR, 0x03);
    8000047c:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteRegUART(FCR, 0x07);
    80000480:	471d                	li	a4,7
    80000482:	00e78123          	sb	a4,2(a5)

  // enable receive interrupts.
  WriteRegUART(IER, 0x01);
    80000486:	4705                	li	a4,1
    80000488:	00e780a3          	sb	a4,1(a5)
}
    8000048c:	6422                	ld	s0,8(sp)
    8000048e:	0141                	addi	sp,sp,16
    80000490:	8082                	ret

0000000080000492 <uartputc>:

// write one output character to the UART.
void
uartputc(int c)
{
    80000492:	1141                	addi	sp,sp,-16
    80000494:	e422                	sd	s0,8(sp)
    80000496:	0800                	addi	s0,sp,16
  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadRegUART(LSR) & (1 << 5)) == 0)
    80000498:	10000737          	lui	a4,0x10000
    8000049c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800004a0:	0ff7f793          	andi	a5,a5,255
    800004a4:	0207f793          	andi	a5,a5,32
    800004a8:	dbf5                	beqz	a5,8000049c <uartputc+0xa>
    ;
  WriteRegUART(THR, c);
    800004aa:	0ff57513          	andi	a0,a0,255
    800004ae:	100007b7          	lui	a5,0x10000
    800004b2:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    800004b6:	6422                	ld	s0,8(sp)
    800004b8:	0141                	addi	sp,sp,16
    800004ba:	8082                	ret

00000000800004bc <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800004bc:	1141                	addi	sp,sp,-16
    800004be:	e422                	sd	s0,8(sp)
    800004c0:	0800                	addi	s0,sp,16
  if(ReadRegUART(LSR) & 0x01){
    800004c2:	100007b7          	lui	a5,0x10000
    800004c6:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800004ca:	8b85                	andi	a5,a5,1
    800004cc:	cb91                	beqz	a5,800004e0 <uartgetc+0x24>
    // input data is ready.
    return ReadRegUART(RHR);
    800004ce:	100007b7          	lui	a5,0x10000
    800004d2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800004d6:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800004da:	6422                	ld	s0,8(sp)
    800004dc:	0141                	addi	sp,sp,16
    800004de:	8082                	ret
    return -1;
    800004e0:	557d                	li	a0,-1
    800004e2:	bfe5                	j	800004da <uartgetc+0x1e>

00000000800004e4 <uartintr>:

// trap.c calls here when the uart interrupts.
void
uartintr(void)
{
    800004e4:	1101                	addi	sp,sp,-32
    800004e6:	ec06                	sd	ra,24(sp)
    800004e8:	e822                	sd	s0,16(sp)
    800004ea:	e426                	sd	s1,8(sp)
    800004ec:	1000                	addi	s0,sp,32
  while(1){
    int c = uartgetc();
    if(c == -1)
    800004ee:	54fd                	li	s1,-1
    int c = uartgetc();
    800004f0:	00000097          	auipc	ra,0x0
    800004f4:	fcc080e7          	jalr	-52(ra) # 800004bc <uartgetc>
    if(c == -1)
    800004f8:	00950763          	beq	a0,s1,80000506 <uartintr+0x22>
      break;
    consoleintr(c);
    800004fc:	00000097          	auipc	ra,0x0
    80000500:	b6e080e7          	jalr	-1170(ra) # 8000006a <consoleintr>
  while(1){
    80000504:	b7f5                	j	800004f0 <uartintr+0xc>
  }
}
    80000506:	60e2                	ld	ra,24(sp)
    80000508:	6442                	ld	s0,16(sp)
    8000050a:	64a2                	ld	s1,8(sp)
    8000050c:	6105                	addi	sp,sp,32
    8000050e:	8082                	ret

0000000080000510 <memset>:
#include "declarations.h"
#include "functions.h"

void*
memset(void *dst, int c, uint n)
{
    80000510:	1141                	addi	sp,sp,-16
    80000512:	e422                	sd	s0,8(sp)
    80000514:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000516:	ce09                	beqz	a2,80000530 <memset+0x20>
    80000518:	87aa                	mv	a5,a0
    8000051a:	fff6071b          	addiw	a4,a2,-1
    8000051e:	1702                	slli	a4,a4,0x20
    80000520:	9301                	srli	a4,a4,0x20
    80000522:	0705                	addi	a4,a4,1
    80000524:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000526:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    8000052a:	0785                	addi	a5,a5,1
    8000052c:	fee79de3          	bne	a5,a4,80000526 <memset+0x16>
  }
  return dst;
}
    80000530:	6422                	ld	s0,8(sp)
    80000532:	0141                	addi	sp,sp,16
    80000534:	8082                	ret

0000000080000536 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000536:	1141                	addi	sp,sp,-16
    80000538:	e422                	sd	s0,8(sp)
    8000053a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    8000053c:	ca05                	beqz	a2,8000056c <memcmp+0x36>
    8000053e:	fff6069b          	addiw	a3,a2,-1
    80000542:	1682                	slli	a3,a3,0x20
    80000544:	9281                	srli	a3,a3,0x20
    80000546:	0685                	addi	a3,a3,1
    80000548:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    8000054a:	00054783          	lbu	a5,0(a0)
    8000054e:	0005c703          	lbu	a4,0(a1)
    80000552:	00e79863          	bne	a5,a4,80000562 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000556:	0505                	addi	a0,a0,1
    80000558:	0585                	addi	a1,a1,1
  while(n-- > 0){
    8000055a:	fed518e3          	bne	a0,a3,8000054a <memcmp+0x14>
  }

  return 0;
    8000055e:	4501                	li	a0,0
    80000560:	a019                	j	80000566 <memcmp+0x30>
      return *s1 - *s2;
    80000562:	40e7853b          	subw	a0,a5,a4
}
    80000566:	6422                	ld	s0,8(sp)
    80000568:	0141                	addi	sp,sp,16
    8000056a:	8082                	ret
  return 0;
    8000056c:	4501                	li	a0,0
    8000056e:	bfe5                	j	80000566 <memcmp+0x30>

0000000080000570 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000570:	1141                	addi	sp,sp,-16
    80000572:	e422                	sd	s0,8(sp)
    80000574:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000576:	02a5e563          	bltu	a1,a0,800005a0 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    8000057a:	fff6069b          	addiw	a3,a2,-1
    8000057e:	ce11                	beqz	a2,8000059a <memmove+0x2a>
    80000580:	1682                	slli	a3,a3,0x20
    80000582:	9281                	srli	a3,a3,0x20
    80000584:	0685                	addi	a3,a3,1
    80000586:	96ae                	add	a3,a3,a1
    80000588:	87aa                	mv	a5,a0
      *d++ = *s++;
    8000058a:	0585                	addi	a1,a1,1
    8000058c:	0785                	addi	a5,a5,1
    8000058e:	fff5c703          	lbu	a4,-1(a1)
    80000592:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000596:	fed59ae3          	bne	a1,a3,8000058a <memmove+0x1a>

  return dst;
}
    8000059a:	6422                	ld	s0,8(sp)
    8000059c:	0141                	addi	sp,sp,16
    8000059e:	8082                	ret
  if(s < d && s + n > d){
    800005a0:	02061713          	slli	a4,a2,0x20
    800005a4:	9301                	srli	a4,a4,0x20
    800005a6:	00e587b3          	add	a5,a1,a4
    800005aa:	fcf578e3          	bgeu	a0,a5,8000057a <memmove+0xa>
    d += n;
    800005ae:	972a                	add	a4,a4,a0
    while(n-- > 0)
    800005b0:	fff6069b          	addiw	a3,a2,-1
    800005b4:	d27d                	beqz	a2,8000059a <memmove+0x2a>
    800005b6:	02069613          	slli	a2,a3,0x20
    800005ba:	9201                	srli	a2,a2,0x20
    800005bc:	fff64613          	not	a2,a2
    800005c0:	963e                	add	a2,a2,a5
      *--d = *--s;
    800005c2:	17fd                	addi	a5,a5,-1
    800005c4:	177d                	addi	a4,a4,-1
    800005c6:	0007c683          	lbu	a3,0(a5)
    800005ca:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    800005ce:	fec79ae3          	bne	a5,a2,800005c2 <memmove+0x52>
    800005d2:	b7e1                	j	8000059a <memmove+0x2a>

00000000800005d4 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    800005d4:	1141                	addi	sp,sp,-16
    800005d6:	e406                	sd	ra,8(sp)
    800005d8:	e022                	sd	s0,0(sp)
    800005da:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    800005dc:	00000097          	auipc	ra,0x0
    800005e0:	f94080e7          	jalr	-108(ra) # 80000570 <memmove>
}
    800005e4:	60a2                	ld	ra,8(sp)
    800005e6:	6402                	ld	s0,0(sp)
    800005e8:	0141                	addi	sp,sp,16
    800005ea:	8082                	ret

00000000800005ec <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    800005ec:	1141                	addi	sp,sp,-16
    800005ee:	e422                	sd	s0,8(sp)
    800005f0:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    800005f2:	ce11                	beqz	a2,8000060e <strncmp+0x22>
    800005f4:	00054783          	lbu	a5,0(a0)
    800005f8:	cf89                	beqz	a5,80000612 <strncmp+0x26>
    800005fa:	0005c703          	lbu	a4,0(a1)
    800005fe:	00f71a63          	bne	a4,a5,80000612 <strncmp+0x26>
    n--, p++, q++;
    80000602:	367d                	addiw	a2,a2,-1
    80000604:	0505                	addi	a0,a0,1
    80000606:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000608:	f675                	bnez	a2,800005f4 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000060a:	4501                	li	a0,0
    8000060c:	a809                	j	8000061e <strncmp+0x32>
    8000060e:	4501                	li	a0,0
    80000610:	a039                	j	8000061e <strncmp+0x32>
  if(n == 0)
    80000612:	ca09                	beqz	a2,80000624 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000614:	00054503          	lbu	a0,0(a0)
    80000618:	0005c783          	lbu	a5,0(a1)
    8000061c:	9d1d                	subw	a0,a0,a5
}
    8000061e:	6422                	ld	s0,8(sp)
    80000620:	0141                	addi	sp,sp,16
    80000622:	8082                	ret
    return 0;
    80000624:	4501                	li	a0,0
    80000626:	bfe5                	j	8000061e <strncmp+0x32>

0000000080000628 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000628:	1141                	addi	sp,sp,-16
    8000062a:	e422                	sd	s0,8(sp)
    8000062c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    8000062e:	872a                	mv	a4,a0
    80000630:	8832                	mv	a6,a2
    80000632:	367d                	addiw	a2,a2,-1
    80000634:	01005963          	blez	a6,80000646 <strncpy+0x1e>
    80000638:	0705                	addi	a4,a4,1
    8000063a:	0005c783          	lbu	a5,0(a1)
    8000063e:	fef70fa3          	sb	a5,-1(a4)
    80000642:	0585                	addi	a1,a1,1
    80000644:	f7f5                	bnez	a5,80000630 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000646:	86ba                	mv	a3,a4
    80000648:	00c05c63          	blez	a2,80000660 <strncpy+0x38>
    *s++ = 0;
    8000064c:	0685                	addi	a3,a3,1
    8000064e:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000652:	fff6c793          	not	a5,a3
    80000656:	9fb9                	addw	a5,a5,a4
    80000658:	010787bb          	addw	a5,a5,a6
    8000065c:	fef048e3          	bgtz	a5,8000064c <strncpy+0x24>
  return os;
}
    80000660:	6422                	ld	s0,8(sp)
    80000662:	0141                	addi	sp,sp,16
    80000664:	8082                	ret

0000000080000666 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000666:	1141                	addi	sp,sp,-16
    80000668:	e422                	sd	s0,8(sp)
    8000066a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    8000066c:	02c05363          	blez	a2,80000692 <safestrcpy+0x2c>
    80000670:	fff6069b          	addiw	a3,a2,-1
    80000674:	1682                	slli	a3,a3,0x20
    80000676:	9281                	srli	a3,a3,0x20
    80000678:	96ae                	add	a3,a3,a1
    8000067a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    8000067c:	00d58963          	beq	a1,a3,8000068e <safestrcpy+0x28>
    80000680:	0585                	addi	a1,a1,1
    80000682:	0785                	addi	a5,a5,1
    80000684:	fff5c703          	lbu	a4,-1(a1)
    80000688:	fee78fa3          	sb	a4,-1(a5)
    8000068c:	fb65                	bnez	a4,8000067c <safestrcpy+0x16>
    ;
  *s = 0;
    8000068e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000692:	6422                	ld	s0,8(sp)
    80000694:	0141                	addi	sp,sp,16
    80000696:	8082                	ret

0000000080000698 <strlen>:

int
strlen(const char *s)
{
    80000698:	1141                	addi	sp,sp,-16
    8000069a:	e422                	sd	s0,8(sp)
    8000069c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    8000069e:	00054783          	lbu	a5,0(a0)
    800006a2:	cf91                	beqz	a5,800006be <strlen+0x26>
    800006a4:	0505                	addi	a0,a0,1
    800006a6:	87aa                	mv	a5,a0
    800006a8:	4685                	li	a3,1
    800006aa:	9e89                	subw	a3,a3,a0
    800006ac:	00f6853b          	addw	a0,a3,a5
    800006b0:	0785                	addi	a5,a5,1
    800006b2:	fff7c703          	lbu	a4,-1(a5)
    800006b6:	fb7d                	bnez	a4,800006ac <strlen+0x14>
    ;
  return n;
}
    800006b8:	6422                	ld	s0,8(sp)
    800006ba:	0141                	addi	sp,sp,16
    800006bc:	8082                	ret
  for(n = 0; s[n]; n++)
    800006be:	4501                	li	a0,0
    800006c0:	bfe5                	j	800006b8 <strlen+0x20>

00000000800006c2 <main>:
#include "declarations.h"
#include "functions.h"

void
main()
{
    800006c2:	1141                	addi	sp,sp,-16
    800006c4:	e406                	sd	ra,8(sp)
    800006c6:	e022                	sd	s0,0(sp)
    800006c8:	0800                	addi	s0,sp,16

// supervisor address translation and protection;
// holds the address of the page table.
static inline 
void w_satp(uint64 x) {
    asm volatile("csrw satp, %0" : : "r" (x));
    800006ca:	4781                	li	a5,0
    800006cc:	18079073          	csrw	satp,a5
    w_satp(0);

    consoleinit();
    800006d0:	00000097          	auipc	ra,0x0
    800006d4:	ae4080e7          	jalr	-1308(ra) # 800001b4 <consoleinit>
    printf("\n");
    800006d8:	00002517          	auipc	a0,0x2
    800006dc:	c7850513          	addi	a0,a0,-904 # 80002350 <ret_to_user+0xc68>
    800006e0:	00000097          	auipc	ra,0x0
    800006e4:	ba6080e7          	jalr	-1114(ra) # 80000286 <printf>
    printf("xv6 kernel is booting\n");
    800006e8:	00002517          	auipc	a0,0x2
    800006ec:	93850513          	addi	a0,a0,-1736 # 80002020 <ret_to_user+0x938>
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b96080e7          	jalr	-1130(ra) # 80000286 <printf>
    printf("\n");
    800006f8:	00002517          	auipc	a0,0x2
    800006fc:	c5850513          	addi	a0,a0,-936 # 80002350 <ret_to_user+0xc68>
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b86080e7          	jalr	-1146(ra) # 80000286 <printf>
    trapinithart();                 // install kernel trap vector
    80000708:	00000097          	auipc	ra,0x0
    8000070c:	052080e7          	jalr	82(ra) # 8000075a <trapinithart>
    plicinit();                     // set up interrupt controller
    80000710:	00000097          	auipc	ra,0x0
    80000714:	3ae080e7          	jalr	942(ra) # 80000abe <plicinit>
    plicinithart();                 // ask PLIC for device interrupts
    80000718:	00000097          	auipc	ra,0x0
    8000071c:	3bc080e7          	jalr	956(ra) # 80000ad4 <plicinithart>
    binit();                        // buffer cache
    80000720:	00000097          	auipc	ra,0x0
    80000724:	10c080e7          	jalr	268(ra) # 8000082c <binit>
    virtio_disk_init();             // emulated hard disk
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	472080e7          	jalr	1138(ra) # 80000b9a <virtio_disk_init>
    log_data_init();
    80000730:	00001097          	auipc	ra,0x1
    80000734:	854080e7          	jalr	-1964(ra) # 80000f84 <log_data_init>
    log_data("This data would be placed into the disk\nfrom the starting of the log blocks\n");
    80000738:	00002517          	auipc	a0,0x2
    8000073c:	90050513          	addi	a0,a0,-1792 # 80002038 <ret_to_user+0x950>
    80000740:	00001097          	auipc	ra,0x1
    80000744:	864080e7          	jalr	-1948(ra) # 80000fa4 <log_data>

    printf("done !\n");
    80000748:	00002517          	auipc	a0,0x2
    8000074c:	94050513          	addi	a0,a0,-1728 # 80002088 <ret_to_user+0x9a0>
    80000750:	00000097          	auipc	ra,0x0
    80000754:	b36080e7          	jalr	-1226(ra) # 80000286 <printf>
    while(1); 
    80000758:	a001                	j	80000758 <main+0x96>

000000008000075a <trapinithart>:
#include "functions.h"

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000075a:	1141                	addi	sp,sp,-16
    8000075c:	e422                	sd	s0,8(sp)
    8000075e:	0800                	addi	s0,sp,16
    asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000760:	300027f3          	csrr	a5,mstatus
    w_mstatus(r_mstatus() | MSTATUS_MIE);
}

static inline 
void intr_all_off() {
    w_mstatus(r_mstatus() & ~(MSTATUS_MIE | MSTATUS_MPIE));
    80000764:	f777f793          	andi	a5,a5,-137
    asm volatile("csrw mstatus, %0" : : "r" (x));
    80000768:	30079073          	csrw	mstatus,a5
    asm volatile("csrr %0, mie" : "=r" (x) );
    8000076c:	304027f3          	csrr	a5,mie
    w_mie(r_mie() & (~(MIE_MEIE | MIE_MTIE | MIE_MSIE)));
    80000770:	777d                	lui	a4,0xfffff
    80000772:	77770713          	addi	a4,a4,1911 # fffffffffffff777 <current_process+0xffffffff7ffed8fb>
    80000776:	8ff9                	and	a5,a5,a4
    asm volatile("csrw mie, %0" : : "r" (x));
    80000778:	30479073          	csrw	mie,a5
    asm volatile("csrw mtvec, %0" : : "r" (x));
    8000077c:	00000797          	auipc	a5,0x0
    80000780:	22478793          	addi	a5,a5,548 # 800009a0 <kernelvec>
    80000784:	30579073          	csrw	mtvec,a5
    intr_all_off();
    w_mtvec((uint64)kernelvec); // must be 4-byte aligned to fit in mtvec.
}
    80000788:	6422                	ld	s0,8(sp)
    8000078a:	0141                	addi	sp,sp,16
    8000078c:	8082                	ret

000000008000078e <devintr>:

void devintr()
{
    8000078e:	1101                	addi	sp,sp,-32
    80000790:	ec06                	sd	ra,24(sp)
    80000792:	e822                	sd	s0,16(sp)
    80000794:	e426                	sd	s1,8(sp)
    80000796:	1000                	addi	s0,sp,32
    // irq indicates which device interrupted.
    int irq = plic_claim();
    80000798:	00000097          	auipc	ra,0x0
    8000079c:	36c080e7          	jalr	876(ra) # 80000b04 <plic_claim>
    800007a0:	84aa                	mv	s1,a0

    if(irq == UART0_IRQ)
    800007a2:	47a9                	li	a5,10
    800007a4:	00f50f63          	beq	a0,a5,800007c2 <devintr+0x34>
        uartintr();
    else if(irq == VIRTIO0_IRQ)
    800007a8:	4785                	li	a5,1
    800007aa:	02f50163          	beq	a0,a5,800007cc <devintr+0x3e>
        virtio_disk_intr();

    plic_complete(irq);
    800007ae:	8526                	mv	a0,s1
    800007b0:	00000097          	auipc	ra,0x0
    800007b4:	366080e7          	jalr	870(ra) # 80000b16 <plic_complete>
}
    800007b8:	60e2                	ld	ra,24(sp)
    800007ba:	6442                	ld	s0,16(sp)
    800007bc:	64a2                	ld	s1,8(sp)
    800007be:	6105                	addi	sp,sp,32
    800007c0:	8082                	ret
        uartintr();
    800007c2:	00000097          	auipc	ra,0x0
    800007c6:	d22080e7          	jalr	-734(ra) # 800004e4 <uartintr>
    800007ca:	b7d5                	j	800007ae <devintr+0x20>
        virtio_disk_intr();
    800007cc:	00000097          	auipc	ra,0x0
    800007d0:	73c080e7          	jalr	1852(ra) # 80000f08 <virtio_disk_intr>
    800007d4:	bfe9                	j	800007ae <devintr+0x20>

00000000800007d6 <kernelTrap>:

// interrupts and exceptions from kernel code go here via kernelvec,
// on whatever the current kernel stack is.
// must be 4-byte aligned to fit in stvec.
void kernelTrap() {
    800007d6:	1141                	addi	sp,sp,-16
    800007d8:	e406                	sd	ra,8(sp)
    800007da:	e022                	sd	s0,0(sp)
    800007dc:	0800                	addi	s0,sp,16
    asm volatile("csrr %0, mcause" : "=r" (x) );
    800007de:	342027f3          	csrr	a5,mcause
    uint64 mcause = r_mcause();
    if(mcause & (1ull << 63ull)) {
    800007e2:	0207d763          	bgez	a5,80000810 <kernelTrap+0x3a>
        if((mcause & ((1ull << 63ull) - 1)) != 11)
    800007e6:	0786                	slli	a5,a5,0x1
    800007e8:	8385                	srli	a5,a5,0x1
    800007ea:	472d                	li	a4,11
    800007ec:	00e79a63          	bne	a5,a4,80000800 <kernelTrap+0x2a>
            panic("trap: Exception other than external");
        
        devintr();
    800007f0:	00000097          	auipc	ra,0x0
    800007f4:	f9e080e7          	jalr	-98(ra) # 8000078e <devintr>
    }
    else
        panic("trap: Exception Occurred");
}
    800007f8:	60a2                	ld	ra,8(sp)
    800007fa:	6402                	ld	s0,0(sp)
    800007fc:	0141                	addi	sp,sp,16
    800007fe:	8082                	ret
            panic("trap: Exception other than external");
    80000800:	00002517          	auipc	a0,0x2
    80000804:	89050513          	addi	a0,a0,-1904 # 80002090 <ret_to_user+0x9a8>
    80000808:	00000097          	auipc	ra,0x0
    8000080c:	a3c080e7          	jalr	-1476(ra) # 80000244 <panic>
        panic("trap: Exception Occurred");
    80000810:	00002517          	auipc	a0,0x2
    80000814:	8a850513          	addi	a0,a0,-1880 # 800020b8 <ret_to_user+0x9d0>
    80000818:	00000097          	auipc	ra,0x0
    8000081c:	a2c080e7          	jalr	-1492(ra) # 80000244 <panic>

0000000080000820 <userTrap>:

void userTrap() {
    80000820:	1141                	addi	sp,sp,-16
    80000822:	e422                	sd	s0,8(sp)
    80000824:	0800                	addi	s0,sp,16

    80000826:	6422                	ld	s0,8(sp)
    80000828:	0141                	addi	sp,sp,16
    8000082a:	8082                	ret

000000008000082c <binit>:
#include "declarations.h"
#include "functions.h"

void
binit(void)
{
    8000082c:	1141                	addi	sp,sp,-16
    8000082e:	e422                	sd	s0,8(sp)
    80000830:	0800                	addi	s0,sp,16
    struct buf *b;


    // Create linked list of buffers
    bcache.head.prev = &bcache.head;
    80000832:	00010797          	auipc	a5,0x10
    80000836:	46678793          	addi	a5,a5,1126 # 80010c98 <bcache+0x8000>
    8000083a:	00010717          	auipc	a4,0x10
    8000083e:	1fe70713          	addi	a4,a4,510 # 80010a38 <bcache+0x7da0>
    80000842:	dae7bc23          	sd	a4,-584(a5)
    bcache.head.next = &bcache.head;
    80000846:	dce7b023          	sd	a4,-576(a5)
    for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000084a:	00008797          	auipc	a5,0x8
    8000084e:	44e78793          	addi	a5,a5,1102 # 80008c98 <bcache>
        b->next = bcache.head.next;
    80000852:	00010717          	auipc	a4,0x10
    80000856:	44670713          	addi	a4,a4,1094 # 80010c98 <bcache+0x8000>
        b->prev = &bcache.head;
    8000085a:	00010697          	auipc	a3,0x10
    8000085e:	1de68693          	addi	a3,a3,478 # 80010a38 <bcache+0x7da0>
        b->next = bcache.head.next;
    80000862:	dc073603          	ld	a2,-576(a4)
    80000866:	f390                	sd	a2,32(a5)
        b->prev = &bcache.head;
    80000868:	ef94                	sd	a3,24(a5)
        bcache.head.next->prev = b;
    8000086a:	dc073603          	ld	a2,-576(a4)
    8000086e:	ee1c                	sd	a5,24(a2)
        bcache.head.next = b;
    80000870:	dcf73023          	sd	a5,-576(a4)
    for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80000874:	43078793          	addi	a5,a5,1072
    80000878:	fed795e3          	bne	a5,a3,80000862 <binit+0x36>
    }
}
    8000087c:	6422                	ld	s0,8(sp)
    8000087e:	0141                	addi	sp,sp,16
    80000880:	8082                	ret

0000000080000882 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80000882:	1101                	addi	sp,sp,-32
    80000884:	ec06                	sd	ra,24(sp)
    80000886:	e822                	sd	s0,16(sp)
    80000888:	e426                	sd	s1,8(sp)
    8000088a:	1000                	addi	s0,sp,32
    for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000088c:	00010497          	auipc	s1,0x10
    80000890:	1cc4b483          	ld	s1,460(s1) # 80010a58 <bcache+0x7dc0>
    80000894:	00010797          	auipc	a5,0x10
    80000898:	1a478793          	addi	a5,a5,420 # 80010a38 <bcache+0x7da0>
    8000089c:	02f48863          	beq	s1,a5,800008cc <bread+0x4a>
    800008a0:	873e                	mv	a4,a5
    800008a2:	a021                	j	800008aa <bread+0x28>
    800008a4:	7084                	ld	s1,32(s1)
    800008a6:	02e48363          	beq	s1,a4,800008cc <bread+0x4a>
        if(b->dev == dev && b->blockno == blockno){
    800008aa:	449c                	lw	a5,8(s1)
    800008ac:	fea79ce3          	bne	a5,a0,800008a4 <bread+0x22>
    800008b0:	44dc                	lw	a5,12(s1)
    800008b2:	feb799e3          	bne	a5,a1,800008a4 <bread+0x22>
            b->refcnt++;
    800008b6:	489c                	lw	a5,16(s1)
    800008b8:	2785                	addiw	a5,a5,1
    800008ba:	c89c                	sw	a5,16(s1)
    struct buf *b;

    b = bget(dev, blockno);
    if(!b->valid) {
    800008bc:	409c                	lw	a5,0(s1)
    800008be:	c7a9                	beqz	a5,80000908 <bread+0x86>
        virtio_disk_rw(b, 0);
        b->valid = 1;
    }
    return b;
}
    800008c0:	8526                	mv	a0,s1
    800008c2:	60e2                	ld	ra,24(sp)
    800008c4:	6442                	ld	s0,16(sp)
    800008c6:	64a2                	ld	s1,8(sp)
    800008c8:	6105                	addi	sp,sp,32
    800008ca:	8082                	ret
    for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800008cc:	00010497          	auipc	s1,0x10
    800008d0:	1844b483          	ld	s1,388(s1) # 80010a50 <bcache+0x7db8>
    800008d4:	00010797          	auipc	a5,0x10
    800008d8:	16478793          	addi	a5,a5,356 # 80010a38 <bcache+0x7da0>
    800008dc:	00f48863          	beq	s1,a5,800008ec <bread+0x6a>
    800008e0:	873e                	mv	a4,a5
        if(b->refcnt == 0) {
    800008e2:	489c                	lw	a5,16(s1)
    800008e4:	cf81                	beqz	a5,800008fc <bread+0x7a>
    for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800008e6:	6c84                	ld	s1,24(s1)
    800008e8:	fee49de3          	bne	s1,a4,800008e2 <bread+0x60>
    panic("bget: no buffers");
    800008ec:	00001517          	auipc	a0,0x1
    800008f0:	7ec50513          	addi	a0,a0,2028 # 800020d8 <ret_to_user+0x9f0>
    800008f4:	00000097          	auipc	ra,0x0
    800008f8:	950080e7          	jalr	-1712(ra) # 80000244 <panic>
            b->dev = dev;
    800008fc:	c488                	sw	a0,8(s1)
            b->blockno = blockno;
    800008fe:	c4cc                	sw	a1,12(s1)
            b->valid = 0;
    80000900:	0004a023          	sw	zero,0(s1)
            b->refcnt = 1;
    80000904:	4785                	li	a5,1
    80000906:	c89c                	sw	a5,16(s1)
        virtio_disk_rw(b, 0);
    80000908:	4581                	li	a1,0
    8000090a:	8526                	mv	a0,s1
    8000090c:	00000097          	auipc	ra,0x0
    80000910:	3ba080e7          	jalr	954(ra) # 80000cc6 <virtio_disk_rw>
        b->valid = 1;
    80000914:	4785                	li	a5,1
    80000916:	c09c                	sw	a5,0(s1)
    return b;
    80000918:	b765                	j	800008c0 <bread+0x3e>

000000008000091a <bwrite>:

// Write b's contents to disk.    Must be locked.
void
bwrite(struct buf *b)
{
    8000091a:	1141                	addi	sp,sp,-16
    8000091c:	e406                	sd	ra,8(sp)
    8000091e:	e022                	sd	s0,0(sp)
    80000920:	0800                	addi	s0,sp,16
    virtio_disk_rw(b, 1);
    80000922:	4585                	li	a1,1
    80000924:	00000097          	auipc	ra,0x0
    80000928:	3a2080e7          	jalr	930(ra) # 80000cc6 <virtio_disk_rw>
}
    8000092c:	60a2                	ld	ra,8(sp)
    8000092e:	6402                	ld	s0,0(sp)
    80000930:	0141                	addi	sp,sp,16
    80000932:	8082                	ret

0000000080000934 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80000934:	1141                	addi	sp,sp,-16
    80000936:	e422                	sd	s0,8(sp)
    80000938:	0800                	addi	s0,sp,16

    b->refcnt--;
    8000093a:	491c                	lw	a5,16(a0)
    8000093c:	37fd                	addiw	a5,a5,-1
    8000093e:	0007871b          	sext.w	a4,a5
    80000942:	c91c                	sw	a5,16(a0)
    if (b->refcnt == 0) {
    80000944:	eb05                	bnez	a4,80000974 <brelse+0x40>
        // no one is waiting for it.
        b->next->prev = b->prev;
    80000946:	711c                	ld	a5,32(a0)
    80000948:	6d18                	ld	a4,24(a0)
    8000094a:	ef98                	sd	a4,24(a5)
        b->prev->next = b->next;
    8000094c:	6d1c                	ld	a5,24(a0)
    8000094e:	7118                	ld	a4,32(a0)
    80000950:	f398                	sd	a4,32(a5)
        b->next = bcache.head.next;
    80000952:	00010797          	auipc	a5,0x10
    80000956:	34678793          	addi	a5,a5,838 # 80010c98 <bcache+0x8000>
    8000095a:	dc07b703          	ld	a4,-576(a5)
    8000095e:	f118                	sd	a4,32(a0)
        b->prev = &bcache.head;
    80000960:	00010717          	auipc	a4,0x10
    80000964:	0d870713          	addi	a4,a4,216 # 80010a38 <bcache+0x7da0>
    80000968:	ed18                	sd	a4,24(a0)
        bcache.head.next->prev = b;
    8000096a:	dc07b703          	ld	a4,-576(a5)
    8000096e:	ef08                	sd	a0,24(a4)
        bcache.head.next = b;
    80000970:	dca7b023          	sd	a0,-576(a5)
    }

}
    80000974:	6422                	ld	s0,8(sp)
    80000976:	0141                	addi	sp,sp,16
    80000978:	8082                	ret

000000008000097a <bpin>:

void
bpin(struct buf *b) {
    8000097a:	1141                	addi	sp,sp,-16
    8000097c:	e422                	sd	s0,8(sp)
    8000097e:	0800                	addi	s0,sp,16
    b->refcnt++;
    80000980:	491c                	lw	a5,16(a0)
    80000982:	2785                	addiw	a5,a5,1
    80000984:	c91c                	sw	a5,16(a0)
}
    80000986:	6422                	ld	s0,8(sp)
    80000988:	0141                	addi	sp,sp,16
    8000098a:	8082                	ret

000000008000098c <bunpin>:

void
bunpin(struct buf *b) {
    8000098c:	1141                	addi	sp,sp,-16
    8000098e:	e422                	sd	s0,8(sp)
    80000990:	0800                	addi	s0,sp,16
    b->refcnt--;
    80000992:	491c                	lw	a5,16(a0)
    80000994:	37fd                	addiw	a5,a5,-1
    80000996:	c91c                	sw	a5,16(a0)
}
    80000998:	6422                	ld	s0,8(sp)
    8000099a:	0141                	addi	sp,sp,16
    8000099c:	8082                	ret
	...

00000000800009a0 <kernelvec>:
    800009a0:	1161                	addi	sp,sp,-8
    800009a2:	e016                	sd	t0,0(sp)
    800009a4:	00008297          	auipc	t0,0x8
    800009a8:	14c28293          	addi	t0,t0,332 # 80008af0 <ksa>
    800009ac:	0012b023          	sd	ra,0(t0)
    800009b0:	0032b823          	sd	gp,16(t0)
    800009b4:	0042bc23          	sd	tp,24(t0)
    800009b8:	0262b423          	sd	t1,40(t0)
    800009bc:	0272b823          	sd	t2,48(t0)
    800009c0:	0282bc23          	sd	s0,56(t0)
    800009c4:	0492b023          	sd	s1,64(t0)
    800009c8:	04a2b423          	sd	a0,72(t0)
    800009cc:	04b2b823          	sd	a1,80(t0)
    800009d0:	04c2bc23          	sd	a2,88(t0)
    800009d4:	06d2b023          	sd	a3,96(t0)
    800009d8:	06e2b423          	sd	a4,104(t0)
    800009dc:	06f2b823          	sd	a5,112(t0)
    800009e0:	0702bc23          	sd	a6,120(t0)
    800009e4:	0912b023          	sd	a7,128(t0)
    800009e8:	0922b423          	sd	s2,136(t0)
    800009ec:	0932b823          	sd	s3,144(t0)
    800009f0:	0942bc23          	sd	s4,152(t0)
    800009f4:	0b52b023          	sd	s5,160(t0)
    800009f8:	0b62b423          	sd	s6,168(t0)
    800009fc:	0b72b823          	sd	s7,176(t0)
    80000a00:	0b82bc23          	sd	s8,184(t0)
    80000a04:	0d92b023          	sd	s9,192(t0)
    80000a08:	0da2b423          	sd	s10,200(t0)
    80000a0c:	0db2b823          	sd	s11,208(t0)
    80000a10:	0dc2bc23          	sd	t3,216(t0)
    80000a14:	0fd2b023          	sd	t4,224(t0)
    80000a18:	0fe2b423          	sd	t5,232(t0)
    80000a1c:	0ff2b823          	sd	t6,240(t0)
    80000a20:	6302                	ld	t1,0(sp)
    80000a22:	0121                	addi	sp,sp,8
    80000a24:	0022b423          	sd	sp,8(t0)
    80000a28:	0262b023          	sd	t1,32(t0)
    80000a2c:	dabff0ef          	jal	ra,800007d6 <kernelTrap>
    80000a30:	00008297          	auipc	t0,0x8
    80000a34:	0c028293          	addi	t0,t0,192 # 80008af0 <ksa>
    80000a38:	0002b083          	ld	ra,0(t0)
    80000a3c:	0082b103          	ld	sp,8(t0)
    80000a40:	0102b183          	ld	gp,16(t0)
    80000a44:	0182b203          	ld	tp,24(t0)
    80000a48:	0282b303          	ld	t1,40(t0)
    80000a4c:	0302b383          	ld	t2,48(t0)
    80000a50:	0382b403          	ld	s0,56(t0)
    80000a54:	0402b483          	ld	s1,64(t0)
    80000a58:	0482b503          	ld	a0,72(t0)
    80000a5c:	0502b583          	ld	a1,80(t0)
    80000a60:	0582b603          	ld	a2,88(t0)
    80000a64:	0602b683          	ld	a3,96(t0)
    80000a68:	0682b703          	ld	a4,104(t0)
    80000a6c:	0702b783          	ld	a5,112(t0)
    80000a70:	0782b803          	ld	a6,120(t0)
    80000a74:	0802b883          	ld	a7,128(t0)
    80000a78:	0882b903          	ld	s2,136(t0)
    80000a7c:	0902b983          	ld	s3,144(t0)
    80000a80:	0982ba03          	ld	s4,152(t0)
    80000a84:	0a02ba83          	ld	s5,160(t0)
    80000a88:	0a82bb03          	ld	s6,168(t0)
    80000a8c:	0b02bb83          	ld	s7,176(t0)
    80000a90:	0b82bc03          	ld	s8,184(t0)
    80000a94:	0c02bc83          	ld	s9,192(t0)
    80000a98:	0c82bd03          	ld	s10,200(t0)
    80000a9c:	0d02bd83          	ld	s11,208(t0)
    80000aa0:	0d82be03          	ld	t3,216(t0)
    80000aa4:	0e02be83          	ld	t4,224(t0)
    80000aa8:	0e82bf03          	ld	t5,232(t0)
    80000aac:	0f02bf83          	ld	t6,240(t0)
    80000ab0:	0202b283          	ld	t0,32(t0)
    80000ab4:	30200073          	mret
    80000ab8:	0000                	unimp
    80000aba:	0000                	unimp
	...

0000000080000abe <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80000abe:	1141                	addi	sp,sp,-16
    80000ac0:	e422                	sd	s0,8(sp)
    80000ac2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80000ac4:	0c0007b7          	lui	a5,0xc000
    80000ac8:	4705                	li	a4,1
    80000aca:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80000acc:	c3d8                	sw	a4,4(a5)
}
    80000ace:	6422                	ld	s0,8(sp)
    80000ad0:	0141                	addi	sp,sp,16
    80000ad2:	8082                	ret

0000000080000ad4 <plicinithart>:

void
plicinithart(void)
{
    80000ad4:	1141                	addi	sp,sp,-16
    80000ad6:	e422                	sd	s0,8(sp)
    80000ad8:	0800                	addi	s0,sp,16
  int hart = CPUID; // Only one cpu
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_MENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80000ada:	0c0027b7          	lui	a5,0xc002
    80000ade:	40200713          	li	a4,1026
    80000ae2:	c398                	sw	a4,0(a5)

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_MPRIORITY(hart) = 0;
    80000ae4:	0c2007b7          	lui	a5,0xc200
    80000ae8:	0007a023          	sw	zero,0(a5) # c200000 <_entry-0x73e00000>
}
    80000aec:	6422                	ld	s0,8(sp)
    80000aee:	0141                	addi	sp,sp,16
    80000af0:	8082                	ret

0000000080000af2 <plic_pending>:

// return a bitmap of which IRQs are waiting
// to be served.
uint64
plic_pending(void)
{
    80000af2:	1141                	addi	sp,sp,-16
    80000af4:	e422                	sd	s0,8(sp)
    80000af6:	0800                	addi	s0,sp,16
  //mask = *(uint32*)(PLIC + 0x1000);
  //mask |= (uint64)*(uint32*)(PLIC + 0x1004) << 32;
  mask = *(uint64*)PLIC_PENDING;

  return mask;
}
    80000af8:	0c0017b7          	lui	a5,0xc001
    80000afc:	6388                	ld	a0,0(a5)
    80000afe:	6422                	ld	s0,8(sp)
    80000b00:	0141                	addi	sp,sp,16
    80000b02:	8082                	ret

0000000080000b04 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80000b04:	1141                	addi	sp,sp,-16
    80000b06:	e422                	sd	s0,8(sp)
    80000b08:	0800                	addi	s0,sp,16
  int hart = CPUID;
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_MCLAIM(hart);
  return irq;
}
    80000b0a:	0c2007b7          	lui	a5,0xc200
    80000b0e:	43c8                	lw	a0,4(a5)
    80000b10:	6422                	ld	s0,8(sp)
    80000b12:	0141                	addi	sp,sp,16
    80000b14:	8082                	ret

0000000080000b16 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80000b16:	1141                	addi	sp,sp,-16
    80000b18:	e422                	sd	s0,8(sp)
    80000b1a:	0800                	addi	s0,sp,16
  int hart = CPUID;
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_MCLAIM(hart) = irq;
    80000b1c:	0c2007b7          	lui	a5,0xc200
    80000b20:	c3c8                	sw	a0,4(a5)
}
    80000b22:	6422                	ld	s0,8(sp)
    80000b24:	0141                	addi	sp,sp,16
    80000b26:	8082                	ret

0000000080000b28 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80000b28:	1141                	addi	sp,sp,-16
    80000b2a:	e406                	sd	ra,8(sp)
    80000b2c:	e022                	sd	s0,0(sp)
    80000b2e:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80000b30:	479d                	li	a5,7
    80000b32:	04a7c463          	blt	a5,a0,80000b7a <free_desc+0x52>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80000b36:	00004797          	auipc	a5,0x4
    80000b3a:	4ca78793          	addi	a5,a5,1226 # 80005000 <disk>
    80000b3e:	00a78733          	add	a4,a5,a0
    80000b42:	6789                	lui	a5,0x2
    80000b44:	97ba                	add	a5,a5,a4
    80000b46:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80000b4a:	e3a1                	bnez	a5,80000b8a <free_desc+0x62>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80000b4c:	00451713          	slli	a4,a0,0x4
    80000b50:	00006797          	auipc	a5,0x6
    80000b54:	4b07b783          	ld	a5,1200(a5) # 80007000 <disk+0x2000>
    80000b58:	97ba                	add	a5,a5,a4
    80000b5a:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80000b5e:	00004797          	auipc	a5,0x4
    80000b62:	4a278793          	addi	a5,a5,1186 # 80005000 <disk>
    80000b66:	97aa                	add	a5,a5,a0
    80000b68:	6509                	lui	a0,0x2
    80000b6a:	953e                	add	a0,a0,a5
    80000b6c:	4785                	li	a5,1
    80000b6e:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
}
    80000b72:	60a2                	ld	ra,8(sp)
    80000b74:	6402                	ld	s0,0(sp)
    80000b76:	0141                	addi	sp,sp,16
    80000b78:	8082                	ret
    panic("virtio_disk_intr 1");
    80000b7a:	00001517          	auipc	a0,0x1
    80000b7e:	57650513          	addi	a0,a0,1398 # 800020f0 <ret_to_user+0xa08>
    80000b82:	fffff097          	auipc	ra,0xfffff
    80000b86:	6c2080e7          	jalr	1730(ra) # 80000244 <panic>
    panic("virtio_disk_intr 2");
    80000b8a:	00001517          	auipc	a0,0x1
    80000b8e:	57e50513          	addi	a0,a0,1406 # 80002108 <ret_to_user+0xa20>
    80000b92:	fffff097          	auipc	ra,0xfffff
    80000b96:	6b2080e7          	jalr	1714(ra) # 80000244 <panic>

0000000080000b9a <virtio_disk_init>:
{
    80000b9a:	1101                	addi	sp,sp,-32
    80000b9c:	ec06                	sd	ra,24(sp)
    80000b9e:	e822                	sd	s0,16(sp)
    80000ba0:	e426                	sd	s1,8(sp)
    80000ba2:	1000                	addi	s0,sp,32
  if(*RVIRT(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80000ba4:	100017b7          	lui	a5,0x10001
    80000ba8:	4398                	lw	a4,0(a5)
    80000baa:	2701                	sext.w	a4,a4
    80000bac:	747277b7          	lui	a5,0x74727
    80000bb0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80000bb4:	0ef71163          	bne	a4,a5,80000c96 <virtio_disk_init+0xfc>
     *RVIRT(VIRTIO_MMIO_VERSION) != 1 ||
    80000bb8:	100017b7          	lui	a5,0x10001
    80000bbc:	43dc                	lw	a5,4(a5)
    80000bbe:	2781                	sext.w	a5,a5
  if(*RVIRT(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80000bc0:	4705                	li	a4,1
    80000bc2:	0ce79a63          	bne	a5,a4,80000c96 <virtio_disk_init+0xfc>
     *RVIRT(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80000bc6:	100017b7          	lui	a5,0x10001
    80000bca:	479c                	lw	a5,8(a5)
    80000bcc:	2781                	sext.w	a5,a5
     *RVIRT(VIRTIO_MMIO_VERSION) != 1 ||
    80000bce:	4709                	li	a4,2
    80000bd0:	0ce79363          	bne	a5,a4,80000c96 <virtio_disk_init+0xfc>
     *RVIRT(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80000bd4:	100017b7          	lui	a5,0x10001
    80000bd8:	47d8                	lw	a4,12(a5)
    80000bda:	2701                	sext.w	a4,a4
     *RVIRT(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80000bdc:	554d47b7          	lui	a5,0x554d4
    80000be0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80000be4:	0af71963          	bne	a4,a5,80000c96 <virtio_disk_init+0xfc>
  *RVIRT(VIRTIO_MMIO_STATUS) = status;
    80000be8:	100017b7          	lui	a5,0x10001
    80000bec:	4705                	li	a4,1
    80000bee:	dbb8                	sw	a4,112(a5)
  *RVIRT(VIRTIO_MMIO_STATUS) = status;
    80000bf0:	470d                	li	a4,3
    80000bf2:	dbb8                	sw	a4,112(a5)
  uint64 features = *RVIRT(VIRTIO_MMIO_DEVICE_FEATURES);
    80000bf4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80000bf6:	c7ffe737          	lui	a4,0xc7ffe
    80000bfa:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <current_process+0xffffffff47fec8e3>
    80000bfe:	8f75                	and	a4,a4,a3
  *RVIRT(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80000c00:	2701                	sext.w	a4,a4
    80000c02:	d398                	sw	a4,32(a5)
  *RVIRT(VIRTIO_MMIO_STATUS) = status;
    80000c04:	472d                	li	a4,11
    80000c06:	dbb8                	sw	a4,112(a5)
  *RVIRT(VIRTIO_MMIO_STATUS) = status;
    80000c08:	473d                	li	a4,15
    80000c0a:	dbb8                	sw	a4,112(a5)
  *RVIRT(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80000c0c:	6705                	lui	a4,0x1
    80000c0e:	d798                	sw	a4,40(a5)
  *RVIRT(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80000c10:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *RVIRT(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80000c14:	5bdc                	lw	a5,52(a5)
    80000c16:	2781                	sext.w	a5,a5
  if(max == 0)
    80000c18:	c7d9                	beqz	a5,80000ca6 <virtio_disk_init+0x10c>
  if(max < NUM)
    80000c1a:	471d                	li	a4,7
    80000c1c:	08f77d63          	bgeu	a4,a5,80000cb6 <virtio_disk_init+0x11c>
  *RVIRT(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80000c20:	100014b7          	lui	s1,0x10001
    80000c24:	47a1                	li	a5,8
    80000c26:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80000c28:	6609                	lui	a2,0x2
    80000c2a:	4581                	li	a1,0
    80000c2c:	00004517          	auipc	a0,0x4
    80000c30:	3d450513          	addi	a0,a0,980 # 80005000 <disk>
    80000c34:	00000097          	auipc	ra,0x0
    80000c38:	8dc080e7          	jalr	-1828(ra) # 80000510 <memset>
  *RVIRT(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80000c3c:	00004717          	auipc	a4,0x4
    80000c40:	3c470713          	addi	a4,a4,964 # 80005000 <disk>
    80000c44:	00c75793          	srli	a5,a4,0xc
    80000c48:	2781                	sext.w	a5,a5
    80000c4a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80000c4c:	00006797          	auipc	a5,0x6
    80000c50:	3b478793          	addi	a5,a5,948 # 80007000 <disk+0x2000>
    80000c54:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80000c56:	00004717          	auipc	a4,0x4
    80000c5a:	42a70713          	addi	a4,a4,1066 # 80005080 <disk+0x80>
    80000c5e:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80000c60:	00005717          	auipc	a4,0x5
    80000c64:	3a070713          	addi	a4,a4,928 # 80006000 <disk+0x1000>
    80000c68:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80000c6a:	4705                	li	a4,1
    80000c6c:	00e78c23          	sb	a4,24(a5)
    80000c70:	00e78ca3          	sb	a4,25(a5)
    80000c74:	00e78d23          	sb	a4,26(a5)
    80000c78:	00e78da3          	sb	a4,27(a5)
    80000c7c:	00e78e23          	sb	a4,28(a5)
    80000c80:	00e78ea3          	sb	a4,29(a5)
    80000c84:	00e78f23          	sb	a4,30(a5)
    80000c88:	00e78fa3          	sb	a4,31(a5)
}
    80000c8c:	60e2                	ld	ra,24(sp)
    80000c8e:	6442                	ld	s0,16(sp)
    80000c90:	64a2                	ld	s1,8(sp)
    80000c92:	6105                	addi	sp,sp,32
    80000c94:	8082                	ret
    panic("could not find virtio disk");
    80000c96:	00001517          	auipc	a0,0x1
    80000c9a:	48a50513          	addi	a0,a0,1162 # 80002120 <ret_to_user+0xa38>
    80000c9e:	fffff097          	auipc	ra,0xfffff
    80000ca2:	5a6080e7          	jalr	1446(ra) # 80000244 <panic>
    panic("virtio disk has no queue 0");
    80000ca6:	00001517          	auipc	a0,0x1
    80000caa:	49a50513          	addi	a0,a0,1178 # 80002140 <ret_to_user+0xa58>
    80000cae:	fffff097          	auipc	ra,0xfffff
    80000cb2:	596080e7          	jalr	1430(ra) # 80000244 <panic>
    panic("virtio disk max queue too short");
    80000cb6:	00001517          	auipc	a0,0x1
    80000cba:	4aa50513          	addi	a0,a0,1194 # 80002160 <ret_to_user+0xa78>
    80000cbe:	fffff097          	auipc	ra,0xfffff
    80000cc2:	586080e7          	jalr	1414(ra) # 80000244 <panic>

0000000080000cc6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80000cc6:	7119                	addi	sp,sp,-128
    80000cc8:	fc86                	sd	ra,120(sp)
    80000cca:	f8a2                	sd	s0,112(sp)
    80000ccc:	f4a6                	sd	s1,104(sp)
    80000cce:	f0ca                	sd	s2,96(sp)
    80000cd0:	ecce                	sd	s3,88(sp)
    80000cd2:	e8d2                	sd	s4,80(sp)
    80000cd4:	e4d6                	sd	s5,72(sp)
    80000cd6:	e0da                	sd	s6,64(sp)
    80000cd8:	fc5e                	sd	s7,56(sp)
    80000cda:	f862                	sd	s8,48(sp)
    80000cdc:	f466                	sd	s9,40(sp)
    80000cde:	f06a                	sd	s10,32(sp)
    80000ce0:	0100                	addi	s0,sp,128
    80000ce2:	8c2a                	mv	s8,a0
    80000ce4:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80000ce6:	00c52c83          	lw	s9,12(a0)
    80000cea:	001c9c9b          	slliw	s9,s9,0x1
    80000cee:	1c82                	slli	s9,s9,0x20
    80000cf0:	020cdc93          	srli	s9,s9,0x20
  for(int i = 0; i < 3; i++){
    80000cf4:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80000cf6:	4ba1                	li	s7,8
      disk.free[i] = 0;
    80000cf8:	00004b17          	auipc	s6,0x4
    80000cfc:	308b0b13          	addi	s6,s6,776 # 80005000 <disk>
    80000d00:	6a89                	lui	s5,0x2
  for(int i = 0; i < 3; i++){
    80000d02:	4a0d                	li	s4,3
  for(int i = 0; i < NUM; i++){
    80000d04:	89ca                	mv	s3,s2
  for(int i = 0; i < 3; i++){
    80000d06:	f9040713          	addi	a4,s0,-112
    80000d0a:	84ca                	mv	s1,s2
    80000d0c:	a829                	j	80000d26 <virtio_disk_rw+0x60>
      disk.free[i] = 0;
    80000d0e:	00fb06b3          	add	a3,s6,a5
    80000d12:	96d6                	add	a3,a3,s5
    80000d14:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80000d18:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80000d1a:	0207c563          	bltz	a5,80000d44 <virtio_disk_rw+0x7e>
  for(int i = 0; i < 3; i++){
    80000d1e:	2485                	addiw	s1,s1,1
    80000d20:	0711                	addi	a4,a4,4
    80000d22:	15448b63          	beq	s1,s4,80000e78 <virtio_disk_rw+0x1b2>
    idx[i] = alloc_desc();
    80000d26:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80000d28:	00006697          	auipc	a3,0x6
    80000d2c:	2f068693          	addi	a3,a3,752 # 80007018 <disk+0x2018>
    80000d30:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80000d32:	0006c583          	lbu	a1,0(a3)
    80000d36:	fde1                	bnez	a1,80000d0e <virtio_disk_rw+0x48>
  for(int i = 0; i < NUM; i++){
    80000d38:	2785                	addiw	a5,a5,1
    80000d3a:	0685                	addi	a3,a3,1
    80000d3c:	ff779be3          	bne	a5,s7,80000d32 <virtio_disk_rw+0x6c>
    idx[i] = alloc_desc();
    80000d40:	57fd                	li	a5,-1
    80000d42:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80000d44:	fc9051e3          	blez	s1,80000d06 <virtio_disk_rw+0x40>
        free_desc(idx[j]);
    80000d48:	f9042503          	lw	a0,-112(s0)
    80000d4c:	00000097          	auipc	ra,0x0
    80000d50:	ddc080e7          	jalr	-548(ra) # 80000b28 <free_desc>
      for(int j = 0; j < i; j++)
    80000d54:	4785                	li	a5,1
    80000d56:	fa97d8e3          	bge	a5,s1,80000d06 <virtio_disk_rw+0x40>
        free_desc(idx[j]);
    80000d5a:	f9442503          	lw	a0,-108(s0)
    80000d5e:	00000097          	auipc	ra,0x0
    80000d62:	dca080e7          	jalr	-566(ra) # 80000b28 <free_desc>
      for(int j = 0; j < i; j++)
    80000d66:	4789                	li	a5,2
    80000d68:	f897dfe3          	bge	a5,s1,80000d06 <virtio_disk_rw+0x40>
        free_desc(idx[j]);
    80000d6c:	f9842503          	lw	a0,-104(s0)
    80000d70:	00000097          	auipc	ra,0x0
    80000d74:	db8080e7          	jalr	-584(ra) # 80000b28 <free_desc>
      for(int j = 0; j < i; j++)
    80000d78:	b779                	j	80000d06 <virtio_disk_rw+0x40>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80000d7a:	00006717          	auipc	a4,0x6
    80000d7e:	28673703          	ld	a4,646(a4) # 80007000 <disk+0x2000>
    80000d82:	973e                	add	a4,a4,a5
    80000d84:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80000d88:	00004517          	auipc	a0,0x4
    80000d8c:	27850513          	addi	a0,a0,632 # 80005000 <disk>
    80000d90:	00006717          	auipc	a4,0x6
    80000d94:	27070713          	addi	a4,a4,624 # 80007000 <disk+0x2000>
    80000d98:	6314                	ld	a3,0(a4)
    80000d9a:	96be                	add	a3,a3,a5
    80000d9c:	00c6d603          	lhu	a2,12(a3)
    80000da0:	00166613          	ori	a2,a2,1
    80000da4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80000da8:	f9842683          	lw	a3,-104(s0)
    80000dac:	6310                	ld	a2,0(a4)
    80000dae:	97b2                	add	a5,a5,a2
    80000db0:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0;
    80000db4:	20080613          	addi	a2,a6,512
    80000db8:	0612                	slli	a2,a2,0x4
    80000dba:	962a                	add	a2,a2,a0
    80000dbc:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80000dc0:	00469793          	slli	a5,a3,0x4
    80000dc4:	00073883          	ld	a7,0(a4)
    80000dc8:	98be                	add	a7,a7,a5
    80000dca:	6689                	lui	a3,0x2
    80000dcc:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80000dd0:	96ae                	add	a3,a3,a1
    80000dd2:	96aa                	add	a3,a3,a0
    80000dd4:	00d8b023          	sd	a3,0(a7)
  disk.desc[idx[2]].len = 1;
    80000dd8:	6314                	ld	a3,0(a4)
    80000dda:	96be                	add	a3,a3,a5
    80000ddc:	4585                	li	a1,1
    80000dde:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80000de0:	6314                	ld	a3,0(a4)
    80000de2:	96be                	add	a3,a3,a5
    80000de4:	4889                	li	a7,2
    80000de6:	01169623          	sh	a7,12(a3)
  disk.desc[idx[2]].next = 0;
    80000dea:	6314                	ld	a3,0(a4)
    80000dec:	97b6                	add	a5,a5,a3
    80000dee:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80000df2:	00bc2223          	sw	a1,4(s8)
  disk.info[idx[0]].b = b;
    80000df6:	03863423          	sd	s8,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    80000dfa:	6714                	ld	a3,8(a4)
    80000dfc:	0026d783          	lhu	a5,2(a3)
    80000e00:	8b9d                	andi	a5,a5,7
    80000e02:	2789                	addiw	a5,a5,2
    80000e04:	0786                	slli	a5,a5,0x1
    80000e06:	97b6                	add	a5,a5,a3
    80000e08:	01079023          	sh	a6,0(a5)
  // __sync_synchronize();
  disk.avail[1] = disk.avail[1] + 1;
    80000e0c:	6718                	ld	a4,8(a4)
    80000e0e:	00275783          	lhu	a5,2(a4)
    80000e12:	2785                	addiw	a5,a5,1
    80000e14:	00f71123          	sh	a5,2(a4)

  *RVIRT(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80000e18:	100017b7          	lui	a5,0x10001
    80000e1c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>
    asm volatile("csrr %0, mie" : "=r" (x) );
    80000e20:	304027f3          	csrr	a5,mie
    w_mie(r_mie() | MIE_MEIE);
    80000e24:	6705                	lui	a4,0x1
    80000e26:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000e2a:	8fd9                	or	a5,a5,a4
    asm volatile("csrw mie, %0" : : "r" (x));
    80000e2c:	30479073          	csrw	mie,a5
    asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000e30:	300027f3          	csrr	a5,mstatus
    w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000e34:	0087e793          	ori	a5,a5,8
    asm volatile("csrw mstatus, %0" : : "r" (x));
    80000e38:	30079073          	csrw	mstatus,a5

  // Wait for virtio_disk_intr() to say request has finished.

  intr_dev_on();
  asm("wfi");
    80000e3c:	10500073          	wfi

  disk.info[idx[0]].b = 0;
    80000e40:	f9042483          	lw	s1,-112(s0)
    80000e44:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    80000e48:	0792                	slli	a5,a5,0x4
    80000e4a:	953e                	add	a0,a0,a5
    80000e4c:	02053423          	sd	zero,40(a0)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80000e50:	00006917          	auipc	s2,0x6
    80000e54:	1b090913          	addi	s2,s2,432 # 80007000 <disk+0x2000>
    free_desc(i);
    80000e58:	8526                	mv	a0,s1
    80000e5a:	00000097          	auipc	ra,0x0
    80000e5e:	cce080e7          	jalr	-818(ra) # 80000b28 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80000e62:	0492                	slli	s1,s1,0x4
    80000e64:	00093783          	ld	a5,0(s2)
    80000e68:	94be                	add	s1,s1,a5
    80000e6a:	00c4d783          	lhu	a5,12(s1)
    80000e6e:	8b85                	andi	a5,a5,1
    80000e70:	cfb5                	beqz	a5,80000eec <virtio_disk_rw+0x226>
      i = disk.desc[i].next;
    80000e72:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    80000e76:	b7cd                	j	80000e58 <virtio_disk_rw+0x192>
  if(write)
    80000e78:	01a037b3          	snez	a5,s10
    80000e7c:	f8f42023          	sw	a5,-128(s0)
  buf0.reserved = 0;
    80000e80:	f8042223          	sw	zero,-124(s0)
  buf0.sector = sector;
    80000e84:	f9943423          	sd	s9,-120(s0)
  disk.desc[idx[0]].addr = (uint64) &buf0;
    80000e88:	f9042803          	lw	a6,-112(s0)
    80000e8c:	00481593          	slli	a1,a6,0x4
    80000e90:	00006717          	auipc	a4,0x6
    80000e94:	17070713          	addi	a4,a4,368 # 80007000 <disk+0x2000>
    80000e98:	631c                	ld	a5,0(a4)
    80000e9a:	97ae                	add	a5,a5,a1
    80000e9c:	f8040693          	addi	a3,s0,-128
    80000ea0:	e394                	sd	a3,0(a5)
  disk.desc[idx[0]].len = sizeof(buf0);
    80000ea2:	631c                	ld	a5,0(a4)
    80000ea4:	97ae                	add	a5,a5,a1
    80000ea6:	46c1                	li	a3,16
    80000ea8:	c794                	sw	a3,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80000eaa:	631c                	ld	a5,0(a4)
    80000eac:	97ae                	add	a5,a5,a1
    80000eae:	4685                	li	a3,1
    80000eb0:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80000eb4:	f9442783          	lw	a5,-108(s0)
    80000eb8:	6314                	ld	a3,0(a4)
    80000eba:	96ae                	add	a3,a3,a1
    80000ebc:	00f69723          	sh	a5,14(a3)
  disk.desc[idx[1]].addr = (uint64) b->data;
    80000ec0:	0792                	slli	a5,a5,0x4
    80000ec2:	6314                	ld	a3,0(a4)
    80000ec4:	96be                	add	a3,a3,a5
    80000ec6:	030c0613          	addi	a2,s8,48
    80000eca:	e290                	sd	a2,0(a3)
  disk.desc[idx[1]].len = BSIZE;
    80000ecc:	6318                	ld	a4,0(a4)
    80000ece:	973e                	add	a4,a4,a5
    80000ed0:	40000693          	li	a3,1024
    80000ed4:	c714                	sw	a3,8(a4)
  if(write)
    80000ed6:	ea0d12e3          	bnez	s10,80000d7a <virtio_disk_rw+0xb4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80000eda:	00006717          	auipc	a4,0x6
    80000ede:	12673703          	ld	a4,294(a4) # 80007000 <disk+0x2000>
    80000ee2:	973e                	add	a4,a4,a5
    80000ee4:	4689                	li	a3,2
    80000ee6:	00d71623          	sh	a3,12(a4)
    80000eea:	bd79                	j	80000d88 <virtio_disk_rw+0xc2>
  free_chain(idx[0]);
}
    80000eec:	70e6                	ld	ra,120(sp)
    80000eee:	7446                	ld	s0,112(sp)
    80000ef0:	74a6                	ld	s1,104(sp)
    80000ef2:	7906                	ld	s2,96(sp)
    80000ef4:	69e6                	ld	s3,88(sp)
    80000ef6:	6a46                	ld	s4,80(sp)
    80000ef8:	6aa6                	ld	s5,72(sp)
    80000efa:	6b06                	ld	s6,64(sp)
    80000efc:	7be2                	ld	s7,56(sp)
    80000efe:	7c42                	ld	s8,48(sp)
    80000f00:	7ca2                	ld	s9,40(sp)
    80000f02:	7d02                	ld	s10,32(sp)
    80000f04:	6109                	addi	sp,sp,128
    80000f06:	8082                	ret

0000000080000f08 <virtio_disk_intr>:

void
virtio_disk_intr()
{
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80000f08:	00006717          	auipc	a4,0x6
    80000f0c:	0f870713          	addi	a4,a4,248 # 80007000 <disk+0x2000>
    80000f10:	02075783          	lhu	a5,32(a4)
    80000f14:	6b18                	ld	a4,16(a4)
    80000f16:	00275683          	lhu	a3,2(a4)
    80000f1a:	8ebd                	xor	a3,a3,a5
    80000f1c:	8a9d                	andi	a3,a3,7
    80000f1e:	c6b1                	beqz	a3,80000f6a <virtio_disk_intr+0x62>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    80000f20:	00004597          	auipc	a1,0x4
    80000f24:	0e058593          	addi	a1,a1,224 # 80005000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80000f28:	00006617          	auipc	a2,0x6
    80000f2c:	0d860613          	addi	a2,a2,216 # 80007000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    80000f30:	078e                	slli	a5,a5,0x3
    80000f32:	97ba                	add	a5,a5,a4
    80000f34:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80000f36:	20078713          	addi	a4,a5,512
    80000f3a:	0712                	slli	a4,a4,0x4
    80000f3c:	972e                	add	a4,a4,a1
    80000f3e:	03074703          	lbu	a4,48(a4)
    80000f42:	e70d                	bnez	a4,80000f6c <virtio_disk_intr+0x64>
    disk.info[id].b->disk = 0;   // disk is done with buf
    80000f44:	20078793          	addi	a5,a5,512
    80000f48:	0792                	slli	a5,a5,0x4
    80000f4a:	97ae                	add	a5,a5,a1
    80000f4c:	779c                	ld	a5,40(a5)
    80000f4e:	0007a223          	sw	zero,4(a5)
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80000f52:	02065783          	lhu	a5,32(a2)
    80000f56:	2785                	addiw	a5,a5,1
    80000f58:	8b9d                	andi	a5,a5,7
    80000f5a:	02f61023          	sh	a5,32(a2)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80000f5e:	6a18                	ld	a4,16(a2)
    80000f60:	00275683          	lhu	a3,2(a4)
    80000f64:	8a9d                	andi	a3,a3,7
    80000f66:	fcf695e3          	bne	a3,a5,80000f30 <virtio_disk_intr+0x28>
    80000f6a:	8082                	ret
{
    80000f6c:	1141                	addi	sp,sp,-16
    80000f6e:	e406                	sd	ra,8(sp)
    80000f70:	e022                	sd	s0,0(sp)
    80000f72:	0800                	addi	s0,sp,16
      panic("virtio_disk_intr status");
    80000f74:	00001517          	auipc	a0,0x1
    80000f78:	20c50513          	addi	a0,a0,524 # 80002180 <ret_to_user+0xa98>
    80000f7c:	fffff097          	auipc	ra,0xfffff
    80000f80:	2c8080e7          	jalr	712(ra) # 80000244 <panic>

0000000080000f84 <log_data_init>:

// int block_no, off; // current unused log block, offset this current block
// uint64 temp_reg_state[NREG];

void log_data_init()
{
    80000f84:	1141                	addi	sp,sp,-16
    80000f86:	e422                	sd	s0,8(sp)
    80000f88:	0800                	addi	s0,sp,16
    block_no = LOGSTART;
    80000f8a:	38400793          	li	a5,900
    80000f8e:	00011717          	auipc	a4,0x11
    80000f92:	eef72323          	sw	a5,-282(a4) # 80011e74 <block_no>
    off = 0;
    80000f96:	00011797          	auipc	a5,0x11
    80000f9a:	ec07ad23          	sw	zero,-294(a5) # 80011e70 <off>
}
    80000f9e:	6422                	ld	s0,8(sp)
    80000fa0:	0141                	addi	sp,sp,16
    80000fa2:	8082                	ret

0000000080000fa4 <log_data>:

void log_data(char *prt_str)
{
    80000fa4:	7139                	addi	sp,sp,-64
    80000fa6:	fc06                	sd	ra,56(sp)
    80000fa8:	f822                	sd	s0,48(sp)
    80000faa:	f426                	sd	s1,40(sp)
    80000fac:	f04a                	sd	s2,32(sp)
    80000fae:	ec4e                	sd	s3,24(sp)
    80000fb0:	e852                	sd	s4,16(sp)
    80000fb2:	e456                	sd	s5,8(sp)
    80000fb4:	e05a                	sd	s6,0(sp)
    80000fb6:	0080                	addi	s0,sp,64
    80000fb8:	84aa                	mv	s1,a0
    struct buf *buff = bread(-1, block_no);
    80000fba:	00011597          	auipc	a1,0x11
    80000fbe:	eba5a583          	lw	a1,-326(a1) # 80011e74 <block_no>
    80000fc2:	557d                	li	a0,-1
    80000fc4:	00000097          	auipc	ra,0x0
    80000fc8:	8be080e7          	jalr	-1858(ra) # 80000882 <bread>
    80000fcc:	89aa                	mv	s3,a0

    while((*prt_str) != '\0')
    80000fce:	0004c783          	lbu	a5,0(s1)
    80000fd2:	c7d1                	beqz	a5,8000105e <log_data+0xba>
    {
        if(off == BSIZE)
    80000fd4:	00011917          	auipc	s2,0x11
    80000fd8:	e9c90913          	addi	s2,s2,-356 # 80011e70 <off>
    80000fdc:	40000a13          	li	s4,1024
        {
            bwrite(buff);
            brelse(buff);
            block_no ++;
    80000fe0:	00011a97          	auipc	s5,0x11
    80000fe4:	e94a8a93          	addi	s5,s5,-364 # 80011e74 <block_no>
            off = 0;
            if(block_no == FSSIZE)
    80000fe8:	3e800b13          	li	s6,1000
    80000fec:	a805                	j	8000101c <log_data+0x78>
                panic("log_data");
    80000fee:	00001517          	auipc	a0,0x1
    80000ff2:	1aa50513          	addi	a0,a0,426 # 80002198 <ret_to_user+0xab0>
    80000ff6:	fffff097          	auipc	ra,0xfffff
    80000ffa:	24e080e7          	jalr	590(ra) # 80000244 <panic>

            buff = bread(-1, block_no);
        }
        buff->data[off] = *prt_str;
    80000ffe:	00092783          	lw	a5,0(s2)
    80001002:	0004c683          	lbu	a3,0(s1)
    80001006:	00f98733          	add	a4,s3,a5
    8000100a:	02d70823          	sb	a3,48(a4)
        prt_str ++;
    8000100e:	0485                	addi	s1,s1,1
        off ++;
    80001010:	2785                	addiw	a5,a5,1
    80001012:	00f92023          	sw	a5,0(s2)
    while((*prt_str) != '\0')
    80001016:	0004c783          	lbu	a5,0(s1)
    8000101a:	c3b1                	beqz	a5,8000105e <log_data+0xba>
        if(off == BSIZE)
    8000101c:	00092783          	lw	a5,0(s2)
    80001020:	fd479fe3          	bne	a5,s4,80000ffe <log_data+0x5a>
            bwrite(buff);
    80001024:	854e                	mv	a0,s3
    80001026:	00000097          	auipc	ra,0x0
    8000102a:	8f4080e7          	jalr	-1804(ra) # 8000091a <bwrite>
            brelse(buff);
    8000102e:	854e                	mv	a0,s3
    80001030:	00000097          	auipc	ra,0x0
    80001034:	904080e7          	jalr	-1788(ra) # 80000934 <brelse>
            block_no ++;
    80001038:	000aa583          	lw	a1,0(s5)
    8000103c:	2585                	addiw	a1,a1,1
    8000103e:	0005879b          	sext.w	a5,a1
    80001042:	00baa023          	sw	a1,0(s5)
            off = 0;
    80001046:	00092023          	sw	zero,0(s2)
            if(block_no == FSSIZE)
    8000104a:	fb6782e3          	beq	a5,s6,80000fee <log_data+0x4a>
            buff = bread(-1, block_no);
    8000104e:	2581                	sext.w	a1,a1
    80001050:	557d                	li	a0,-1
    80001052:	00000097          	auipc	ra,0x0
    80001056:	830080e7          	jalr	-2000(ra) # 80000882 <bread>
    8000105a:	89aa                	mv	s3,a0
    8000105c:	b74d                	j	80000ffe <log_data+0x5a>
    }
    bwrite(buff);
    8000105e:	854e                	mv	a0,s3
    80001060:	00000097          	auipc	ra,0x0
    80001064:	8ba080e7          	jalr	-1862(ra) # 8000091a <bwrite>
    brelse(buff);
    80001068:	854e                	mv	a0,s3
    8000106a:	00000097          	auipc	ra,0x0
    8000106e:	8ca080e7          	jalr	-1846(ra) # 80000934 <brelse>
}
    80001072:	70e2                	ld	ra,56(sp)
    80001074:	7442                	ld	s0,48(sp)
    80001076:	74a2                	ld	s1,40(sp)
    80001078:	7902                	ld	s2,32(sp)
    8000107a:	69e2                	ld	s3,24(sp)
    8000107c:	6a42                	ld	s4,16(sp)
    8000107e:	6aa2                	ld	s5,8(sp)
    80001080:	6b02                	ld	s6,0(sp)
    80001082:	6121                	addi	sp,sp,64
    80001084:	8082                	ret

0000000080001086 <printTempRegState>:

// This is called by dump_reg_state function
void printTempRegState()
{
    80001086:	1101                	addi	sp,sp,-32
    80001088:	ec06                	sd	ra,24(sp)
    8000108a:	e822                	sd	s0,16(sp)
    8000108c:	e426                	sd	s1,8(sp)
    8000108e:	1000                	addi	s0,sp,32
    // Just print the registers here
    printf("The register content is: \n");
    80001090:	00001517          	auipc	a0,0x1
    80001094:	11850513          	addi	a0,a0,280 # 800021a8 <ret_to_user+0xac0>
    80001098:	fffff097          	auipc	ra,0xfffff
    8000109c:	1ee080e7          	jalr	494(ra) # 80000286 <printf>
    printf("ra %l\n",temp_reg_state[0]);
    800010a0:	00003497          	auipc	s1,0x3
    800010a4:	f6048493          	addi	s1,s1,-160 # 80004000 <temp_reg_state>
    800010a8:	608c                	ld	a1,0(s1)
    800010aa:	00001517          	auipc	a0,0x1
    800010ae:	11e50513          	addi	a0,a0,286 # 800021c8 <ret_to_user+0xae0>
    800010b2:	fffff097          	auipc	ra,0xfffff
    800010b6:	1d4080e7          	jalr	468(ra) # 80000286 <printf>
    printf("sp %l\n",temp_reg_state[1]);
    800010ba:	648c                	ld	a1,8(s1)
    800010bc:	00001517          	auipc	a0,0x1
    800010c0:	11450513          	addi	a0,a0,276 # 800021d0 <ret_to_user+0xae8>
    800010c4:	fffff097          	auipc	ra,0xfffff
    800010c8:	1c2080e7          	jalr	450(ra) # 80000286 <printf>
    printf("gp = %l\n",temp_reg_state[2]);
    800010cc:	688c                	ld	a1,16(s1)
    800010ce:	00001517          	auipc	a0,0x1
    800010d2:	10a50513          	addi	a0,a0,266 # 800021d8 <ret_to_user+0xaf0>
    800010d6:	fffff097          	auipc	ra,0xfffff
    800010da:	1b0080e7          	jalr	432(ra) # 80000286 <printf>
    printf("tp = %l\n",temp_reg_state[3]);
    800010de:	6c8c                	ld	a1,24(s1)
    800010e0:	00001517          	auipc	a0,0x1
    800010e4:	10850513          	addi	a0,a0,264 # 800021e8 <ret_to_user+0xb00>
    800010e8:	fffff097          	auipc	ra,0xfffff
    800010ec:	19e080e7          	jalr	414(ra) # 80000286 <printf>
    printf("t0 = %l\n",temp_reg_state[4]);
    800010f0:	708c                	ld	a1,32(s1)
    800010f2:	00001517          	auipc	a0,0x1
    800010f6:	10650513          	addi	a0,a0,262 # 800021f8 <ret_to_user+0xb10>
    800010fa:	fffff097          	auipc	ra,0xfffff
    800010fe:	18c080e7          	jalr	396(ra) # 80000286 <printf>
    printf("t1 = %l\n",temp_reg_state[5]);
    80001102:	748c                	ld	a1,40(s1)
    80001104:	00001517          	auipc	a0,0x1
    80001108:	10450513          	addi	a0,a0,260 # 80002208 <ret_to_user+0xb20>
    8000110c:	fffff097          	auipc	ra,0xfffff
    80001110:	17a080e7          	jalr	378(ra) # 80000286 <printf>
    printf("t2 = %l\n",temp_reg_state[6]);
    80001114:	788c                	ld	a1,48(s1)
    80001116:	00001517          	auipc	a0,0x1
    8000111a:	10250513          	addi	a0,a0,258 # 80002218 <ret_to_user+0xb30>
    8000111e:	fffff097          	auipc	ra,0xfffff
    80001122:	168080e7          	jalr	360(ra) # 80000286 <printf>
    printf("s0 = %l\n",temp_reg_state[7]);
    80001126:	7c8c                	ld	a1,56(s1)
    80001128:	00001517          	auipc	a0,0x1
    8000112c:	10050513          	addi	a0,a0,256 # 80002228 <ret_to_user+0xb40>
    80001130:	fffff097          	auipc	ra,0xfffff
    80001134:	156080e7          	jalr	342(ra) # 80000286 <printf>
    printf("s1 = %l\n",temp_reg_state[8]);
    80001138:	60ac                	ld	a1,64(s1)
    8000113a:	00001517          	auipc	a0,0x1
    8000113e:	0fe50513          	addi	a0,a0,254 # 80002238 <ret_to_user+0xb50>
    80001142:	fffff097          	auipc	ra,0xfffff
    80001146:	144080e7          	jalr	324(ra) # 80000286 <printf>
    printf("a0 = %l\n",temp_reg_state[9]);
    8000114a:	64ac                	ld	a1,72(s1)
    8000114c:	00001517          	auipc	a0,0x1
    80001150:	0fc50513          	addi	a0,a0,252 # 80002248 <ret_to_user+0xb60>
    80001154:	fffff097          	auipc	ra,0xfffff
    80001158:	132080e7          	jalr	306(ra) # 80000286 <printf>
    printf("a1 = %l\n",temp_reg_state[10]);
    8000115c:	68ac                	ld	a1,80(s1)
    8000115e:	00001517          	auipc	a0,0x1
    80001162:	0fa50513          	addi	a0,a0,250 # 80002258 <ret_to_user+0xb70>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	120080e7          	jalr	288(ra) # 80000286 <printf>
    printf("a2 = %l\n",temp_reg_state[11]);
    8000116e:	6cac                	ld	a1,88(s1)
    80001170:	00001517          	auipc	a0,0x1
    80001174:	0f850513          	addi	a0,a0,248 # 80002268 <ret_to_user+0xb80>
    80001178:	fffff097          	auipc	ra,0xfffff
    8000117c:	10e080e7          	jalr	270(ra) # 80000286 <printf>
    printf("a3 = %l\n",temp_reg_state[12]);
    80001180:	70ac                	ld	a1,96(s1)
    80001182:	00001517          	auipc	a0,0x1
    80001186:	0f650513          	addi	a0,a0,246 # 80002278 <ret_to_user+0xb90>
    8000118a:	fffff097          	auipc	ra,0xfffff
    8000118e:	0fc080e7          	jalr	252(ra) # 80000286 <printf>
    printf("a4 = %l\n",temp_reg_state[13]);
    80001192:	74ac                	ld	a1,104(s1)
    80001194:	00001517          	auipc	a0,0x1
    80001198:	0f450513          	addi	a0,a0,244 # 80002288 <ret_to_user+0xba0>
    8000119c:	fffff097          	auipc	ra,0xfffff
    800011a0:	0ea080e7          	jalr	234(ra) # 80000286 <printf>
    printf("a5 = %l\n",temp_reg_state[14]);
    800011a4:	78ac                	ld	a1,112(s1)
    800011a6:	00001517          	auipc	a0,0x1
    800011aa:	0f250513          	addi	a0,a0,242 # 80002298 <ret_to_user+0xbb0>
    800011ae:	fffff097          	auipc	ra,0xfffff
    800011b2:	0d8080e7          	jalr	216(ra) # 80000286 <printf>
    printf("a6 = %l\n",temp_reg_state[15]);
    800011b6:	7cac                	ld	a1,120(s1)
    800011b8:	00001517          	auipc	a0,0x1
    800011bc:	0f050513          	addi	a0,a0,240 # 800022a8 <ret_to_user+0xbc0>
    800011c0:	fffff097          	auipc	ra,0xfffff
    800011c4:	0c6080e7          	jalr	198(ra) # 80000286 <printf>
    printf("a7 = %l\n",temp_reg_state[16]);
    800011c8:	60cc                	ld	a1,128(s1)
    800011ca:	00001517          	auipc	a0,0x1
    800011ce:	0ee50513          	addi	a0,a0,238 # 800022b8 <ret_to_user+0xbd0>
    800011d2:	fffff097          	auipc	ra,0xfffff
    800011d6:	0b4080e7          	jalr	180(ra) # 80000286 <printf>
    printf("s2 = %l\n",temp_reg_state[17]);
    800011da:	64cc                	ld	a1,136(s1)
    800011dc:	00001517          	auipc	a0,0x1
    800011e0:	0ec50513          	addi	a0,a0,236 # 800022c8 <ret_to_user+0xbe0>
    800011e4:	fffff097          	auipc	ra,0xfffff
    800011e8:	0a2080e7          	jalr	162(ra) # 80000286 <printf>
    printf("s3 = %l\n",temp_reg_state[18]);
    800011ec:	68cc                	ld	a1,144(s1)
    800011ee:	00001517          	auipc	a0,0x1
    800011f2:	0ea50513          	addi	a0,a0,234 # 800022d8 <ret_to_user+0xbf0>
    800011f6:	fffff097          	auipc	ra,0xfffff
    800011fa:	090080e7          	jalr	144(ra) # 80000286 <printf>
    printf("s4 = %l\n",temp_reg_state[19]);
    800011fe:	6ccc                	ld	a1,152(s1)
    80001200:	00001517          	auipc	a0,0x1
    80001204:	0e850513          	addi	a0,a0,232 # 800022e8 <ret_to_user+0xc00>
    80001208:	fffff097          	auipc	ra,0xfffff
    8000120c:	07e080e7          	jalr	126(ra) # 80000286 <printf>
    printf("s5 = %l\n",temp_reg_state[20]);
    80001210:	70cc                	ld	a1,160(s1)
    80001212:	00001517          	auipc	a0,0x1
    80001216:	0e650513          	addi	a0,a0,230 # 800022f8 <ret_to_user+0xc10>
    8000121a:	fffff097          	auipc	ra,0xfffff
    8000121e:	06c080e7          	jalr	108(ra) # 80000286 <printf>
    printf("s6 = %l\n",temp_reg_state[21]);
    80001222:	74cc                	ld	a1,168(s1)
    80001224:	00001517          	auipc	a0,0x1
    80001228:	0e450513          	addi	a0,a0,228 # 80002308 <ret_to_user+0xc20>
    8000122c:	fffff097          	auipc	ra,0xfffff
    80001230:	05a080e7          	jalr	90(ra) # 80000286 <printf>
    printf("s7 = %l\n",temp_reg_state[22]);
    80001234:	78cc                	ld	a1,176(s1)
    80001236:	00001517          	auipc	a0,0x1
    8000123a:	0e250513          	addi	a0,a0,226 # 80002318 <ret_to_user+0xc30>
    8000123e:	fffff097          	auipc	ra,0xfffff
    80001242:	048080e7          	jalr	72(ra) # 80000286 <printf>
    printf("s8 = %l\n",temp_reg_state[23]);
    80001246:	7ccc                	ld	a1,184(s1)
    80001248:	00001517          	auipc	a0,0x1
    8000124c:	0e050513          	addi	a0,a0,224 # 80002328 <ret_to_user+0xc40>
    80001250:	fffff097          	auipc	ra,0xfffff
    80001254:	036080e7          	jalr	54(ra) # 80000286 <printf>
    printf("s9 = %l\n",temp_reg_state[24]);
    80001258:	60ec                	ld	a1,192(s1)
    8000125a:	00001517          	auipc	a0,0x1
    8000125e:	0de50513          	addi	a0,a0,222 # 80002338 <ret_to_user+0xc50>
    80001262:	fffff097          	auipc	ra,0xfffff
    80001266:	024080e7          	jalr	36(ra) # 80000286 <printf>
    printf("s10 = %l\n",temp_reg_state[25]);
    8000126a:	64ec                	ld	a1,200(s1)
    8000126c:	00001517          	auipc	a0,0x1
    80001270:	0dc50513          	addi	a0,a0,220 # 80002348 <ret_to_user+0xc60>
    80001274:	fffff097          	auipc	ra,0xfffff
    80001278:	012080e7          	jalr	18(ra) # 80000286 <printf>
    printf("s11 = %l\n",temp_reg_state[26]);
    8000127c:	68ec                	ld	a1,208(s1)
    8000127e:	00001517          	auipc	a0,0x1
    80001282:	0da50513          	addi	a0,a0,218 # 80002358 <ret_to_user+0xc70>
    80001286:	fffff097          	auipc	ra,0xfffff
    8000128a:	000080e7          	jalr	ra # 80000286 <printf>
    printf("s12 = %l\n",temp_reg_state[27]);
    8000128e:	6cec                	ld	a1,216(s1)
    80001290:	00001517          	auipc	a0,0x1
    80001294:	0d850513          	addi	a0,a0,216 # 80002368 <ret_to_user+0xc80>
    80001298:	fffff097          	auipc	ra,0xfffff
    8000129c:	fee080e7          	jalr	-18(ra) # 80000286 <printf>
    printf("t3 = %l\n",temp_reg_state[28]);
    800012a0:	70ec                	ld	a1,224(s1)
    800012a2:	00001517          	auipc	a0,0x1
    800012a6:	0d650513          	addi	a0,a0,214 # 80002378 <ret_to_user+0xc90>
    800012aa:	fffff097          	auipc	ra,0xfffff
    800012ae:	fdc080e7          	jalr	-36(ra) # 80000286 <printf>
    printf("t4 = %l\n",temp_reg_state[29]);
    800012b2:	74ec                	ld	a1,232(s1)
    800012b4:	00001517          	auipc	a0,0x1
    800012b8:	0d450513          	addi	a0,a0,212 # 80002388 <ret_to_user+0xca0>
    800012bc:	fffff097          	auipc	ra,0xfffff
    800012c0:	fca080e7          	jalr	-54(ra) # 80000286 <printf>
    printf("t5 = %l\n",temp_reg_state[30]);
    800012c4:	78ec                	ld	a1,240(s1)
    800012c6:	00001517          	auipc	a0,0x1
    800012ca:	0d250513          	addi	a0,a0,210 # 80002398 <ret_to_user+0xcb0>
    800012ce:	fffff097          	auipc	ra,0xfffff
    800012d2:	fb8080e7          	jalr	-72(ra) # 80000286 <printf>
    printf("t6 = %l\n",temp_reg_state[31]);
    800012d6:	7cec                	ld	a1,248(s1)
    800012d8:	00001517          	auipc	a0,0x1
    800012dc:	0d050513          	addi	a0,a0,208 # 800023a8 <ret_to_user+0xcc0>
    800012e0:	fffff097          	auipc	ra,0xfffff
    800012e4:	fa6080e7          	jalr	-90(ra) # 80000286 <printf>
    return;
}
    800012e8:	60e2                	ld	ra,24(sp)
    800012ea:	6442                	ld	s0,16(sp)
    800012ec:	64a2                	ld	s1,8(sp)
    800012ee:	6105                	addi	sp,sp,32
    800012f0:	8082                	ret

00000000800012f2 <dump_reg_state>:
    800012f2:	1161                	addi	sp,sp,-8
    800012f4:	e016                	sd	t0,0(sp)
    800012f6:	00003297          	auipc	t0,0x3
    800012fa:	d0a28293          	addi	t0,t0,-758 # 80004000 <temp_reg_state>
    800012fe:	0032b823          	sd	gp,16(t0)
    80001302:	0042bc23          	sd	tp,24(t0)
    80001306:	0262b423          	sd	t1,40(t0)
    8000130a:	0272b823          	sd	t2,48(t0)
    8000130e:	0282bc23          	sd	s0,56(t0)
    80001312:	0492b023          	sd	s1,64(t0)
    80001316:	04a2b423          	sd	a0,72(t0)
    8000131a:	04b2b823          	sd	a1,80(t0)
    8000131e:	04c2bc23          	sd	a2,88(t0)
    80001322:	06d2b023          	sd	a3,96(t0)
    80001326:	06e2b423          	sd	a4,104(t0)
    8000132a:	06f2b823          	sd	a5,112(t0)
    8000132e:	0702bc23          	sd	a6,120(t0)
    80001332:	0912b023          	sd	a7,128(t0)
    80001336:	0922b423          	sd	s2,136(t0)
    8000133a:	0932b823          	sd	s3,144(t0)
    8000133e:	0942bc23          	sd	s4,152(t0)
    80001342:	0b52b023          	sd	s5,160(t0)
    80001346:	0b62b423          	sd	s6,168(t0)
    8000134a:	0b72b823          	sd	s7,176(t0)
    8000134e:	0b82bc23          	sd	s8,184(t0)
    80001352:	0d92b023          	sd	s9,192(t0)
    80001356:	0da2b423          	sd	s10,200(t0)
    8000135a:	0db2b823          	sd	s11,208(t0)
    8000135e:	0dc2bc23          	sd	t3,216(t0)
    80001362:	0fd2b023          	sd	t4,224(t0)
    80001366:	0fe2b423          	sd	t5,232(t0)
    8000136a:	0ff2b823          	sd	t6,240(t0)
    8000136e:	00810313          	addi	t1,sp,8
    80001372:	0062b423          	sd	t1,8(t0)
    80001376:	6302                	ld	t1,0(sp)
    80001378:	0262b023          	sd	t1,32(t0)
    8000137c:	0282b303          	ld	t1,40(t0)
    80001380:	6282                	ld	t0,0(sp)
    80001382:	0121                	addi	sp,sp,8
    80001384:	7119                	addi	sp,sp,-128
    80001386:	e006                	sd	ra,0(sp)
    80001388:	e416                	sd	t0,8(sp)
    8000138a:	e81a                	sd	t1,16(sp)
    8000138c:	ec1e                	sd	t2,24(sp)
    8000138e:	f072                	sd	t3,32(sp)
    80001390:	f476                	sd	t4,40(sp)
    80001392:	f87a                	sd	t5,48(sp)
    80001394:	fc7e                	sd	t6,56(sp)
    80001396:	e0aa                	sd	a0,64(sp)
    80001398:	e4ae                	sd	a1,72(sp)
    8000139a:	e8b2                	sd	a2,80(sp)
    8000139c:	ecb6                	sd	a3,88(sp)
    8000139e:	f0ba                	sd	a4,96(sp)
    800013a0:	f4be                	sd	a5,104(sp)
    800013a2:	f8c2                	sd	a6,112(sp)
    800013a4:	fcc6                	sd	a7,120(sp)
    800013a6:	ce1ff0ef          	jal	ra,80001086 <printTempRegState>
    800013aa:	6082                	ld	ra,0(sp)
    800013ac:	62a2                	ld	t0,8(sp)
    800013ae:	6342                	ld	t1,16(sp)
    800013b0:	63e2                	ld	t2,24(sp)
    800013b2:	7e02                	ld	t3,32(sp)
    800013b4:	7ea2                	ld	t4,40(sp)
    800013b6:	7f42                	ld	t5,48(sp)
    800013b8:	7fe2                	ld	t6,56(sp)
    800013ba:	6506                	ld	a0,64(sp)
    800013bc:	65a6                	ld	a1,72(sp)
    800013be:	6646                	ld	a2,80(sp)
    800013c0:	66e6                	ld	a3,88(sp)
    800013c2:	7706                	ld	a4,96(sp)
    800013c4:	77a6                	ld	a5,104(sp)
    800013c6:	7846                	ld	a6,112(sp)
    800013c8:	78e6                	ld	a7,120(sp)
    800013ca:	6109                	addi	sp,sp,128
    800013cc:	0121                	addi	sp,sp,8
    800013ce:	8082                	ret

00000000800013d0 <proc_init>:

extern void ret_to_user(void);                      // Returns to user modec
extern void uservec(void);                          // Uservec in uservec.S

void proc_init()
{
    800013d0:	1141                	addi	sp,sp,-16
    800013d2:	e422                	sd	s0,8(sp)
    800013d4:	0800                	addi	s0,sp,16
    for(int i = 0;i < NumberOfProcesses;i++)
    800013d6:	00007797          	auipc	a5,0x7
    800013da:	d3a78793          	addi	a5,a5,-710 # 80008110 <pd+0x110>
    800013de:	00008717          	auipc	a4,0x8
    800013e2:	82270713          	addi	a4,a4,-2014 # 80008c00 <freePageLists+0x8>
        pd[i].slotAllocated = 0;
    800013e6:	0007a023          	sw	zero,0(a5)
    for(int i = 0;i < NumberOfProcesses;i++)
    800013ea:	11878793          	addi	a5,a5,280
    800013ee:	fee79ce3          	bne	a5,a4,800013e6 <proc_init+0x16>
}
    800013f2:	6422                	ld	s0,8(sp)
    800013f4:	0141                	addi	sp,sp,16
    800013f6:	8082                	ret

00000000800013f8 <SelectProcessToRun>:

int SelectProcessToRun()
{
    800013f8:	1141                	addi	sp,sp,-16
    800013fa:	e422                	sd	s0,8(sp)
    800013fc:	0800                	addi	s0,sp,16
    static int next_proc = NumberOfProcesses;
    
    if(current_process > 0
    800013fe:	00011517          	auipc	a0,0x11
    80001402:	a7e52503          	lw	a0,-1410(a0) # 80011e7c <current_process>
    80001406:	00a05e63          	blez	a0,80001422 <SelectProcessToRun+0x2a>
        && pd[current_process].slotAllocated
    8000140a:	11800793          	li	a5,280
    8000140e:	02f50733          	mul	a4,a0,a5
    80001412:	00007797          	auipc	a5,0x7
    80001416:	bee78793          	addi	a5,a5,-1042 # 80008000 <pd>
    8000141a:	97ba                	add	a5,a5,a4
    8000141c:	1107a783          	lw	a5,272(a5)
    80001420:	e385                	bnez	a5,80001440 <SelectProcessToRun+0x48>
        && pd[current_process].timeLeft > 0)
        return current_process;
    
    for(int i = 0;i < NumberOfProcesses;i++)
    80001422:	00002517          	auipc	a0,0x2
    80001426:	bf252503          	lw	a0,-1038(a0) # 80003014 <next_proc.1330>
{
    8000142a:	4729                	li	a4,10
    {
        next_proc ++;
        if(next_proc >= NumberOfProcesses)
    8000142c:	45a5                	li	a1,9
            next_proc = 0;
    8000142e:	4881                	li	a7,0
        
        if(pd[next_proc].slotAllocated
    80001430:	00007617          	auipc	a2,0x7
    80001434:	bd060613          	addi	a2,a2,-1072 # 80008000 <pd>
    80001438:	11800693          	li	a3,280
            && (pd[next_proc].state == Created || pd[next_proc].state == Ready))
    8000143c:	4805                	li	a6,1
    8000143e:	a005                	j	8000145e <SelectProcessToRun+0x66>
        && pd[current_process].timeLeft > 0)
    80001440:	11800793          	li	a5,280
    80001444:	02f50733          	mul	a4,a0,a5
    80001448:	00007797          	auipc	a5,0x7
    8000144c:	bb878793          	addi	a5,a5,-1096 # 80008000 <pd>
    80001450:	97ba                	add	a5,a5,a4
    80001452:	1087b783          	ld	a5,264(a5)
    80001456:	d7f1                	beqz	a5,80001422 <SelectProcessToRun+0x2a>
    80001458:	a8b9                	j	800014b6 <SelectProcessToRun+0xbe>
    for(int i = 0;i < NumberOfProcesses;i++)
    8000145a:	377d                	addiw	a4,a4,-1
    8000145c:	cb21                	beqz	a4,800014ac <SelectProcessToRun+0xb4>
        next_proc ++;
    8000145e:	2505                	addiw	a0,a0,1
        if(next_proc >= NumberOfProcesses)
    80001460:	00a5d363          	bge	a1,a0,80001466 <SelectProcessToRun+0x6e>
            next_proc = 0;
    80001464:	8546                	mv	a0,a7
        if(pd[next_proc].slotAllocated
    80001466:	02d507b3          	mul	a5,a0,a3
    8000146a:	97b2                	add	a5,a5,a2
    8000146c:	1107a783          	lw	a5,272(a5)
    80001470:	d7ed                	beqz	a5,8000145a <SelectProcessToRun+0x62>
            && (pd[next_proc].state == Created || pd[next_proc].state == Ready))
    80001472:	02d507b3          	mul	a5,a0,a3
    80001476:	97b2                	add	a5,a5,a2
    80001478:	1147a783          	lw	a5,276(a5)
    8000147c:	fcf86fe3          	bltu	a6,a5,8000145a <SelectProcessToRun+0x62>
    80001480:	00002797          	auipc	a5,0x2
    80001484:	b8a7aa23          	sw	a0,-1132(a5) # 80003014 <next_proc.1330>
        {
            pd[next_proc].state = Running;
    80001488:	11800793          	li	a5,280
    8000148c:	02f50733          	mul	a4,a0,a5
    80001490:	00007797          	auipc	a5,0x7
    80001494:	b7078793          	addi	a5,a5,-1168 # 80008000 <pd>
    80001498:	97ba                	add	a5,a5,a4
    8000149a:	4709                	li	a4,2
    8000149c:	10e7aa23          	sw	a4,276(a5)
            pd[next_proc].timeLeft = TimeQuantum;
    800014a0:	6761                	lui	a4,0x18
    800014a2:	6a070713          	addi	a4,a4,1696 # 186a0 <_entry-0x7ffe7960>
    800014a6:	10e7b423          	sd	a4,264(a5)
            return next_proc;
    800014aa:	a031                	j	800014b6 <SelectProcessToRun+0xbe>
    800014ac:	00002797          	auipc	a5,0x2
    800014b0:	b6a7a423          	sw	a0,-1176(a5) # 80003014 <next_proc.1330>
        }
    }
    
    return -1;
    800014b4:	557d                	li	a0,-1
}
    800014b6:	6422                	ld	s0,8(sp)
    800014b8:	0141                	addi	sp,sp,16
    800014ba:	8082                	ret

00000000800014bc <RunProcess>:

void RunProcess()
{
    800014bc:	1141                	addi	sp,sp,-16
    800014be:	e406                	sd	ra,8(sp)
    800014c0:	e022                	sd	s0,0(sp)
    800014c2:	0800                	addi	s0,sp,16
    if(current_process < 0)
    800014c4:	00011797          	auipc	a5,0x11
    800014c8:	9b87a783          	lw	a5,-1608(a5) # 80011e7c <current_process>
    800014cc:	0807c663          	bltz	a5,80001558 <RunProcess+0x9c>
    asm volatile("csrr %0, mstatus" : "=r" (x) );
    800014d0:	300027f3          	csrr	a5,mstatus
        panic("RunProcess");                        // for now we panic !
        intr_all_on();
        asm volatile ("wfi");
    }

    w_mstatus(r_mstatus() & (~(3 << 11)));          // setting previous privilege to user mode
    800014d4:	7779                	lui	a4,0xffffe
    800014d6:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <current_process+0xffffffff7ffec983>
    800014da:	8ff9                	and	a5,a5,a4
    asm volatile("csrw mstatus, %0" : : "r" (x));
    800014dc:	30079073          	csrw	mstatus,a5
    asm volatile("csrw mtvec, %0" : : "r" (x));
    800014e0:	00000797          	auipc	a5,0x0
    800014e4:	13078793          	addi	a5,a5,304 # 80001610 <uservec>
    800014e8:	30579073          	csrw	mtvec,a5
                                                    // we have to set timer and software ints on, and set timer value

    w_mtvec((uint64)uservec);                       // Change vector from kernelvec to uservec
    *(uint64 *)CLINT_MTIME = 0ll;
    800014ec:	0200c7b7          	lui	a5,0x200c
    800014f0:	fe07bc23          	sd	zero,-8(a5) # 200bff8 <_entry-0x7dff4008>
    *(uint64 *)CLINT_MTIMECMP(0) = pd[current_process].timeLeft + EPS;
    800014f4:	00011797          	auipc	a5,0x11
    800014f8:	9887a783          	lw	a5,-1656(a5) # 80011e7c <current_process>
    800014fc:	11800713          	li	a4,280
    80001500:	02e78733          	mul	a4,a5,a4
    80001504:	00007797          	auipc	a5,0x7
    80001508:	afc78793          	addi	a5,a5,-1284 # 80008000 <pd>
    8000150c:	97ba                	add	a5,a5,a4
    8000150e:	1087b703          	ld	a4,264(a5)
    80001512:	020047b7          	lui	a5,0x2004
    80001516:	e398                	sd	a4,0(a5)
    asm volatile("csrr %0, mie" : "=r" (x) );
    80001518:	304027f3          	csrr	a5,mie
    w_mie(r_mie() | MIE_MSIE);
    8000151c:	0087e793          	ori	a5,a5,8
    asm volatile("csrw mie, %0" : : "r" (x));
    80001520:	30479073          	csrw	mie,a5
    asm volatile("csrr %0, mstatus" : "=r" (x) );
    80001524:	300027f3          	csrr	a5,mstatus
    w_mstatus(r_mstatus() | MSTATUS_MIE);
    80001528:	0087e793          	ori	a5,a5,8
    asm volatile("csrw mstatus, %0" : : "r" (x));
    8000152c:	30079073          	csrw	mstatus,a5
    asm volatile("csrr %0, mie" : "=r" (x) );
    80001530:	304027f3          	csrr	a5,mie
    w_mie(r_mie() | MIE_MTIE);
    80001534:	0807e793          	ori	a5,a5,128
    asm volatile("csrw mie, %0" : : "r" (x));
    80001538:	30479073          	csrw	mie,a5
    asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000153c:	300027f3          	csrr	a5,mstatus
    w_mstatus(r_mstatus() | MSTATUS_MIE);
    80001540:	0087e793          	ori	a5,a5,8
    asm volatile("csrw mstatus, %0" : : "r" (x));
    80001544:	30079073          	csrw	mstatus,a5
    intr_software_on();
    intr_timer_on();
    ret_to_user();
    80001548:	00000097          	auipc	ra,0x0
    8000154c:	1a0080e7          	jalr	416(ra) # 800016e8 <ret_to_user>
}
    80001550:	60a2                	ld	ra,8(sp)
    80001552:	6402                	ld	s0,0(sp)
    80001554:	0141                	addi	sp,sp,16
    80001556:	8082                	ret
        panic("RunProcess");                        // for now we panic !
    80001558:	00001517          	auipc	a0,0x1
    8000155c:	e6050513          	addi	a0,a0,-416 # 800023b8 <ret_to_user+0xcd0>
    80001560:	fffff097          	auipc	ra,0xfffff
    80001564:	ce4080e7          	jalr	-796(ra) # 80000244 <panic>

0000000080001568 <dispatcher>:

void dispatcher(void)
{
    80001568:	1141                	addi	sp,sp,-16
    8000156a:	e406                	sd	ra,8(sp)
    8000156c:	e022                	sd	s0,0(sp)
    8000156e:	0800                	addi	s0,sp,16
    current_process = SelectProcessToRun();
    80001570:	00000097          	auipc	ra,0x0
    80001574:	e88080e7          	jalr	-376(ra) # 800013f8 <SelectProcessToRun>
    80001578:	00011797          	auipc	a5,0x11
    8000157c:	90a7a223          	sw	a0,-1788(a5) # 80011e7c <current_process>
    RunProcess();
    80001580:	00000097          	auipc	ra,0x0
    80001584:	f3c080e7          	jalr	-196(ra) # 800014bc <RunProcess>
}
    80001588:	60a2                	ld	ra,8(sp)
    8000158a:	6402                	ld	s0,0(sp)
    8000158c:	0141                	addi	sp,sp,16
    8000158e:	8082                	ret

0000000080001590 <timerInterruptHandler>:

void timerInterruptHandler(void)
{
    80001590:	1141                	addi	sp,sp,-16
    80001592:	e406                	sd	ra,8(sp)
    80001594:	e022                	sd	s0,0(sp)
    80001596:	0800                	addi	s0,sp,16
    asm volatile("csrr %0, mstatus" : "=r" (x) );
    80001598:	300027f3          	csrr	a5,mstatus
    if((r_mstatus() & (3 << 11)) != 0)              // if timer interrupt came in any other mode than user mode, then panic
    8000159c:	6709                	lui	a4,0x2
    8000159e:	80070713          	addi	a4,a4,-2048 # 1800 <_entry-0x7fffe800>
    800015a2:	8ff9                	and	a5,a5,a4
    800015a4:	eb9d                	bnez	a5,800015da <timerInterruptHandler+0x4a>
        panic("timerInterruptHandler");

    pd[current_process].timeLeft = 0;
    800015a6:	00011797          	auipc	a5,0x11
    800015aa:	8d67a783          	lw	a5,-1834(a5) # 80011e7c <current_process>
    800015ae:	11800713          	li	a4,280
    800015b2:	02e78733          	mul	a4,a5,a4
    800015b6:	00007797          	auipc	a5,0x7
    800015ba:	a4a78793          	addi	a5,a5,-1462 # 80008000 <pd>
    800015be:	97ba                	add	a5,a5,a4
    800015c0:	1007b423          	sd	zero,264(a5)
    pd[current_process].state = Ready;
    800015c4:	4705                	li	a4,1
    800015c6:	10e7aa23          	sw	a4,276(a5)

    dispatcher();
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	f9e080e7          	jalr	-98(ra) # 80001568 <dispatcher>
}
    800015d2:	60a2                	ld	ra,8(sp)
    800015d4:	6402                	ld	s0,0(sp)
    800015d6:	0141                	addi	sp,sp,16
    800015d8:	8082                	ret
        panic("timerInterruptHandler");
    800015da:	00001517          	auipc	a0,0x1
    800015de:	dee50513          	addi	a0,a0,-530 # 800023c8 <ret_to_user+0xce0>
    800015e2:	fffff097          	auipc	ra,0xfffff
    800015e6:	c62080e7          	jalr	-926(ra) # 80000244 <panic>

00000000800015ea <read_elf>:

void read_elf(int pid, int start_blk, int start_off, int end_block, int end_off)
{
    800015ea:	1141                	addi	sp,sp,-16
    800015ec:	e422                	sd	s0,8(sp)
    800015ee:	0800                	addi	s0,sp,16

}
    800015f0:	6422                	ld	s0,8(sp)
    800015f2:	0141                	addi	sp,sp,16
    800015f4:	8082                	ret
	...

0000000080001600 <err>:
    80001600:	7375                	lui	t1,0xffffd
    80001602:	7265                	lui	tp,0xffff9
    80001604:	6576                	ld	a0,344(sp)
    80001606:	00130063          	beq	t1,ra,80001606 <err+0x6>
    8000160a:	0000                	unimp
    8000160c:	00000013          	nop

0000000080001610 <uservec>:
    80001610:	34011073          	csrw	mscratch,sp
    80001614:	00010117          	auipc	sp,0x10
    80001618:	85c10113          	addi	sp,sp,-1956 # 80010e70 <SystemStack>
    8000161c:	1141                	addi	sp,sp,-16
    8000161e:	e01a                	sd	t1,0(sp)
    80001620:	e416                	sd	t0,8(sp)
    80001622:	00011297          	auipc	t0,0x11
    80001626:	85a28293          	addi	t0,t0,-1958 # 80011e7c <current_process>
    8000162a:	0002b283          	ld	t0,0(t0)
    8000162e:	11800313          	li	t1,280
    80001632:	026282b3          	mul	t0,t0,t1
    80001636:	00007317          	auipc	t1,0x7
    8000163a:	9ca30313          	addi	t1,t1,-1590 # 80008000 <pd>
    8000163e:	929a                	add	t0,t0,t1
    80001640:	6302                	ld	t1,0(sp)
    80001642:	0121                	addi	sp,sp,8
    80001644:	0012b023          	sd	ra,0(t0)
    80001648:	0032b823          	sd	gp,16(t0)
    8000164c:	0042bc23          	sd	tp,24(t0)
    80001650:	0262b423          	sd	t1,40(t0)
    80001654:	0272b823          	sd	t2,48(t0)
    80001658:	0282bc23          	sd	s0,56(t0)
    8000165c:	0492b023          	sd	s1,64(t0)
    80001660:	04a2b423          	sd	a0,72(t0)
    80001664:	04b2b823          	sd	a1,80(t0)
    80001668:	04c2bc23          	sd	a2,88(t0)
    8000166c:	06d2b023          	sd	a3,96(t0)
    80001670:	06e2b423          	sd	a4,104(t0)
    80001674:	06f2b823          	sd	a5,112(t0)
    80001678:	0702bc23          	sd	a6,120(t0)
    8000167c:	0912b023          	sd	a7,128(t0)
    80001680:	0922b423          	sd	s2,136(t0)
    80001684:	0932b823          	sd	s3,144(t0)
    80001688:	0942bc23          	sd	s4,152(t0)
    8000168c:	0b52b023          	sd	s5,160(t0)
    80001690:	0b62b423          	sd	s6,168(t0)
    80001694:	0b72b823          	sd	s7,176(t0)
    80001698:	0b82bc23          	sd	s8,184(t0)
    8000169c:	0d92b023          	sd	s9,192(t0)
    800016a0:	0da2b423          	sd	s10,200(t0)
    800016a4:	0db2b823          	sd	s11,208(t0)
    800016a8:	0dc2bc23          	sd	t3,216(t0)
    800016ac:	0fd2b023          	sd	t4,224(t0)
    800016b0:	0fe2b423          	sd	t5,232(t0)
    800016b4:	0ff2b823          	sd	t6,240(t0)
    800016b8:	34002373          	csrr	t1,mscratch
    800016bc:	0062b423          	sd	t1,8(t0)
    800016c0:	34102373          	csrr	t1,mepc
    800016c4:	0e62bc23          	sd	t1,248(t0)
    800016c8:	18002373          	csrr	t1,satp
    800016cc:	1062b023          	sd	t1,256(t0)
    800016d0:	6302                	ld	t1,0(sp)
    800016d2:	0121                	addi	sp,sp,8
    800016d4:	0262b023          	sd	t1,32(t0)
    800016d8:	948ff0ef          	jal	ra,80000820 <userTrap>
    800016dc:	00000517          	auipc	a0,0x0
    800016e0:	f2450513          	addi	a0,a0,-220 # 80001600 <err>
    800016e4:	b61fe0ef          	jal	ra,80000244 <panic>

00000000800016e8 <ret_to_user>:
    800016e8:	00010297          	auipc	t0,0x10
    800016ec:	79428293          	addi	t0,t0,1940 # 80011e7c <current_process>
    800016f0:	0002b283          	ld	t0,0(t0)
    800016f4:	11800313          	li	t1,280
    800016f8:	026282b3          	mul	t0,t0,t1
    800016fc:	00007317          	auipc	t1,0x7
    80001700:	90430313          	addi	t1,t1,-1788 # 80008000 <pd>
    80001704:	929a                	add	t0,t0,t1
    80001706:	0f82b303          	ld	t1,248(t0)
    8000170a:	34131073          	csrw	mepc,t1
    8000170e:	1002b303          	ld	t1,256(t0)
    80001712:	18031073          	csrw	satp,t1
    80001716:	0002b083          	ld	ra,0(t0)
    8000171a:	0082b103          	ld	sp,8(t0)
    8000171e:	0102b183          	ld	gp,16(t0)
    80001722:	0182b203          	ld	tp,24(t0)
    80001726:	0282b303          	ld	t1,40(t0)
    8000172a:	0302b383          	ld	t2,48(t0)
    8000172e:	0382b403          	ld	s0,56(t0)
    80001732:	0402b483          	ld	s1,64(t0)
    80001736:	0482b503          	ld	a0,72(t0)
    8000173a:	0502b583          	ld	a1,80(t0)
    8000173e:	0582b603          	ld	a2,88(t0)
    80001742:	0602b683          	ld	a3,96(t0)
    80001746:	0682b703          	ld	a4,104(t0)
    8000174a:	0702b783          	ld	a5,112(t0)
    8000174e:	0782b803          	ld	a6,120(t0)
    80001752:	0802b883          	ld	a7,128(t0)
    80001756:	0882b903          	ld	s2,136(t0)
    8000175a:	0902b983          	ld	s3,144(t0)
    8000175e:	0982ba03          	ld	s4,152(t0)
    80001762:	0a02ba83          	ld	s5,160(t0)
    80001766:	0a82bb03          	ld	s6,168(t0)
    8000176a:	0b02bb83          	ld	s7,176(t0)
    8000176e:	0b82bc03          	ld	s8,184(t0)
    80001772:	0c02bc83          	ld	s9,192(t0)
    80001776:	0c82bd03          	ld	s10,200(t0)
    8000177a:	0d02bd83          	ld	s11,208(t0)
    8000177e:	0d82be03          	ld	t3,216(t0)
    80001782:	0e02be83          	ld	t4,224(t0)
    80001786:	0e82bf03          	ld	t5,232(t0)
    8000178a:	0f02bf83          	ld	t6,240(t0)
    8000178e:	0202b283          	ld	t0,32(t0)
    80001792:	30200073          	mret
	...
