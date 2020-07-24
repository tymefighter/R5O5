
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
    80000016:	520000ef          	jal	ra,80000536 <main>

000000008000001a <junk>:
    8000001a:	a001                	j	8000001a <junk>

000000008000001c <consputc>:
// send one character to the uart.
//
void consputc(int c) {
    extern volatile int panicked; // from printf.c

    if(panicked) {
    8000001c:	00012797          	auipc	a5,0x12
    80000020:	e5c7a783          	lw	a5,-420(a5) # 80011e78 <panicked>
    80000024:	c391                	beqz	a5,80000028 <consputc+0xc>
        for(;;)
    80000026:	a001                	j	80000026 <consputc+0xa>
void consputc(int c) {
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
    }
    else {
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
// the console input interrupt handler.
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c) {
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

void consoleinit(void) {
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
#include <stdarg.h>

#include "declarations.h"
#include "functions.h"

static void printint(uint64 xx, int base, int sign) {
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
                break;
            }
    }
}

void panic(char *s) {
    80000244:	1101                	addi	sp,sp,-32
    80000246:	ec06                	sd	ra,24(sp)
    80000248:	e822                	sd	s0,16(sp)
    8000024a:	e426                	sd	s1,8(sp)
    8000024c:	1000                	addi	s0,sp,32
    8000024e:	84aa                	mv	s1,a0
    printf("panic: ");
    80000250:	00002517          	auipc	a0,0x2
    80000254:	db050513          	addi	a0,a0,-592 # 80002000 <printTempRegState+0x10fa>
    80000258:	00000097          	auipc	ra,0x0
    8000025c:	02e080e7          	jalr	46(ra) # 80000286 <printf>
    printf(s);
    80000260:	8526                	mv	a0,s1
    80000262:	00000097          	auipc	ra,0x0
    80000266:	024080e7          	jalr	36(ra) # 80000286 <printf>
    printf("\n");
    8000026a:	00002517          	auipc	a0,0x2
    8000026e:	0ee50513          	addi	a0,a0,238 # 80002358 <printTempRegState+0x1452>
    80000272:	00000097          	auipc	ra,0x0
    80000276:	014080e7          	jalr	20(ra) # 80000286 <printf>
    panicked = 1; // freeze other CPUs
    8000027a:	4785                	li	a5,1
    8000027c:	00012717          	auipc	a4,0x12
    80000280:	bef72e23          	sw	a5,-1028(a4) # 80011e78 <panicked>
    for(;;)
    80000284:	a001                	j	80000284 <panic+0x40>

0000000080000286 <printf>:
void printf(char *fmt, ...) {
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
    800002d4:	0f090913          	addi	s2,s2,240 # 800023c0 <printTempRegState+0x14ba>
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
    800002ec:	d2850513          	addi	a0,a0,-728 # 80002010 <printTempRegState+0x110a>
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
    80000416:	bf6b8b93          	addi	s7,s7,-1034 # 80002008 <printTempRegState+0x1102>
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
//

#include "declarations.h"
#include "functions.h"

void uartinit(void) {
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
void uartputc(int c) {
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
int uartgetc(void) {
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
    }
    else {
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
void uartintr(void) {
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

void* memset(void *dst, int c, uint n) {
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
    80000530:	6422                	ld	s0,8(sp)
    80000532:	0141                	addi	sp,sp,16
    80000534:	8082                	ret

0000000080000536 <main>:
#include "declarations.h"
#include "functions.h"

void main() {
    80000536:	1141                	addi	sp,sp,-16
    80000538:	e406                	sd	ra,8(sp)
    8000053a:	e022                	sd	s0,0(sp)
    8000053c:	0800                	addi	s0,sp,16

// supervisor address translation and protection;
// holds the address of the page table.
static inline 
void w_satp(uint64 x) {
    asm volatile("csrw satp, %0" : : "r" (x));
    8000053e:	4781                	li	a5,0
    80000540:	18079073          	csrw	satp,a5
    w_satp(0);

    consoleinit();
    80000544:	00000097          	auipc	ra,0x0
    80000548:	c70080e7          	jalr	-912(ra) # 800001b4 <consoleinit>
    printf("\n");
    8000054c:	00002517          	auipc	a0,0x2
    80000550:	e0c50513          	addi	a0,a0,-500 # 80002358 <printTempRegState+0x1452>
    80000554:	00000097          	auipc	ra,0x0
    80000558:	d32080e7          	jalr	-718(ra) # 80000286 <printf>
    printf("xv6 kernel is booting\n");
    8000055c:	00002517          	auipc	a0,0x2
    80000560:	ac450513          	addi	a0,a0,-1340 # 80002020 <printTempRegState+0x111a>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	d22080e7          	jalr	-734(ra) # 80000286 <printf>
    printf("\n");
    8000056c:	00002517          	auipc	a0,0x2
    80000570:	dec50513          	addi	a0,a0,-532 # 80002358 <printTempRegState+0x1452>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	d12080e7          	jalr	-750(ra) # 80000286 <printf>
    trapinithart();                 // install kernel trap vector
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	052080e7          	jalr	82(ra) # 800005ce <trapinithart>
    plicinit();                     // set up interrupt controller
    80000584:	00000097          	auipc	ra,0x0
    80000588:	3ba080e7          	jalr	954(ra) # 8000093e <plicinit>
    plicinithart();                 // ask PLIC for device interrupts
    8000058c:	00000097          	auipc	ra,0x0
    80000590:	3c8080e7          	jalr	968(ra) # 80000954 <plicinithart>
    binit();                        // buffer cache
    80000594:	00000097          	auipc	ra,0x0
    80000598:	10c080e7          	jalr	268(ra) # 800006a0 <binit>
    virtio_disk_init();             // emulated hard disk
    8000059c:	00000097          	auipc	ra,0x0
    800005a0:	47e080e7          	jalr	1150(ra) # 80000a1a <virtio_disk_init>
    log_data_init();
    800005a4:	00001097          	auipc	ra,0x1
    800005a8:	860080e7          	jalr	-1952(ra) # 80000e04 <log_data_init>
    log_data("This data would be placed into the disk \
    800005ac:	00002517          	auipc	a0,0x2
    800005b0:	a8c50513          	addi	a0,a0,-1396 # 80002038 <printTempRegState+0x1132>
    800005b4:	00001097          	auipc	ra,0x1
    800005b8:	870080e7          	jalr	-1936(ra) # 80000e24 <log_data>
    \nfrom the starting of the log blocks\n");

    printf("done !\n");
    800005bc:	00002517          	auipc	a0,0x2
    800005c0:	ad450513          	addi	a0,a0,-1324 # 80002090 <printTempRegState+0x118a>
    800005c4:	00000097          	auipc	ra,0x0
    800005c8:	cc2080e7          	jalr	-830(ra) # 80000286 <printf>
    while(1)
    800005cc:	a001                	j	800005cc <main+0x96>

00000000800005ce <trapinithart>:
#include "declarations.h"
#include "functions.h"

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void) {
    800005ce:	1141                	addi	sp,sp,-16
    800005d0:	e422                	sd	s0,8(sp)
    800005d2:	0800                	addi	s0,sp,16
    asm volatile("csrr %0, mstatus" : "=r" (x) );
    800005d4:	300027f3          	csrr	a5,mstatus
    w_mstatus(r_mstatus() | MSTATUS_MIE);
}

static inline 
void intr_all_off() {
    w_mstatus(r_mstatus() & ~(MSTATUS_MIE | MSTATUS_MPIE));
    800005d8:	f777f793          	andi	a5,a5,-137
    asm volatile("csrw mstatus, %0" : : "r" (x));
    800005dc:	30079073          	csrw	mstatus,a5
    asm volatile("csrr %0, mie" : "=r" (x) );
    800005e0:	304027f3          	csrr	a5,mie
    w_mie(r_mie() & (~(MIE_MEIE | MIE_MTIE | MIE_MSIE)));
    800005e4:	777d                	lui	a4,0xfffff
    800005e6:	77770713          	addi	a4,a4,1911 # fffffffffffff777 <current_process+0xffffffff7ffed8fb>
    800005ea:	8ff9                	and	a5,a5,a4
    asm volatile("csrw mie, %0" : : "r" (x));
    800005ec:	30479073          	csrw	mie,a5
    asm volatile("csrw mtvec, %0" : : "r" (x));
    800005f0:	00000797          	auipc	a5,0x0
    800005f4:	23078793          	addi	a5,a5,560 # 80000820 <kernelvec>
    800005f8:	30579073          	csrw	mtvec,a5
    intr_all_off();
    w_mtvec((uint64)kernelvec); // must be 4-byte aligned to fit in mtvec.
}
    800005fc:	6422                	ld	s0,8(sp)
    800005fe:	0141                	addi	sp,sp,16
    80000600:	8082                	ret

0000000080000602 <devintr>:

void devintr() {
    80000602:	1101                	addi	sp,sp,-32
    80000604:	ec06                	sd	ra,24(sp)
    80000606:	e822                	sd	s0,16(sp)
    80000608:	e426                	sd	s1,8(sp)
    8000060a:	1000                	addi	s0,sp,32
    // irq indicates which device interrupted.
    int irq = plic_claim();
    8000060c:	00000097          	auipc	ra,0x0
    80000610:	378080e7          	jalr	888(ra) # 80000984 <plic_claim>
    80000614:	84aa                	mv	s1,a0

    if(irq == UART0_IRQ)
    80000616:	47a9                	li	a5,10
    80000618:	00f50f63          	beq	a0,a5,80000636 <devintr+0x34>
        uartintr();
    else if(irq == VIRTIO0_IRQ)
    8000061c:	4785                	li	a5,1
    8000061e:	02f50163          	beq	a0,a5,80000640 <devintr+0x3e>
        virtio_disk_intr();

    plic_complete(irq);
    80000622:	8526                	mv	a0,s1
    80000624:	00000097          	auipc	ra,0x0
    80000628:	372080e7          	jalr	882(ra) # 80000996 <plic_complete>
}
    8000062c:	60e2                	ld	ra,24(sp)
    8000062e:	6442                	ld	s0,16(sp)
    80000630:	64a2                	ld	s1,8(sp)
    80000632:	6105                	addi	sp,sp,32
    80000634:	8082                	ret
        uartintr();
    80000636:	00000097          	auipc	ra,0x0
    8000063a:	eae080e7          	jalr	-338(ra) # 800004e4 <uartintr>
    8000063e:	b7d5                	j	80000622 <devintr+0x20>
        virtio_disk_intr();
    80000640:	00000097          	auipc	ra,0x0
    80000644:	748080e7          	jalr	1864(ra) # 80000d88 <virtio_disk_intr>
    80000648:	bfe9                	j	80000622 <devintr+0x20>

000000008000064a <kernelTrap>:

// interrupts and exceptions from kernel code go here via kernelvec,
// on whatever the current kernel stack is.
// must be 4-byte aligned to fit in stvec.
void kernelTrap() {
    8000064a:	1141                	addi	sp,sp,-16
    8000064c:	e406                	sd	ra,8(sp)
    8000064e:	e022                	sd	s0,0(sp)
    80000650:	0800                	addi	s0,sp,16
    asm volatile("csrr %0, mcause" : "=r" (x) );
    80000652:	342027f3          	csrr	a5,mcause
    uint64 mcause = r_mcause();
    if(mcause & (1ull << 63ull)) {
    80000656:	0207d763          	bgez	a5,80000684 <kernelTrap+0x3a>
        if((mcause & ((1ull << 63ull) - 1)) != 11)
    8000065a:	0786                	slli	a5,a5,0x1
    8000065c:	8385                	srli	a5,a5,0x1
    8000065e:	472d                	li	a4,11
    80000660:	00e79a63          	bne	a5,a4,80000674 <kernelTrap+0x2a>
            panic("trap: Exception other than external");
        
        devintr();
    80000664:	00000097          	auipc	ra,0x0
    80000668:	f9e080e7          	jalr	-98(ra) # 80000602 <devintr>
    }
    else
        panic("trap: Exception Occurred");
}
    8000066c:	60a2                	ld	ra,8(sp)
    8000066e:	6402                	ld	s0,0(sp)
    80000670:	0141                	addi	sp,sp,16
    80000672:	8082                	ret
            panic("trap: Exception other than external");
    80000674:	00002517          	auipc	a0,0x2
    80000678:	a2450513          	addi	a0,a0,-1500 # 80002098 <printTempRegState+0x1192>
    8000067c:	00000097          	auipc	ra,0x0
    80000680:	bc8080e7          	jalr	-1080(ra) # 80000244 <panic>
        panic("trap: Exception Occurred");
    80000684:	00002517          	auipc	a0,0x2
    80000688:	a3c50513          	addi	a0,a0,-1476 # 800020c0 <printTempRegState+0x11ba>
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	bb8080e7          	jalr	-1096(ra) # 80000244 <panic>

0000000080000694 <userTrap>:

void userTrap() {
    80000694:	1141                	addi	sp,sp,-16
    80000696:	e422                	sd	s0,8(sp)
    80000698:	0800                	addi	s0,sp,16

    8000069a:	6422                	ld	s0,8(sp)
    8000069c:	0141                	addi	sp,sp,16
    8000069e:	8082                	ret

00000000800006a0 <binit>:


#include "declarations.h"
#include "functions.h"

void binit(void) {
    800006a0:	1141                	addi	sp,sp,-16
    800006a2:	e422                	sd	s0,8(sp)
    800006a4:	0800                	addi	s0,sp,16
    struct buf *b;


    // Create linked list of buffers
    bcache.head.prev = &bcache.head;
    800006a6:	00010797          	auipc	a5,0x10
    800006aa:	5f278793          	addi	a5,a5,1522 # 80010c98 <bcache+0x8000>
    800006ae:	00010717          	auipc	a4,0x10
    800006b2:	38a70713          	addi	a4,a4,906 # 80010a38 <bcache+0x7da0>
    800006b6:	dae7bc23          	sd	a4,-584(a5)
    bcache.head.next = &bcache.head;
    800006ba:	dce7b023          	sd	a4,-576(a5)
    for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800006be:	00008797          	auipc	a5,0x8
    800006c2:	5da78793          	addi	a5,a5,1498 # 80008c98 <bcache>
        b->next = bcache.head.next;
    800006c6:	00010717          	auipc	a4,0x10
    800006ca:	5d270713          	addi	a4,a4,1490 # 80010c98 <bcache+0x8000>
        b->prev = &bcache.head;
    800006ce:	00010697          	auipc	a3,0x10
    800006d2:	36a68693          	addi	a3,a3,874 # 80010a38 <bcache+0x7da0>
        b->next = bcache.head.next;
    800006d6:	dc073603          	ld	a2,-576(a4)
    800006da:	f390                	sd	a2,32(a5)
        b->prev = &bcache.head;
    800006dc:	ef94                	sd	a3,24(a5)
        bcache.head.next->prev = b;
    800006de:	dc073603          	ld	a2,-576(a4)
    800006e2:	ee1c                	sd	a5,24(a2)
        bcache.head.next = b;
    800006e4:	dcf73023          	sd	a5,-576(a4)
    for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800006e8:	43078793          	addi	a5,a5,1072
    800006ec:	fed795e3          	bne	a5,a3,800006d6 <binit+0x36>
    }
}
    800006f0:	6422                	ld	s0,8(sp)
    800006f2:	0141                	addi	sp,sp,16
    800006f4:	8082                	ret

00000000800006f6 <bread>:
    }
    panic("bget: no buffers");
}

// Return a locked buf with the contents of the indicated block.
struct buf* bread(uint dev, uint blockno) {
    800006f6:	1101                	addi	sp,sp,-32
    800006f8:	ec06                	sd	ra,24(sp)
    800006fa:	e822                	sd	s0,16(sp)
    800006fc:	e426                	sd	s1,8(sp)
    800006fe:	1000                	addi	s0,sp,32
    for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80000700:	00010497          	auipc	s1,0x10
    80000704:	3584b483          	ld	s1,856(s1) # 80010a58 <bcache+0x7dc0>
    80000708:	00010797          	auipc	a5,0x10
    8000070c:	33078793          	addi	a5,a5,816 # 80010a38 <bcache+0x7da0>
    80000710:	02f48863          	beq	s1,a5,80000740 <bread+0x4a>
    80000714:	873e                	mv	a4,a5
    80000716:	a021                	j	8000071e <bread+0x28>
    80000718:	7084                	ld	s1,32(s1)
    8000071a:	02e48363          	beq	s1,a4,80000740 <bread+0x4a>
        if(b->dev == dev && b->blockno == blockno){
    8000071e:	449c                	lw	a5,8(s1)
    80000720:	fea79ce3          	bne	a5,a0,80000718 <bread+0x22>
    80000724:	44dc                	lw	a5,12(s1)
    80000726:	feb799e3          	bne	a5,a1,80000718 <bread+0x22>
            b->refcnt++;
    8000072a:	489c                	lw	a5,16(s1)
    8000072c:	2785                	addiw	a5,a5,1
    8000072e:	c89c                	sw	a5,16(s1)
    struct buf *b;

    b = bget(dev, blockno);
    if(!b->valid) {
    80000730:	409c                	lw	a5,0(s1)
    80000732:	c7a9                	beqz	a5,8000077c <bread+0x86>
        virtio_disk_rw(b, 0);
        b->valid = 1;
    }
    return b;
}
    80000734:	8526                	mv	a0,s1
    80000736:	60e2                	ld	ra,24(sp)
    80000738:	6442                	ld	s0,16(sp)
    8000073a:	64a2                	ld	s1,8(sp)
    8000073c:	6105                	addi	sp,sp,32
    8000073e:	8082                	ret
    for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80000740:	00010497          	auipc	s1,0x10
    80000744:	3104b483          	ld	s1,784(s1) # 80010a50 <bcache+0x7db8>
    80000748:	00010797          	auipc	a5,0x10
    8000074c:	2f078793          	addi	a5,a5,752 # 80010a38 <bcache+0x7da0>
    80000750:	00f48863          	beq	s1,a5,80000760 <bread+0x6a>
    80000754:	873e                	mv	a4,a5
        if(b->refcnt == 0) {
    80000756:	489c                	lw	a5,16(s1)
    80000758:	cf81                	beqz	a5,80000770 <bread+0x7a>
    for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000075a:	6c84                	ld	s1,24(s1)
    8000075c:	fee49de3          	bne	s1,a4,80000756 <bread+0x60>
    panic("bget: no buffers");
    80000760:	00002517          	auipc	a0,0x2
    80000764:	98050513          	addi	a0,a0,-1664 # 800020e0 <printTempRegState+0x11da>
    80000768:	00000097          	auipc	ra,0x0
    8000076c:	adc080e7          	jalr	-1316(ra) # 80000244 <panic>
            b->dev = dev;
    80000770:	c488                	sw	a0,8(s1)
            b->blockno = blockno;
    80000772:	c4cc                	sw	a1,12(s1)
            b->valid = 0;
    80000774:	0004a023          	sw	zero,0(s1)
            b->refcnt = 1;
    80000778:	4785                	li	a5,1
    8000077a:	c89c                	sw	a5,16(s1)
        virtio_disk_rw(b, 0);
    8000077c:	4581                	li	a1,0
    8000077e:	8526                	mv	a0,s1
    80000780:	00000097          	auipc	ra,0x0
    80000784:	3c6080e7          	jalr	966(ra) # 80000b46 <virtio_disk_rw>
        b->valid = 1;
    80000788:	4785                	li	a5,1
    8000078a:	c09c                	sw	a5,0(s1)
    return b;
    8000078c:	b765                	j	80000734 <bread+0x3e>

000000008000078e <bwrite>:

// Write b's contents to disk.    Must be locked.
void
bwrite(struct buf *b)
{
    8000078e:	1141                	addi	sp,sp,-16
    80000790:	e406                	sd	ra,8(sp)
    80000792:	e022                	sd	s0,0(sp)
    80000794:	0800                	addi	s0,sp,16
    virtio_disk_rw(b, 1);
    80000796:	4585                	li	a1,1
    80000798:	00000097          	auipc	ra,0x0
    8000079c:	3ae080e7          	jalr	942(ra) # 80000b46 <virtio_disk_rw>
}
    800007a0:	60a2                	ld	ra,8(sp)
    800007a2:	6402                	ld	s0,0(sp)
    800007a4:	0141                	addi	sp,sp,16
    800007a6:	8082                	ret

00000000800007a8 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void brelse(struct buf *b) {
    800007a8:	1141                	addi	sp,sp,-16
    800007aa:	e422                	sd	s0,8(sp)
    800007ac:	0800                	addi	s0,sp,16

    b->refcnt--;
    800007ae:	491c                	lw	a5,16(a0)
    800007b0:	37fd                	addiw	a5,a5,-1
    800007b2:	0007871b          	sext.w	a4,a5
    800007b6:	c91c                	sw	a5,16(a0)
    if (b->refcnt == 0) {
    800007b8:	eb05                	bnez	a4,800007e8 <brelse+0x40>
        // no one is waiting for it.
        b->next->prev = b->prev;
    800007ba:	711c                	ld	a5,32(a0)
    800007bc:	6d18                	ld	a4,24(a0)
    800007be:	ef98                	sd	a4,24(a5)
        b->prev->next = b->next;
    800007c0:	6d1c                	ld	a5,24(a0)
    800007c2:	7118                	ld	a4,32(a0)
    800007c4:	f398                	sd	a4,32(a5)
        b->next = bcache.head.next;
    800007c6:	00010797          	auipc	a5,0x10
    800007ca:	4d278793          	addi	a5,a5,1234 # 80010c98 <bcache+0x8000>
    800007ce:	dc07b703          	ld	a4,-576(a5)
    800007d2:	f118                	sd	a4,32(a0)
        b->prev = &bcache.head;
    800007d4:	00010717          	auipc	a4,0x10
    800007d8:	26470713          	addi	a4,a4,612 # 80010a38 <bcache+0x7da0>
    800007dc:	ed18                	sd	a4,24(a0)
        bcache.head.next->prev = b;
    800007de:	dc07b703          	ld	a4,-576(a5)
    800007e2:	ef08                	sd	a0,24(a4)
        bcache.head.next = b;
    800007e4:	dca7b023          	sd	a0,-576(a5)
    }

}
    800007e8:	6422                	ld	s0,8(sp)
    800007ea:	0141                	addi	sp,sp,16
    800007ec:	8082                	ret

00000000800007ee <bpin>:

void bpin(struct buf *b) {
    800007ee:	1141                	addi	sp,sp,-16
    800007f0:	e422                	sd	s0,8(sp)
    800007f2:	0800                	addi	s0,sp,16
    b->refcnt++;
    800007f4:	491c                	lw	a5,16(a0)
    800007f6:	2785                	addiw	a5,a5,1
    800007f8:	c91c                	sw	a5,16(a0)
}
    800007fa:	6422                	ld	s0,8(sp)
    800007fc:	0141                	addi	sp,sp,16
    800007fe:	8082                	ret

0000000080000800 <bunpin>:

void bunpin(struct buf *b) {
    80000800:	1141                	addi	sp,sp,-16
    80000802:	e422                	sd	s0,8(sp)
    80000804:	0800                	addi	s0,sp,16
    b->refcnt--;
    80000806:	491c                	lw	a5,16(a0)
    80000808:	37fd                	addiw	a5,a5,-1
    8000080a:	c91c                	sw	a5,16(a0)
    8000080c:	6422                	ld	s0,8(sp)
    8000080e:	0141                	addi	sp,sp,16
    80000810:	8082                	ret
	...

0000000080000820 <kernelvec>:
    80000820:	1161                	addi	sp,sp,-8
    80000822:	e016                	sd	t0,0(sp)
    80000824:	00008297          	auipc	t0,0x8
    80000828:	2cc28293          	addi	t0,t0,716 # 80008af0 <ksa>
    8000082c:	0012b023          	sd	ra,0(t0)
    80000830:	0032b823          	sd	gp,16(t0)
    80000834:	0042bc23          	sd	tp,24(t0)
    80000838:	0262b423          	sd	t1,40(t0)
    8000083c:	0272b823          	sd	t2,48(t0)
    80000840:	0282bc23          	sd	s0,56(t0)
    80000844:	0492b023          	sd	s1,64(t0)
    80000848:	04a2b423          	sd	a0,72(t0)
    8000084c:	04b2b823          	sd	a1,80(t0)
    80000850:	04c2bc23          	sd	a2,88(t0)
    80000854:	06d2b023          	sd	a3,96(t0)
    80000858:	06e2b423          	sd	a4,104(t0)
    8000085c:	06f2b823          	sd	a5,112(t0)
    80000860:	0702bc23          	sd	a6,120(t0)
    80000864:	0912b023          	sd	a7,128(t0)
    80000868:	0922b423          	sd	s2,136(t0)
    8000086c:	0932b823          	sd	s3,144(t0)
    80000870:	0942bc23          	sd	s4,152(t0)
    80000874:	0b52b023          	sd	s5,160(t0)
    80000878:	0b62b423          	sd	s6,168(t0)
    8000087c:	0b72b823          	sd	s7,176(t0)
    80000880:	0b82bc23          	sd	s8,184(t0)
    80000884:	0d92b023          	sd	s9,192(t0)
    80000888:	0da2b423          	sd	s10,200(t0)
    8000088c:	0db2b823          	sd	s11,208(t0)
    80000890:	0dc2bc23          	sd	t3,216(t0)
    80000894:	0fd2b023          	sd	t4,224(t0)
    80000898:	0fe2b423          	sd	t5,232(t0)
    8000089c:	0ff2b823          	sd	t6,240(t0)
    800008a0:	6302                	ld	t1,0(sp)
    800008a2:	0121                	addi	sp,sp,8
    800008a4:	0022b423          	sd	sp,8(t0)
    800008a8:	0262b023          	sd	t1,32(t0)
    800008ac:	d9fff0ef          	jal	ra,8000064a <kernelTrap>
    800008b0:	00008297          	auipc	t0,0x8
    800008b4:	24028293          	addi	t0,t0,576 # 80008af0 <ksa>
    800008b8:	0002b083          	ld	ra,0(t0)
    800008bc:	0082b103          	ld	sp,8(t0)
    800008c0:	0102b183          	ld	gp,16(t0)
    800008c4:	0182b203          	ld	tp,24(t0)
    800008c8:	0282b303          	ld	t1,40(t0)
    800008cc:	0302b383          	ld	t2,48(t0)
    800008d0:	0382b403          	ld	s0,56(t0)
    800008d4:	0402b483          	ld	s1,64(t0)
    800008d8:	0482b503          	ld	a0,72(t0)
    800008dc:	0502b583          	ld	a1,80(t0)
    800008e0:	0582b603          	ld	a2,88(t0)
    800008e4:	0602b683          	ld	a3,96(t0)
    800008e8:	0682b703          	ld	a4,104(t0)
    800008ec:	0702b783          	ld	a5,112(t0)
    800008f0:	0782b803          	ld	a6,120(t0)
    800008f4:	0802b883          	ld	a7,128(t0)
    800008f8:	0882b903          	ld	s2,136(t0)
    800008fc:	0902b983          	ld	s3,144(t0)
    80000900:	0982ba03          	ld	s4,152(t0)
    80000904:	0a02ba83          	ld	s5,160(t0)
    80000908:	0a82bb03          	ld	s6,168(t0)
    8000090c:	0b02bb83          	ld	s7,176(t0)
    80000910:	0b82bc03          	ld	s8,184(t0)
    80000914:	0c02bc83          	ld	s9,192(t0)
    80000918:	0c82bd03          	ld	s10,200(t0)
    8000091c:	0d02bd83          	ld	s11,208(t0)
    80000920:	0d82be03          	ld	t3,216(t0)
    80000924:	0e02be83          	ld	t4,224(t0)
    80000928:	0e82bf03          	ld	t5,232(t0)
    8000092c:	0f02bf83          	ld	t6,240(t0)
    80000930:	0202b283          	ld	t0,32(t0)
    80000934:	30200073          	mret
    80000938:	0000                	unimp
    8000093a:	0000                	unimp
	...

000000008000093e <plicinit>:

//
// the riscv Platform Level Interrupt Controller (PLIC).
//

void plicinit(void) {
    8000093e:	1141                	addi	sp,sp,-16
    80000940:	e422                	sd	s0,8(sp)
    80000942:	0800                	addi	s0,sp,16
    // set desired IRQ priorities non-zero (otherwise disabled).
    *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80000944:	0c0007b7          	lui	a5,0xc000
    80000948:	4705                	li	a4,1
    8000094a:	d798                	sw	a4,40(a5)
    *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000094c:	c3d8                	sw	a4,4(a5)
}
    8000094e:	6422                	ld	s0,8(sp)
    80000950:	0141                	addi	sp,sp,16
    80000952:	8082                	ret

0000000080000954 <plicinithart>:

void plicinithart(void) {
    80000954:	1141                	addi	sp,sp,-16
    80000956:	e422                	sd	s0,8(sp)
    80000958:	0800                	addi	s0,sp,16
    int hart = CPUID; // Only one cpu
    
    // set uart's enable bit for this hart's S-mode. 
    *(uint32*)PLIC_MENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    8000095a:	0c0027b7          	lui	a5,0xc002
    8000095e:	40200713          	li	a4,1026
    80000962:	c398                	sw	a4,0(a5)

    // set this hart's S-mode priority threshold to 0.
    *(uint32*)PLIC_MPRIORITY(hart) = 0;
    80000964:	0c2007b7          	lui	a5,0xc200
    80000968:	0007a023          	sw	zero,0(a5) # c200000 <_entry-0x73e00000>
}
    8000096c:	6422                	ld	s0,8(sp)
    8000096e:	0141                	addi	sp,sp,16
    80000970:	8082                	ret

0000000080000972 <plic_pending>:

// return a bitmap of which IRQs are waiting
// to be served.
uint64 plic_pending(void) {
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
    //mask = *(uint32*)(PLIC + 0x1000);
    //mask |= (uint64)*(uint32*)(PLIC + 0x1004) << 32;
    mask = *(uint64*)PLIC_PENDING;

    return mask;
}
    80000978:	0c0017b7          	lui	a5,0xc001
    8000097c:	6388                	ld	a0,0(a5)
    8000097e:	6422                	ld	s0,8(sp)
    80000980:	0141                	addi	sp,sp,16
    80000982:	8082                	ret

0000000080000984 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int plic_claim(void) {
    80000984:	1141                	addi	sp,sp,-16
    80000986:	e422                	sd	s0,8(sp)
    80000988:	0800                	addi	s0,sp,16
    int hart = CPUID;
    //int irq = *(uint32*)(PLIC + 0x201004);
    int irq = *(uint32*)PLIC_MCLAIM(hart);
    return irq;
}
    8000098a:	0c2007b7          	lui	a5,0xc200
    8000098e:	43c8                	lw	a0,4(a5)
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret

0000000080000996 <plic_complete>:

// tell the PLIC we've served this IRQ.
void plic_complete(int irq) {
    80000996:	1141                	addi	sp,sp,-16
    80000998:	e422                	sd	s0,8(sp)
    8000099a:	0800                	addi	s0,sp,16
    int hart = CPUID;
    //*(uint32*)(PLIC + 0x201004) = irq;
    *(uint32*)PLIC_MCLAIM(hart) = irq;
    8000099c:	0c2007b7          	lui	a5,0xc200
    800009a0:	c3c8                	sw	a0,4(a5)
}
    800009a2:	6422                	ld	s0,8(sp)
    800009a4:	0141                	addi	sp,sp,16
    800009a6:	8082                	ret

00000000800009a8 <free_desc>:
    }
    return -1;
}

// mark a descriptor as free.
static void free_desc(int i) {
    800009a8:	1141                	addi	sp,sp,-16
    800009aa:	e406                	sd	ra,8(sp)
    800009ac:	e022                	sd	s0,0(sp)
    800009ae:	0800                	addi	s0,sp,16
    if(i >= NUM)
    800009b0:	479d                	li	a5,7
    800009b2:	04a7c463          	blt	a5,a0,800009fa <free_desc+0x52>
        panic("virtio_disk_intr 1");
    if(disk.free[i])
    800009b6:	00004797          	auipc	a5,0x4
    800009ba:	64a78793          	addi	a5,a5,1610 # 80005000 <disk>
    800009be:	00a78733          	add	a4,a5,a0
    800009c2:	6789                	lui	a5,0x2
    800009c4:	97ba                	add	a5,a5,a4
    800009c6:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800009ca:	e3a1                	bnez	a5,80000a0a <free_desc+0x62>
        panic("virtio_disk_intr 2");
    disk.desc[i].addr = 0;
    800009cc:	00451713          	slli	a4,a0,0x4
    800009d0:	00006797          	auipc	a5,0x6
    800009d4:	6307b783          	ld	a5,1584(a5) # 80007000 <disk+0x2000>
    800009d8:	97ba                	add	a5,a5,a4
    800009da:	0007b023          	sd	zero,0(a5)
    disk.free[i] = 1;
    800009de:	00004797          	auipc	a5,0x4
    800009e2:	62278793          	addi	a5,a5,1570 # 80005000 <disk>
    800009e6:	97aa                	add	a5,a5,a0
    800009e8:	6509                	lui	a0,0x2
    800009ea:	953e                	add	a0,a0,a5
    800009ec:	4785                	li	a5,1
    800009ee:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
}
    800009f2:	60a2                	ld	ra,8(sp)
    800009f4:	6402                	ld	s0,0(sp)
    800009f6:	0141                	addi	sp,sp,16
    800009f8:	8082                	ret
        panic("virtio_disk_intr 1");
    800009fa:	00001517          	auipc	a0,0x1
    800009fe:	6fe50513          	addi	a0,a0,1790 # 800020f8 <printTempRegState+0x11f2>
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	842080e7          	jalr	-1982(ra) # 80000244 <panic>
        panic("virtio_disk_intr 2");
    80000a0a:	00001517          	auipc	a0,0x1
    80000a0e:	70650513          	addi	a0,a0,1798 # 80002110 <printTempRegState+0x120a>
    80000a12:	00000097          	auipc	ra,0x0
    80000a16:	832080e7          	jalr	-1998(ra) # 80000244 <panic>

0000000080000a1a <virtio_disk_init>:
void virtio_disk_init(void) {
    80000a1a:	1101                	addi	sp,sp,-32
    80000a1c:	ec06                	sd	ra,24(sp)
    80000a1e:	e822                	sd	s0,16(sp)
    80000a20:	e426                	sd	s1,8(sp)
    80000a22:	1000                	addi	s0,sp,32
    if(*RVIRT(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80000a24:	100017b7          	lui	a5,0x10001
    80000a28:	4398                	lw	a4,0(a5)
    80000a2a:	2701                	sext.w	a4,a4
    80000a2c:	747277b7          	lui	a5,0x74727
    80000a30:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80000a34:	0ef71163          	bne	a4,a5,80000b16 <virtio_disk_init+0xfc>
        *RVIRT(VIRTIO_MMIO_VERSION) != 1 ||
    80000a38:	100017b7          	lui	a5,0x10001
    80000a3c:	43dc                	lw	a5,4(a5)
    80000a3e:	2781                	sext.w	a5,a5
    if(*RVIRT(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80000a40:	4705                	li	a4,1
    80000a42:	0ce79a63          	bne	a5,a4,80000b16 <virtio_disk_init+0xfc>
        *RVIRT(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80000a46:	100017b7          	lui	a5,0x10001
    80000a4a:	479c                	lw	a5,8(a5)
    80000a4c:	2781                	sext.w	a5,a5
        *RVIRT(VIRTIO_MMIO_VERSION) != 1 ||
    80000a4e:	4709                	li	a4,2
    80000a50:	0ce79363          	bne	a5,a4,80000b16 <virtio_disk_init+0xfc>
        *RVIRT(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80000a54:	100017b7          	lui	a5,0x10001
    80000a58:	47d8                	lw	a4,12(a5)
    80000a5a:	2701                	sext.w	a4,a4
        *RVIRT(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80000a5c:	554d47b7          	lui	a5,0x554d4
    80000a60:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80000a64:	0af71963          	bne	a4,a5,80000b16 <virtio_disk_init+0xfc>
    *RVIRT(VIRTIO_MMIO_STATUS) = status;
    80000a68:	100017b7          	lui	a5,0x10001
    80000a6c:	4705                	li	a4,1
    80000a6e:	dbb8                	sw	a4,112(a5)
    *RVIRT(VIRTIO_MMIO_STATUS) = status;
    80000a70:	470d                	li	a4,3
    80000a72:	dbb8                	sw	a4,112(a5)
    uint64 features = *RVIRT(VIRTIO_MMIO_DEVICE_FEATURES);
    80000a74:	4b94                	lw	a3,16(a5)
    features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80000a76:	c7ffe737          	lui	a4,0xc7ffe
    80000a7a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <current_process+0xffffffff47fec8e3>
    80000a7e:	8f75                	and	a4,a4,a3
    *RVIRT(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80000a80:	2701                	sext.w	a4,a4
    80000a82:	d398                	sw	a4,32(a5)
    *RVIRT(VIRTIO_MMIO_STATUS) = status;
    80000a84:	472d                	li	a4,11
    80000a86:	dbb8                	sw	a4,112(a5)
    *RVIRT(VIRTIO_MMIO_STATUS) = status;
    80000a88:	473d                	li	a4,15
    80000a8a:	dbb8                	sw	a4,112(a5)
    *RVIRT(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80000a8c:	6705                	lui	a4,0x1
    80000a8e:	d798                	sw	a4,40(a5)
    *RVIRT(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80000a90:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
    uint32 max = *RVIRT(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80000a94:	5bdc                	lw	a5,52(a5)
    80000a96:	2781                	sext.w	a5,a5
    if(max == 0)
    80000a98:	c7d9                	beqz	a5,80000b26 <virtio_disk_init+0x10c>
    if(max < NUM)
    80000a9a:	471d                	li	a4,7
    80000a9c:	08f77d63          	bgeu	a4,a5,80000b36 <virtio_disk_init+0x11c>
    *RVIRT(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80000aa0:	100014b7          	lui	s1,0x10001
    80000aa4:	47a1                	li	a5,8
    80000aa6:	dc9c                	sw	a5,56(s1)
    memset(disk.pages, 0, sizeof(disk.pages));
    80000aa8:	6609                	lui	a2,0x2
    80000aaa:	4581                	li	a1,0
    80000aac:	00004517          	auipc	a0,0x4
    80000ab0:	55450513          	addi	a0,a0,1364 # 80005000 <disk>
    80000ab4:	00000097          	auipc	ra,0x0
    80000ab8:	a5c080e7          	jalr	-1444(ra) # 80000510 <memset>
    *RVIRT(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80000abc:	00004717          	auipc	a4,0x4
    80000ac0:	54470713          	addi	a4,a4,1348 # 80005000 <disk>
    80000ac4:	00c75793          	srli	a5,a4,0xc
    80000ac8:	2781                	sext.w	a5,a5
    80000aca:	c0bc                	sw	a5,64(s1)
    disk.desc = (struct VRingDesc *) disk.pages;
    80000acc:	00006797          	auipc	a5,0x6
    80000ad0:	53478793          	addi	a5,a5,1332 # 80007000 <disk+0x2000>
    80000ad4:	e398                	sd	a4,0(a5)
    disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80000ad6:	00004717          	auipc	a4,0x4
    80000ada:	5aa70713          	addi	a4,a4,1450 # 80005080 <disk+0x80>
    80000ade:	e798                	sd	a4,8(a5)
    disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80000ae0:	00005717          	auipc	a4,0x5
    80000ae4:	52070713          	addi	a4,a4,1312 # 80006000 <disk+0x1000>
    80000ae8:	eb98                	sd	a4,16(a5)
        disk.free[i] = 1;
    80000aea:	4705                	li	a4,1
    80000aec:	00e78c23          	sb	a4,24(a5)
    80000af0:	00e78ca3          	sb	a4,25(a5)
    80000af4:	00e78d23          	sb	a4,26(a5)
    80000af8:	00e78da3          	sb	a4,27(a5)
    80000afc:	00e78e23          	sb	a4,28(a5)
    80000b00:	00e78ea3          	sb	a4,29(a5)
    80000b04:	00e78f23          	sb	a4,30(a5)
    80000b08:	00e78fa3          	sb	a4,31(a5)
}
    80000b0c:	60e2                	ld	ra,24(sp)
    80000b0e:	6442                	ld	s0,16(sp)
    80000b10:	64a2                	ld	s1,8(sp)
    80000b12:	6105                	addi	sp,sp,32
    80000b14:	8082                	ret
        panic("could not find virtio disk");
    80000b16:	00001517          	auipc	a0,0x1
    80000b1a:	61250513          	addi	a0,a0,1554 # 80002128 <printTempRegState+0x1222>
    80000b1e:	fffff097          	auipc	ra,0xfffff
    80000b22:	726080e7          	jalr	1830(ra) # 80000244 <panic>
        panic("virtio disk has no queue 0");
    80000b26:	00001517          	auipc	a0,0x1
    80000b2a:	62250513          	addi	a0,a0,1570 # 80002148 <printTempRegState+0x1242>
    80000b2e:	fffff097          	auipc	ra,0xfffff
    80000b32:	716080e7          	jalr	1814(ra) # 80000244 <panic>
        panic("virtio disk max queue too short");
    80000b36:	00001517          	auipc	a0,0x1
    80000b3a:	63250513          	addi	a0,a0,1586 # 80002168 <printTempRegState+0x1262>
    80000b3e:	fffff097          	auipc	ra,0xfffff
    80000b42:	706080e7          	jalr	1798(ra) # 80000244 <panic>

0000000080000b46 <virtio_disk_rw>:
        }
    }
    return 0;
}

void virtio_disk_rw(struct buf *b, int write) {
    80000b46:	7119                	addi	sp,sp,-128
    80000b48:	fc86                	sd	ra,120(sp)
    80000b4a:	f8a2                	sd	s0,112(sp)
    80000b4c:	f4a6                	sd	s1,104(sp)
    80000b4e:	f0ca                	sd	s2,96(sp)
    80000b50:	ecce                	sd	s3,88(sp)
    80000b52:	e8d2                	sd	s4,80(sp)
    80000b54:	e4d6                	sd	s5,72(sp)
    80000b56:	e0da                	sd	s6,64(sp)
    80000b58:	fc5e                	sd	s7,56(sp)
    80000b5a:	f862                	sd	s8,48(sp)
    80000b5c:	f466                	sd	s9,40(sp)
    80000b5e:	f06a                	sd	s10,32(sp)
    80000b60:	0100                	addi	s0,sp,128
    80000b62:	8c2a                	mv	s8,a0
    80000b64:	8d2e                	mv	s10,a1
    uint64 sector = b->blockno * (BSIZE / 512);
    80000b66:	00c52c83          	lw	s9,12(a0)
    80000b6a:	001c9c9b          	slliw	s9,s9,0x1
    80000b6e:	1c82                	slli	s9,s9,0x20
    80000b70:	020cdc93          	srli	s9,s9,0x20
    for(int i = 0; i < 3; i++){
    80000b74:	4901                	li	s2,0
    for(int i = 0; i < NUM; i++){
    80000b76:	4ba1                	li	s7,8
            disk.free[i] = 0;
    80000b78:	00004b17          	auipc	s6,0x4
    80000b7c:	488b0b13          	addi	s6,s6,1160 # 80005000 <disk>
    80000b80:	6a89                	lui	s5,0x2
    for(int i = 0; i < 3; i++){
    80000b82:	4a0d                	li	s4,3
    for(int i = 0; i < NUM; i++){
    80000b84:	89ca                	mv	s3,s2
    for(int i = 0; i < 3; i++){
    80000b86:	f9040713          	addi	a4,s0,-112
    80000b8a:	84ca                	mv	s1,s2
    80000b8c:	a829                	j	80000ba6 <virtio_disk_rw+0x60>
            disk.free[i] = 0;
    80000b8e:	00fb06b3          	add	a3,s6,a5
    80000b92:	96d6                	add	a3,a3,s5
    80000b94:	00068c23          	sb	zero,24(a3)
        idx[i] = alloc_desc();
    80000b98:	c21c                	sw	a5,0(a2)
        if(idx[i] < 0){
    80000b9a:	0207c563          	bltz	a5,80000bc4 <virtio_disk_rw+0x7e>
    for(int i = 0; i < 3; i++){
    80000b9e:	2485                	addiw	s1,s1,1
    80000ba0:	0711                	addi	a4,a4,4
    80000ba2:	15448b63          	beq	s1,s4,80000cf8 <virtio_disk_rw+0x1b2>
        idx[i] = alloc_desc();
    80000ba6:	863a                	mv	a2,a4
    for(int i = 0; i < NUM; i++){
    80000ba8:	00006697          	auipc	a3,0x6
    80000bac:	47068693          	addi	a3,a3,1136 # 80007018 <disk+0x2018>
    80000bb0:	87ce                	mv	a5,s3
        if(disk.free[i]){
    80000bb2:	0006c583          	lbu	a1,0(a3)
    80000bb6:	fde1                	bnez	a1,80000b8e <virtio_disk_rw+0x48>
    for(int i = 0; i < NUM; i++){
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	0685                	addi	a3,a3,1
    80000bbc:	ff779be3          	bne	a5,s7,80000bb2 <virtio_disk_rw+0x6c>
        idx[i] = alloc_desc();
    80000bc0:	57fd                	li	a5,-1
    80000bc2:	c21c                	sw	a5,0(a2)
            for(int j = 0; j < i; j++)
    80000bc4:	fc9051e3          	blez	s1,80000b86 <virtio_disk_rw+0x40>
                free_desc(idx[j]);
    80000bc8:	f9042503          	lw	a0,-112(s0)
    80000bcc:	00000097          	auipc	ra,0x0
    80000bd0:	ddc080e7          	jalr	-548(ra) # 800009a8 <free_desc>
            for(int j = 0; j < i; j++)
    80000bd4:	4785                	li	a5,1
    80000bd6:	fa97d8e3          	bge	a5,s1,80000b86 <virtio_disk_rw+0x40>
                free_desc(idx[j]);
    80000bda:	f9442503          	lw	a0,-108(s0)
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	dca080e7          	jalr	-566(ra) # 800009a8 <free_desc>
            for(int j = 0; j < i; j++)
    80000be6:	4789                	li	a5,2
    80000be8:	f897dfe3          	bge	a5,s1,80000b86 <virtio_disk_rw+0x40>
                free_desc(idx[j]);
    80000bec:	f9842503          	lw	a0,-104(s0)
    80000bf0:	00000097          	auipc	ra,0x0
    80000bf4:	db8080e7          	jalr	-584(ra) # 800009a8 <free_desc>
            for(int j = 0; j < i; j++)
    80000bf8:	b779                	j	80000b86 <virtio_disk_rw+0x40>
    disk.desc[idx[0]].next = idx[1];

    disk.desc[idx[1]].addr = (uint64) b->data;
    disk.desc[idx[1]].len = BSIZE;
    if(write)
        disk.desc[idx[1]].flags = 0; // device reads b->data
    80000bfa:	00006717          	auipc	a4,0x6
    80000bfe:	40673703          	ld	a4,1030(a4) # 80007000 <disk+0x2000>
    80000c02:	973e                	add	a4,a4,a5
    80000c04:	00071623          	sh	zero,12(a4)
    else
        disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80000c08:	00004517          	auipc	a0,0x4
    80000c0c:	3f850513          	addi	a0,a0,1016 # 80005000 <disk>
    80000c10:	00006717          	auipc	a4,0x6
    80000c14:	3f070713          	addi	a4,a4,1008 # 80007000 <disk+0x2000>
    80000c18:	6314                	ld	a3,0(a4)
    80000c1a:	96be                	add	a3,a3,a5
    80000c1c:	00c6d603          	lhu	a2,12(a3)
    80000c20:	00166613          	ori	a2,a2,1
    80000c24:	00c69623          	sh	a2,12(a3)
    disk.desc[idx[1]].next = idx[2];
    80000c28:	f9842683          	lw	a3,-104(s0)
    80000c2c:	6310                	ld	a2,0(a4)
    80000c2e:	97b2                	add	a5,a5,a2
    80000c30:	00d79723          	sh	a3,14(a5)

    disk.info[idx[0]].status = 0;
    80000c34:	20080613          	addi	a2,a6,512
    80000c38:	0612                	slli	a2,a2,0x4
    80000c3a:	962a                	add	a2,a2,a0
    80000c3c:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
    disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80000c40:	00469793          	slli	a5,a3,0x4
    80000c44:	00073883          	ld	a7,0(a4)
    80000c48:	98be                	add	a7,a7,a5
    80000c4a:	6689                	lui	a3,0x2
    80000c4c:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80000c50:	96ae                	add	a3,a3,a1
    80000c52:	96aa                	add	a3,a3,a0
    80000c54:	00d8b023          	sd	a3,0(a7)
    disk.desc[idx[2]].len = 1;
    80000c58:	6314                	ld	a3,0(a4)
    80000c5a:	96be                	add	a3,a3,a5
    80000c5c:	4585                	li	a1,1
    80000c5e:	c68c                	sw	a1,8(a3)
    disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80000c60:	6314                	ld	a3,0(a4)
    80000c62:	96be                	add	a3,a3,a5
    80000c64:	4889                	li	a7,2
    80000c66:	01169623          	sh	a7,12(a3)
    disk.desc[idx[2]].next = 0;
    80000c6a:	6314                	ld	a3,0(a4)
    80000c6c:	97b6                	add	a5,a5,a3
    80000c6e:	00079723          	sh	zero,14(a5)

    // record struct buf for virtio_disk_intr().
    b->disk = 1;
    80000c72:	00bc2223          	sw	a1,4(s8)
    disk.info[idx[0]].b = b;
    80000c76:	03863423          	sd	s8,40(a2)

    // avail[0] is flags
    // avail[1] tells the device how far to look in avail[2...].
    // avail[2...] are desc[] indices the device should process.
    // we only tell device the first index in our chain of descriptors.
    disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    80000c7a:	6714                	ld	a3,8(a4)
    80000c7c:	0026d783          	lhu	a5,2(a3)
    80000c80:	8b9d                	andi	a5,a5,7
    80000c82:	2789                	addiw	a5,a5,2
    80000c84:	0786                	slli	a5,a5,0x1
    80000c86:	97b6                	add	a5,a5,a3
    80000c88:	01079023          	sh	a6,0(a5)
    // __sync_synchronize();
    disk.avail[1] = disk.avail[1] + 1;
    80000c8c:	6718                	ld	a4,8(a4)
    80000c8e:	00275783          	lhu	a5,2(a4)
    80000c92:	2785                	addiw	a5,a5,1
    80000c94:	00f71123          	sh	a5,2(a4)

    *RVIRT(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80000c98:	100017b7          	lui	a5,0x10001
    80000c9c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>
    asm volatile("csrr %0, mie" : "=r" (x) );
    80000ca0:	304027f3          	csrr	a5,mie
    w_mie(r_mie() | MIE_MEIE);
    80000ca4:	6705                	lui	a4,0x1
    80000ca6:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000caa:	8fd9                	or	a5,a5,a4
    asm volatile("csrw mie, %0" : : "r" (x));
    80000cac:	30479073          	csrw	mie,a5
    asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000cb0:	300027f3          	csrr	a5,mstatus
    w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000cb4:	0087e793          	ori	a5,a5,8
    asm volatile("csrw mstatus, %0" : : "r" (x));
    80000cb8:	30079073          	csrw	mstatus,a5

    // Wait for virtio_disk_intr() to say request has finished.

    intr_dev_on();
    asm("wfi");
    80000cbc:	10500073          	wfi

    disk.info[idx[0]].b = 0;
    80000cc0:	f9042483          	lw	s1,-112(s0)
    80000cc4:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    80000cc8:	0792                	slli	a5,a5,0x4
    80000cca:	953e                	add	a0,a0,a5
    80000ccc:	02053423          	sd	zero,40(a0)
        if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80000cd0:	00006917          	auipc	s2,0x6
    80000cd4:	33090913          	addi	s2,s2,816 # 80007000 <disk+0x2000>
        free_desc(i);
    80000cd8:	8526                	mv	a0,s1
    80000cda:	00000097          	auipc	ra,0x0
    80000cde:	cce080e7          	jalr	-818(ra) # 800009a8 <free_desc>
        if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80000ce2:	0492                	slli	s1,s1,0x4
    80000ce4:	00093783          	ld	a5,0(s2)
    80000ce8:	94be                	add	s1,s1,a5
    80000cea:	00c4d783          	lhu	a5,12(s1)
    80000cee:	8b85                	andi	a5,a5,1
    80000cf0:	cfb5                	beqz	a5,80000d6c <virtio_disk_rw+0x226>
            i = disk.desc[i].next;
    80000cf2:	00e4d483          	lhu	s1,14(s1)
        free_desc(i);
    80000cf6:	b7cd                	j	80000cd8 <virtio_disk_rw+0x192>
    if(write)
    80000cf8:	01a037b3          	snez	a5,s10
    80000cfc:	f8f42023          	sw	a5,-128(s0)
    buf0.reserved = 0;
    80000d00:	f8042223          	sw	zero,-124(s0)
    buf0.sector = sector;
    80000d04:	f9943423          	sd	s9,-120(s0)
    disk.desc[idx[0]].addr = (uint64) &buf0;
    80000d08:	f9042803          	lw	a6,-112(s0)
    80000d0c:	00481593          	slli	a1,a6,0x4
    80000d10:	00006717          	auipc	a4,0x6
    80000d14:	2f070713          	addi	a4,a4,752 # 80007000 <disk+0x2000>
    80000d18:	631c                	ld	a5,0(a4)
    80000d1a:	97ae                	add	a5,a5,a1
    80000d1c:	f8040693          	addi	a3,s0,-128
    80000d20:	e394                	sd	a3,0(a5)
    disk.desc[idx[0]].len = sizeof(buf0);
    80000d22:	631c                	ld	a5,0(a4)
    80000d24:	97ae                	add	a5,a5,a1
    80000d26:	46c1                	li	a3,16
    80000d28:	c794                	sw	a3,8(a5)
    disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80000d2a:	631c                	ld	a5,0(a4)
    80000d2c:	97ae                	add	a5,a5,a1
    80000d2e:	4685                	li	a3,1
    80000d30:	00d79623          	sh	a3,12(a5)
    disk.desc[idx[0]].next = idx[1];
    80000d34:	f9442783          	lw	a5,-108(s0)
    80000d38:	6314                	ld	a3,0(a4)
    80000d3a:	96ae                	add	a3,a3,a1
    80000d3c:	00f69723          	sh	a5,14(a3)
    disk.desc[idx[1]].addr = (uint64) b->data;
    80000d40:	0792                	slli	a5,a5,0x4
    80000d42:	6314                	ld	a3,0(a4)
    80000d44:	96be                	add	a3,a3,a5
    80000d46:	030c0613          	addi	a2,s8,48
    80000d4a:	e290                	sd	a2,0(a3)
    disk.desc[idx[1]].len = BSIZE;
    80000d4c:	6318                	ld	a4,0(a4)
    80000d4e:	973e                	add	a4,a4,a5
    80000d50:	40000693          	li	a3,1024
    80000d54:	c714                	sw	a3,8(a4)
    if(write)
    80000d56:	ea0d12e3          	bnez	s10,80000bfa <virtio_disk_rw+0xb4>
        disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80000d5a:	00006717          	auipc	a4,0x6
    80000d5e:	2a673703          	ld	a4,678(a4) # 80007000 <disk+0x2000>
    80000d62:	973e                	add	a4,a4,a5
    80000d64:	4689                	li	a3,2
    80000d66:	00d71623          	sh	a3,12(a4)
    80000d6a:	bd79                	j	80000c08 <virtio_disk_rw+0xc2>
    free_chain(idx[0]);
}
    80000d6c:	70e6                	ld	ra,120(sp)
    80000d6e:	7446                	ld	s0,112(sp)
    80000d70:	74a6                	ld	s1,104(sp)
    80000d72:	7906                	ld	s2,96(sp)
    80000d74:	69e6                	ld	s3,88(sp)
    80000d76:	6a46                	ld	s4,80(sp)
    80000d78:	6aa6                	ld	s5,72(sp)
    80000d7a:	6b06                	ld	s6,64(sp)
    80000d7c:	7be2                	ld	s7,56(sp)
    80000d7e:	7c42                	ld	s8,48(sp)
    80000d80:	7ca2                	ld	s9,40(sp)
    80000d82:	7d02                	ld	s10,32(sp)
    80000d84:	6109                	addi	sp,sp,128
    80000d86:	8082                	ret

0000000080000d88 <virtio_disk_intr>:

void
virtio_disk_intr() {
    while((disk.used_idx % NUM) != (disk.used->id % NUM)) {
    80000d88:	00006717          	auipc	a4,0x6
    80000d8c:	27870713          	addi	a4,a4,632 # 80007000 <disk+0x2000>
    80000d90:	02075783          	lhu	a5,32(a4)
    80000d94:	6b18                	ld	a4,16(a4)
    80000d96:	00275683          	lhu	a3,2(a4)
    80000d9a:	8ebd                	xor	a3,a3,a5
    80000d9c:	8a9d                	andi	a3,a3,7
    80000d9e:	c6b1                	beqz	a3,80000dea <virtio_disk_intr+0x62>
        int id = disk.used->elems[disk.used_idx].id;

        if(disk.info[id].status != 0)
    80000da0:	00004597          	auipc	a1,0x4
    80000da4:	26058593          	addi	a1,a1,608 # 80005000 <disk>
            panic("virtio_disk_intr status");
        
        disk.info[id].b->disk = 0;   // disk is done with buf

        disk.used_idx = (disk.used_idx + 1) % NUM;
    80000da8:	00006617          	auipc	a2,0x6
    80000dac:	25860613          	addi	a2,a2,600 # 80007000 <disk+0x2000>
        int id = disk.used->elems[disk.used_idx].id;
    80000db0:	078e                	slli	a5,a5,0x3
    80000db2:	97ba                	add	a5,a5,a4
    80000db4:	43dc                	lw	a5,4(a5)
        if(disk.info[id].status != 0)
    80000db6:	20078713          	addi	a4,a5,512
    80000dba:	0712                	slli	a4,a4,0x4
    80000dbc:	972e                	add	a4,a4,a1
    80000dbe:	03074703          	lbu	a4,48(a4)
    80000dc2:	e70d                	bnez	a4,80000dec <virtio_disk_intr+0x64>
        disk.info[id].b->disk = 0;   // disk is done with buf
    80000dc4:	20078793          	addi	a5,a5,512
    80000dc8:	0792                	slli	a5,a5,0x4
    80000dca:	97ae                	add	a5,a5,a1
    80000dcc:	779c                	ld	a5,40(a5)
    80000dce:	0007a223          	sw	zero,4(a5)
        disk.used_idx = (disk.used_idx + 1) % NUM;
    80000dd2:	02065783          	lhu	a5,32(a2)
    80000dd6:	2785                	addiw	a5,a5,1
    80000dd8:	8b9d                	andi	a5,a5,7
    80000dda:	02f61023          	sh	a5,32(a2)
    while((disk.used_idx % NUM) != (disk.used->id % NUM)) {
    80000dde:	6a18                	ld	a4,16(a2)
    80000de0:	00275683          	lhu	a3,2(a4)
    80000de4:	8a9d                	andi	a3,a3,7
    80000de6:	fcf695e3          	bne	a3,a5,80000db0 <virtio_disk_intr+0x28>
    80000dea:	8082                	ret
virtio_disk_intr() {
    80000dec:	1141                	addi	sp,sp,-16
    80000dee:	e406                	sd	ra,8(sp)
    80000df0:	e022                	sd	s0,0(sp)
    80000df2:	0800                	addi	s0,sp,16
            panic("virtio_disk_intr status");
    80000df4:	00001517          	auipc	a0,0x1
    80000df8:	39450513          	addi	a0,a0,916 # 80002188 <printTempRegState+0x1282>
    80000dfc:	fffff097          	auipc	ra,0xfffff
    80000e00:	448080e7          	jalr	1096(ra) # 80000244 <panic>

0000000080000e04 <log_data_init>:
#include "functions.h"

// int block_no, off; // current unused log block, offset this current block
// uint64 temp_reg_state[NREG];

void log_data_init() {
    80000e04:	1141                	addi	sp,sp,-16
    80000e06:	e422                	sd	s0,8(sp)
    80000e08:	0800                	addi	s0,sp,16
    block_no = LOGSTART;
    80000e0a:	38400793          	li	a5,900
    80000e0e:	00011717          	auipc	a4,0x11
    80000e12:	06f72323          	sw	a5,102(a4) # 80011e74 <block_no>
    off = 0;
    80000e16:	00011797          	auipc	a5,0x11
    80000e1a:	0407ad23          	sw	zero,90(a5) # 80011e70 <off>
}
    80000e1e:	6422                	ld	s0,8(sp)
    80000e20:	0141                	addi	sp,sp,16
    80000e22:	8082                	ret

0000000080000e24 <log_data>:

void log_data(char *prt_str) {
    80000e24:	7139                	addi	sp,sp,-64
    80000e26:	fc06                	sd	ra,56(sp)
    80000e28:	f822                	sd	s0,48(sp)
    80000e2a:	f426                	sd	s1,40(sp)
    80000e2c:	f04a                	sd	s2,32(sp)
    80000e2e:	ec4e                	sd	s3,24(sp)
    80000e30:	e852                	sd	s4,16(sp)
    80000e32:	e456                	sd	s5,8(sp)
    80000e34:	e05a                	sd	s6,0(sp)
    80000e36:	0080                	addi	s0,sp,64
    80000e38:	84aa                	mv	s1,a0
    struct buf *buff = bread(-1, block_no);
    80000e3a:	00011597          	auipc	a1,0x11
    80000e3e:	03a5a583          	lw	a1,58(a1) # 80011e74 <block_no>
    80000e42:	557d                	li	a0,-1
    80000e44:	00000097          	auipc	ra,0x0
    80000e48:	8b2080e7          	jalr	-1870(ra) # 800006f6 <bread>
    80000e4c:	89aa                	mv	s3,a0

    while((*prt_str) != '\0') {
    80000e4e:	0004c783          	lbu	a5,0(s1)
    80000e52:	c7d1                	beqz	a5,80000ede <log_data+0xba>
        if(off == BSIZE) {
    80000e54:	00011917          	auipc	s2,0x11
    80000e58:	01c90913          	addi	s2,s2,28 # 80011e70 <off>
    80000e5c:	40000a13          	li	s4,1024
            bwrite(buff);
            brelse(buff);
            block_no ++;
    80000e60:	00011a97          	auipc	s5,0x11
    80000e64:	014a8a93          	addi	s5,s5,20 # 80011e74 <block_no>
            off = 0;
            if(block_no == FSSIZE)
    80000e68:	3e800b13          	li	s6,1000
    80000e6c:	a805                	j	80000e9c <log_data+0x78>
                panic("log_data");
    80000e6e:	00001517          	auipc	a0,0x1
    80000e72:	33250513          	addi	a0,a0,818 # 800021a0 <printTempRegState+0x129a>
    80000e76:	fffff097          	auipc	ra,0xfffff
    80000e7a:	3ce080e7          	jalr	974(ra) # 80000244 <panic>

            buff = bread(-1, block_no);
        }
        buff->data[off] = *prt_str;
    80000e7e:	00092783          	lw	a5,0(s2)
    80000e82:	0004c683          	lbu	a3,0(s1)
    80000e86:	00f98733          	add	a4,s3,a5
    80000e8a:	02d70823          	sb	a3,48(a4)
        prt_str ++;
    80000e8e:	0485                	addi	s1,s1,1
        off ++;
    80000e90:	2785                	addiw	a5,a5,1
    80000e92:	00f92023          	sw	a5,0(s2)
    while((*prt_str) != '\0') {
    80000e96:	0004c783          	lbu	a5,0(s1)
    80000e9a:	c3b1                	beqz	a5,80000ede <log_data+0xba>
        if(off == BSIZE) {
    80000e9c:	00092783          	lw	a5,0(s2)
    80000ea0:	fd479fe3          	bne	a5,s4,80000e7e <log_data+0x5a>
            bwrite(buff);
    80000ea4:	854e                	mv	a0,s3
    80000ea6:	00000097          	auipc	ra,0x0
    80000eaa:	8e8080e7          	jalr	-1816(ra) # 8000078e <bwrite>
            brelse(buff);
    80000eae:	854e                	mv	a0,s3
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	8f8080e7          	jalr	-1800(ra) # 800007a8 <brelse>
            block_no ++;
    80000eb8:	000aa583          	lw	a1,0(s5)
    80000ebc:	2585                	addiw	a1,a1,1
    80000ebe:	0005879b          	sext.w	a5,a1
    80000ec2:	00baa023          	sw	a1,0(s5)
            off = 0;
    80000ec6:	00092023          	sw	zero,0(s2)
            if(block_no == FSSIZE)
    80000eca:	fb6782e3          	beq	a5,s6,80000e6e <log_data+0x4a>
            buff = bread(-1, block_no);
    80000ece:	2581                	sext.w	a1,a1
    80000ed0:	557d                	li	a0,-1
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	824080e7          	jalr	-2012(ra) # 800006f6 <bread>
    80000eda:	89aa                	mv	s3,a0
    80000edc:	b74d                	j	80000e7e <log_data+0x5a>
    }
    bwrite(buff);
    80000ede:	854e                	mv	a0,s3
    80000ee0:	00000097          	auipc	ra,0x0
    80000ee4:	8ae080e7          	jalr	-1874(ra) # 8000078e <bwrite>
    brelse(buff);
    80000ee8:	854e                	mv	a0,s3
    80000eea:	00000097          	auipc	ra,0x0
    80000eee:	8be080e7          	jalr	-1858(ra) # 800007a8 <brelse>
}
    80000ef2:	70e2                	ld	ra,56(sp)
    80000ef4:	7442                	ld	s0,48(sp)
    80000ef6:	74a2                	ld	s1,40(sp)
    80000ef8:	7902                	ld	s2,32(sp)
    80000efa:	69e2                	ld	s3,24(sp)
    80000efc:	6a42                	ld	s4,16(sp)
    80000efe:	6aa2                	ld	s5,8(sp)
    80000f00:	6b02                	ld	s6,0(sp)
    80000f02:	6121                	addi	sp,sp,64
    80000f04:	8082                	ret

0000000080000f06 <printTempRegState>:

// This is called by dump_reg_state function
void printTempRegState() {
    80000f06:	1101                	addi	sp,sp,-32
    80000f08:	ec06                	sd	ra,24(sp)
    80000f0a:	e822                	sd	s0,16(sp)
    80000f0c:	e426                	sd	s1,8(sp)
    80000f0e:	1000                	addi	s0,sp,32
    // Just print the registers here
    printf("The register content is: \n");
    80000f10:	00001517          	auipc	a0,0x1
    80000f14:	2a050513          	addi	a0,a0,672 # 800021b0 <printTempRegState+0x12aa>
    80000f18:	fffff097          	auipc	ra,0xfffff
    80000f1c:	36e080e7          	jalr	878(ra) # 80000286 <printf>
    printf("ra %l\n",temp_reg_state[0]);
    80000f20:	00003497          	auipc	s1,0x3
    80000f24:	0e048493          	addi	s1,s1,224 # 80004000 <temp_reg_state>
    80000f28:	608c                	ld	a1,0(s1)
    80000f2a:	00001517          	auipc	a0,0x1
    80000f2e:	2a650513          	addi	a0,a0,678 # 800021d0 <printTempRegState+0x12ca>
    80000f32:	fffff097          	auipc	ra,0xfffff
    80000f36:	354080e7          	jalr	852(ra) # 80000286 <printf>
    printf("sp %l\n",temp_reg_state[1]);
    80000f3a:	648c                	ld	a1,8(s1)
    80000f3c:	00001517          	auipc	a0,0x1
    80000f40:	29c50513          	addi	a0,a0,668 # 800021d8 <printTempRegState+0x12d2>
    80000f44:	fffff097          	auipc	ra,0xfffff
    80000f48:	342080e7          	jalr	834(ra) # 80000286 <printf>
    printf("gp = %l\n",temp_reg_state[2]);
    80000f4c:	688c                	ld	a1,16(s1)
    80000f4e:	00001517          	auipc	a0,0x1
    80000f52:	29250513          	addi	a0,a0,658 # 800021e0 <printTempRegState+0x12da>
    80000f56:	fffff097          	auipc	ra,0xfffff
    80000f5a:	330080e7          	jalr	816(ra) # 80000286 <printf>
    printf("tp = %l\n",temp_reg_state[3]);
    80000f5e:	6c8c                	ld	a1,24(s1)
    80000f60:	00001517          	auipc	a0,0x1
    80000f64:	29050513          	addi	a0,a0,656 # 800021f0 <printTempRegState+0x12ea>
    80000f68:	fffff097          	auipc	ra,0xfffff
    80000f6c:	31e080e7          	jalr	798(ra) # 80000286 <printf>
    printf("t0 = %l\n",temp_reg_state[4]);
    80000f70:	708c                	ld	a1,32(s1)
    80000f72:	00001517          	auipc	a0,0x1
    80000f76:	28e50513          	addi	a0,a0,654 # 80002200 <printTempRegState+0x12fa>
    80000f7a:	fffff097          	auipc	ra,0xfffff
    80000f7e:	30c080e7          	jalr	780(ra) # 80000286 <printf>
    printf("t1 = %l\n",temp_reg_state[5]);
    80000f82:	748c                	ld	a1,40(s1)
    80000f84:	00001517          	auipc	a0,0x1
    80000f88:	28c50513          	addi	a0,a0,652 # 80002210 <printTempRegState+0x130a>
    80000f8c:	fffff097          	auipc	ra,0xfffff
    80000f90:	2fa080e7          	jalr	762(ra) # 80000286 <printf>
    printf("t2 = %l\n",temp_reg_state[6]);
    80000f94:	788c                	ld	a1,48(s1)
    80000f96:	00001517          	auipc	a0,0x1
    80000f9a:	28a50513          	addi	a0,a0,650 # 80002220 <printTempRegState+0x131a>
    80000f9e:	fffff097          	auipc	ra,0xfffff
    80000fa2:	2e8080e7          	jalr	744(ra) # 80000286 <printf>
    printf("s0 = %l\n",temp_reg_state[7]);
    80000fa6:	7c8c                	ld	a1,56(s1)
    80000fa8:	00001517          	auipc	a0,0x1
    80000fac:	28850513          	addi	a0,a0,648 # 80002230 <printTempRegState+0x132a>
    80000fb0:	fffff097          	auipc	ra,0xfffff
    80000fb4:	2d6080e7          	jalr	726(ra) # 80000286 <printf>
    printf("s1 = %l\n",temp_reg_state[8]);
    80000fb8:	60ac                	ld	a1,64(s1)
    80000fba:	00001517          	auipc	a0,0x1
    80000fbe:	28650513          	addi	a0,a0,646 # 80002240 <printTempRegState+0x133a>
    80000fc2:	fffff097          	auipc	ra,0xfffff
    80000fc6:	2c4080e7          	jalr	708(ra) # 80000286 <printf>
    printf("a0 = %l\n",temp_reg_state[9]);
    80000fca:	64ac                	ld	a1,72(s1)
    80000fcc:	00001517          	auipc	a0,0x1
    80000fd0:	28450513          	addi	a0,a0,644 # 80002250 <printTempRegState+0x134a>
    80000fd4:	fffff097          	auipc	ra,0xfffff
    80000fd8:	2b2080e7          	jalr	690(ra) # 80000286 <printf>
    printf("a1 = %l\n",temp_reg_state[10]);
    80000fdc:	68ac                	ld	a1,80(s1)
    80000fde:	00001517          	auipc	a0,0x1
    80000fe2:	28250513          	addi	a0,a0,642 # 80002260 <printTempRegState+0x135a>
    80000fe6:	fffff097          	auipc	ra,0xfffff
    80000fea:	2a0080e7          	jalr	672(ra) # 80000286 <printf>
    printf("a2 = %l\n",temp_reg_state[11]);
    80000fee:	6cac                	ld	a1,88(s1)
    80000ff0:	00001517          	auipc	a0,0x1
    80000ff4:	28050513          	addi	a0,a0,640 # 80002270 <printTempRegState+0x136a>
    80000ff8:	fffff097          	auipc	ra,0xfffff
    80000ffc:	28e080e7          	jalr	654(ra) # 80000286 <printf>
    printf("a3 = %l\n",temp_reg_state[12]);
    80001000:	70ac                	ld	a1,96(s1)
    80001002:	00001517          	auipc	a0,0x1
    80001006:	27e50513          	addi	a0,a0,638 # 80002280 <printTempRegState+0x137a>
    8000100a:	fffff097          	auipc	ra,0xfffff
    8000100e:	27c080e7          	jalr	636(ra) # 80000286 <printf>
    printf("a4 = %l\n",temp_reg_state[13]);
    80001012:	74ac                	ld	a1,104(s1)
    80001014:	00001517          	auipc	a0,0x1
    80001018:	27c50513          	addi	a0,a0,636 # 80002290 <printTempRegState+0x138a>
    8000101c:	fffff097          	auipc	ra,0xfffff
    80001020:	26a080e7          	jalr	618(ra) # 80000286 <printf>
    printf("a5 = %l\n",temp_reg_state[14]);
    80001024:	78ac                	ld	a1,112(s1)
    80001026:	00001517          	auipc	a0,0x1
    8000102a:	27a50513          	addi	a0,a0,634 # 800022a0 <printTempRegState+0x139a>
    8000102e:	fffff097          	auipc	ra,0xfffff
    80001032:	258080e7          	jalr	600(ra) # 80000286 <printf>
    printf("a6 = %l\n",temp_reg_state[15]);
    80001036:	7cac                	ld	a1,120(s1)
    80001038:	00001517          	auipc	a0,0x1
    8000103c:	27850513          	addi	a0,a0,632 # 800022b0 <printTempRegState+0x13aa>
    80001040:	fffff097          	auipc	ra,0xfffff
    80001044:	246080e7          	jalr	582(ra) # 80000286 <printf>
    printf("a7 = %l\n",temp_reg_state[16]);
    80001048:	60cc                	ld	a1,128(s1)
    8000104a:	00001517          	auipc	a0,0x1
    8000104e:	27650513          	addi	a0,a0,630 # 800022c0 <printTempRegState+0x13ba>
    80001052:	fffff097          	auipc	ra,0xfffff
    80001056:	234080e7          	jalr	564(ra) # 80000286 <printf>
    printf("s2 = %l\n",temp_reg_state[17]);
    8000105a:	64cc                	ld	a1,136(s1)
    8000105c:	00001517          	auipc	a0,0x1
    80001060:	27450513          	addi	a0,a0,628 # 800022d0 <printTempRegState+0x13ca>
    80001064:	fffff097          	auipc	ra,0xfffff
    80001068:	222080e7          	jalr	546(ra) # 80000286 <printf>
    printf("s3 = %l\n",temp_reg_state[18]);
    8000106c:	68cc                	ld	a1,144(s1)
    8000106e:	00001517          	auipc	a0,0x1
    80001072:	27250513          	addi	a0,a0,626 # 800022e0 <printTempRegState+0x13da>
    80001076:	fffff097          	auipc	ra,0xfffff
    8000107a:	210080e7          	jalr	528(ra) # 80000286 <printf>
    printf("s4 = %l\n",temp_reg_state[19]);
    8000107e:	6ccc                	ld	a1,152(s1)
    80001080:	00001517          	auipc	a0,0x1
    80001084:	27050513          	addi	a0,a0,624 # 800022f0 <printTempRegState+0x13ea>
    80001088:	fffff097          	auipc	ra,0xfffff
    8000108c:	1fe080e7          	jalr	510(ra) # 80000286 <printf>
    printf("s5 = %l\n",temp_reg_state[20]);
    80001090:	70cc                	ld	a1,160(s1)
    80001092:	00001517          	auipc	a0,0x1
    80001096:	26e50513          	addi	a0,a0,622 # 80002300 <printTempRegState+0x13fa>
    8000109a:	fffff097          	auipc	ra,0xfffff
    8000109e:	1ec080e7          	jalr	492(ra) # 80000286 <printf>
    printf("s6 = %l\n",temp_reg_state[21]);
    800010a2:	74cc                	ld	a1,168(s1)
    800010a4:	00001517          	auipc	a0,0x1
    800010a8:	26c50513          	addi	a0,a0,620 # 80002310 <printTempRegState+0x140a>
    800010ac:	fffff097          	auipc	ra,0xfffff
    800010b0:	1da080e7          	jalr	474(ra) # 80000286 <printf>
    printf("s7 = %l\n",temp_reg_state[22]);
    800010b4:	78cc                	ld	a1,176(s1)
    800010b6:	00001517          	auipc	a0,0x1
    800010ba:	26a50513          	addi	a0,a0,618 # 80002320 <printTempRegState+0x141a>
    800010be:	fffff097          	auipc	ra,0xfffff
    800010c2:	1c8080e7          	jalr	456(ra) # 80000286 <printf>
    printf("s8 = %l\n",temp_reg_state[23]);
    800010c6:	7ccc                	ld	a1,184(s1)
    800010c8:	00001517          	auipc	a0,0x1
    800010cc:	26850513          	addi	a0,a0,616 # 80002330 <printTempRegState+0x142a>
    800010d0:	fffff097          	auipc	ra,0xfffff
    800010d4:	1b6080e7          	jalr	438(ra) # 80000286 <printf>
    printf("s9 = %l\n",temp_reg_state[24]);
    800010d8:	60ec                	ld	a1,192(s1)
    800010da:	00001517          	auipc	a0,0x1
    800010de:	26650513          	addi	a0,a0,614 # 80002340 <printTempRegState+0x143a>
    800010e2:	fffff097          	auipc	ra,0xfffff
    800010e6:	1a4080e7          	jalr	420(ra) # 80000286 <printf>
    printf("s10 = %l\n",temp_reg_state[25]);
    800010ea:	64ec                	ld	a1,200(s1)
    800010ec:	00001517          	auipc	a0,0x1
    800010f0:	26450513          	addi	a0,a0,612 # 80002350 <printTempRegState+0x144a>
    800010f4:	fffff097          	auipc	ra,0xfffff
    800010f8:	192080e7          	jalr	402(ra) # 80000286 <printf>
    printf("s11 = %l\n",temp_reg_state[26]);
    800010fc:	68ec                	ld	a1,208(s1)
    800010fe:	00001517          	auipc	a0,0x1
    80001102:	26250513          	addi	a0,a0,610 # 80002360 <printTempRegState+0x145a>
    80001106:	fffff097          	auipc	ra,0xfffff
    8000110a:	180080e7          	jalr	384(ra) # 80000286 <printf>
    printf("s12 = %l\n",temp_reg_state[27]);
    8000110e:	6cec                	ld	a1,216(s1)
    80001110:	00001517          	auipc	a0,0x1
    80001114:	26050513          	addi	a0,a0,608 # 80002370 <printTempRegState+0x146a>
    80001118:	fffff097          	auipc	ra,0xfffff
    8000111c:	16e080e7          	jalr	366(ra) # 80000286 <printf>
    printf("t3 = %l\n",temp_reg_state[28]);
    80001120:	70ec                	ld	a1,224(s1)
    80001122:	00001517          	auipc	a0,0x1
    80001126:	25e50513          	addi	a0,a0,606 # 80002380 <printTempRegState+0x147a>
    8000112a:	fffff097          	auipc	ra,0xfffff
    8000112e:	15c080e7          	jalr	348(ra) # 80000286 <printf>
    printf("t4 = %l\n",temp_reg_state[29]);
    80001132:	74ec                	ld	a1,232(s1)
    80001134:	00001517          	auipc	a0,0x1
    80001138:	25c50513          	addi	a0,a0,604 # 80002390 <printTempRegState+0x148a>
    8000113c:	fffff097          	auipc	ra,0xfffff
    80001140:	14a080e7          	jalr	330(ra) # 80000286 <printf>
    printf("t5 = %l\n",temp_reg_state[30]);
    80001144:	78ec                	ld	a1,240(s1)
    80001146:	00001517          	auipc	a0,0x1
    8000114a:	25a50513          	addi	a0,a0,602 # 800023a0 <printTempRegState+0x149a>
    8000114e:	fffff097          	auipc	ra,0xfffff
    80001152:	138080e7          	jalr	312(ra) # 80000286 <printf>
    printf("t6 = %l\n",temp_reg_state[31]);
    80001156:	7cec                	ld	a1,248(s1)
    80001158:	00001517          	auipc	a0,0x1
    8000115c:	25850513          	addi	a0,a0,600 # 800023b0 <printTempRegState+0x14aa>
    80001160:	fffff097          	auipc	ra,0xfffff
    80001164:	126080e7          	jalr	294(ra) # 80000286 <printf>
    return;
}
    80001168:	60e2                	ld	ra,24(sp)
    8000116a:	6442                	ld	s0,16(sp)
    8000116c:	64a2                	ld	s1,8(sp)
    8000116e:	6105                	addi	sp,sp,32
    80001170:	8082                	ret
	...
