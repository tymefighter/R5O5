
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00011117          	auipc	sp,0x11
    80000004:	ec010113          	addi	sp,sp,-320 # 80010ec0 <SystemStack>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	4fa000ef          	jal	ra,80000510 <main>

000000008000001a <junk>:
    8000001a:	a001                	j	8000001a <junk>

000000008000001c <consputc>:
#include "declarations.h"
#include "functions.h"

// send one character to the uart.
void consputc(int c) {
    if(errorOccurred) {
    8000001c:	00012797          	auipc	a5,0x12
    80000020:	eac7a783          	lw	a5,-340(a5) # 80011ec8 <errorOccurred>
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

// the console input interrupt handler.
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
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
            cons.e--;
            consputc(BACKSPACE);
        }
        break;
    default:
        if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000008c:	c571                	beqz	a0,80000158 <consoleintr+0xee>
    8000008e:	00009717          	auipc	a4,0x9
    80000092:	bd270713          	addi	a4,a4,-1070 # 80008c60 <cons>
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
    800000ba:	baa78793          	addi	a5,a5,-1110 # 80008c60 <cons>
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
    800000e8:	bfc7a783          	lw	a5,-1028(a5) # 80008ce0 <cons+0x80>
    800000ec:	0807879b          	addiw	a5,a5,128
    800000f0:	06f69463          	bne	a3,a5,80000158 <consoleintr+0xee>
            cons.buf[cons.e++ % INPUT_BUF] = c;
    800000f4:	86be                	mv	a3,a5
    800000f6:	a855                	j	800001aa <consoleintr+0x140>
        while(cons.e != cons.w &&
    800000f8:	00009717          	auipc	a4,0x9
    800000fc:	b6870713          	addi	a4,a4,-1176 # 80008c60 <cons>
    80000100:	08872783          	lw	a5,136(a4)
    80000104:	08472703          	lw	a4,132(a4)
            cons.buf[(cons.e-1) % INPUT_BUF] != '\n') {
    80000108:	00009497          	auipc	s1,0x9
    8000010c:	b5848493          	addi	s1,s1,-1192 # 80008c60 <cons>
        while(cons.e != cons.w &&
    80000110:	4929                	li	s2,10
    80000112:	04f70363          	beq	a4,a5,80000158 <consoleintr+0xee>
            cons.buf[(cons.e-1) % INPUT_BUF] != '\n') {
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
    80000148:	b1c70713          	addi	a4,a4,-1252 # 80008c60 <cons>
    8000014c:	08872783          	lw	a5,136(a4)
    80000150:	08472703          	lw	a4,132(a4)
    80000154:	00f71863          	bne	a4,a5,80000164 <consoleintr+0xfa>
                cons.w = cons.e;
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
    8000016a:	b8f72123          	sw	a5,-1150(a4) # 80008ce8 <cons+0x88>
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
    8000018a:	ada78793          	addi	a5,a5,-1318 # 80008c60 <cons>
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
    800001ae:	b2d7ad23          	sw	a3,-1222(a5) # 80008ce4 <cons+0x84>
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

0000000080000244 <error>:
        }
    }

}

void error(char *s) {
    80000244:	1101                	addi	sp,sp,-32
    80000246:	ec06                	sd	ra,24(sp)
    80000248:	e822                	sd	s0,16(sp)
    8000024a:	e426                	sd	s1,8(sp)
    8000024c:	1000                	addi	s0,sp,32
    8000024e:	84aa                	mv	s1,a0
    printf("panic: ");
    80000250:	00002517          	auipc	a0,0x2
    80000254:	db050513          	addi	a0,a0,-592 # 80002000 <strlen+0xf70>
    80000258:	00000097          	auipc	ra,0x0
    8000025c:	02e080e7          	jalr	46(ra) # 80000286 <printf>
    printf(s);
    80000260:	8526                	mv	a0,s1
    80000262:	00000097          	auipc	ra,0x0
    80000266:	024080e7          	jalr	36(ra) # 80000286 <printf>
    printf("\n");
    8000026a:	00002517          	auipc	a0,0x2
    8000026e:	d9e50513          	addi	a0,a0,-610 # 80002008 <strlen+0xf78>
    80000272:	00000097          	auipc	ra,0x0
    80000276:	014080e7          	jalr	20(ra) # 80000286 <printf>
    errorOccurred = 1; // freeze other CPUs
    8000027a:	4785                	li	a5,1
    8000027c:	00012717          	auipc	a4,0x12
    80000280:	c4f72623          	sw	a5,-948(a4) # 80011ec8 <errorOccurred>
    for(;;)
    80000284:	a001                	j	80000284 <error+0x40>

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
        if(c != '%') {
    800002ca:	02500a13          	li	s4,37
        switch(c){
    800002ce:	4ad1                	li	s5,20
    800002d0:	00002917          	auipc	s2,0x2
    800002d4:	e7090913          	addi	s2,s2,-400 # 80002140 <strlen+0x10b0>
            for(; *s; s++)
    800002d8:	02800c93          	li	s9,40
    consputc('x');
    800002dc:	4c41                	li	s8,16
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800002de:	00003b17          	auipc	s6,0x3
    800002e2:	d22b0b13          	addi	s6,s6,-734 # 80003000 <digits>
    800002e6:	a025                	j	8000030e <printf+0x88>
        error("null fmt");
    800002e8:	00002517          	auipc	a0,0x2
    800002ec:	d3050513          	addi	a0,a0,-720 # 80002018 <strlen+0xf88>
    800002f0:	00000097          	auipc	ra,0x0
    800002f4:	f54080e7          	jalr	-172(ra) # 80000244 <error>
            consputc(c);
    800002f8:	00000097          	auipc	ra,0x0
    800002fc:	d24080e7          	jalr	-732(ra) # 8000001c <consputc>
    for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000300:	2485                	addiw	s1,s1,1
    80000302:	009987b3          	add	a5,s3,s1
    80000306:	0007c503          	lbu	a0,0(a5)
    8000030a:	12050b63          	beqz	a0,80000440 <printf+0x1ba>
        if(c != '%') {
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
    80000416:	bfeb8b93          	addi	s7,s7,-1026 # 80002010 <strlen+0xf80>
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
    if(ReadRegUART(LSR) & 0x01) {
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
    while(1) {
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
    while(1) {
    80000504:	b7f5                	j	800004f0 <uartintr+0xc>
    }
}
    80000506:	60e2                	ld	ra,24(sp)
    80000508:	6442                	ld	s0,16(sp)
    8000050a:	64a2                	ld	s1,8(sp)
    8000050c:	6105                	addi	sp,sp,32
    8000050e:	8082                	ret

0000000080000510 <main>:
#include "functions.h"

void main() {
    80000510:	1141                	addi	sp,sp,-16
    80000512:	e406                	sd	ra,8(sp)
    80000514:	e022                	sd	s0,0(sp)
    80000516:	0800                	addi	s0,sp,16

// supervisor address translation and protection;
// holds the address of the page table.
static inline 
void w_satp(uint64 x) {
    asm volatile("csrw satp, %0" : : "r" (x));
    80000518:	4781                	li	a5,0
    8000051a:	18079073          	csrw	satp,a5
    w_satp(0);          // Disable paging

    consoleinit();      // initialize console
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	c96080e7          	jalr	-874(ra) # 800001b4 <consoleinit>
    trapinithart();     // install kernel trap vector
    80000526:	00000097          	auipc	ra,0x0
    8000052a:	042080e7          	jalr	66(ra) # 80000568 <trapinithart>
    plicinit();         // set up interrupt controller
    8000052e:	00000097          	auipc	ra,0x0
    80000532:	3c0080e7          	jalr	960(ra) # 800008ee <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000536:	00000097          	auipc	ra,0x0
    8000053a:	3ce080e7          	jalr	974(ra) # 80000904 <plicinithart>
    binit();            // buffer cache
    8000053e:	00000097          	auipc	ra,0x0
    80000542:	0f4080e7          	jalr	244(ra) # 80000632 <binit>
    diskInit();         // emulated hard disk
    80000546:	00000097          	auipc	ra,0x0
    8000054a:	48e080e7          	jalr	1166(ra) # 800009d4 <diskInit>
    logDataInit();      // Initialize logging mechanism
    8000054e:	00001097          	auipc	ra,0x1
    80000552:	8b0080e7          	jalr	-1872(ra) # 80000dfe <logDataInit>

    printf("Done\n");
    80000556:	00002517          	auipc	a0,0x2
    8000055a:	ad250513          	addi	a0,a0,-1326 # 80002028 <strlen+0xf98>
    8000055e:	00000097          	auipc	ra,0x0
    80000562:	d28080e7          	jalr	-728(ra) # 80000286 <printf>
    while(1); 
    80000566:	a001                	j	80000566 <main+0x56>

0000000080000568 <trapinithart>:
#include "declarations.h"
#include "functions.h"

// set up to take exceptions and traps while in the kernel.
void trapinithart(void) {
    80000568:	1141                	addi	sp,sp,-16
    8000056a:	e422                	sd	s0,8(sp)
    8000056c:	0800                	addi	s0,sp,16
    asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000056e:	300027f3          	csrr	a5,mstatus
    w_mstatus(r_mstatus() | MSTATUS_MIE);
}

static inline 
void intr_all_off() {
    w_mstatus(r_mstatus() & ~(MSTATUS_MIE | MSTATUS_MPIE));
    80000572:	f777f793          	andi	a5,a5,-137
    asm volatile("csrw mstatus, %0" : : "r" (x));
    80000576:	30079073          	csrw	mstatus,a5
    asm volatile("csrr %0, mie" : "=r" (x) );
    8000057a:	304027f3          	csrr	a5,mie
    w_mie(r_mie() & (~(MIE_MEIE | MIE_MTIE | MIE_MSIE)));
    8000057e:	777d                	lui	a4,0xfffff
    80000580:	77770713          	addi	a4,a4,1911 # fffffffffffff777 <currentProcess+0xffffffff7ffed8ab>
    80000584:	8ff9                	and	a5,a5,a4
    asm volatile("csrw mie, %0" : : "r" (x));
    80000586:	30479073          	csrw	mie,a5
    asm volatile("csrw mtvec, %0" : : "r" (x));
    8000058a:	00000797          	auipc	a5,0x0
    8000058e:	24678793          	addi	a5,a5,582 # 800007d0 <kernelvec>
    80000592:	30579073          	csrw	mtvec,a5
    intr_all_off();
    w_mtvec((uint64)kernelvec); // must be 4-byte aligned to fit in stvec.
}
    80000596:	6422                	ld	s0,8(sp)
    80000598:	0141                	addi	sp,sp,16
    8000059a:	8082                	ret

000000008000059c <devintr>:

void devintr() {
    8000059c:	1101                	addi	sp,sp,-32
    8000059e:	ec06                	sd	ra,24(sp)
    800005a0:	e822                	sd	s0,16(sp)
    800005a2:	e426                	sd	s1,8(sp)
    800005a4:	1000                	addi	s0,sp,32
    // irq indicates which device interrupted.
    int irq = plic_claim();
    800005a6:	00000097          	auipc	ra,0x0
    800005aa:	38e080e7          	jalr	910(ra) # 80000934 <plic_claim>
    800005ae:	84aa                	mv	s1,a0

    if(irq == UART0_IRQ)
    800005b0:	47a9                	li	a5,10
    800005b2:	00f50f63          	beq	a0,a5,800005d0 <devintr+0x34>
        uartintr();
    else if(irq == VIRTIO0_IRQ)
    800005b6:	4785                	li	a5,1
    800005b8:	02f50163          	beq	a0,a5,800005da <devintr+0x3e>
        diskIntr();

    plic_complete(irq);
    800005bc:	8526                	mv	a0,s1
    800005be:	00000097          	auipc	ra,0x0
    800005c2:	388080e7          	jalr	904(ra) # 80000946 <plic_complete>
}
    800005c6:	60e2                	ld	ra,24(sp)
    800005c8:	6442                	ld	s0,16(sp)
    800005ca:	64a2                	ld	s1,8(sp)
    800005cc:	6105                	addi	sp,sp,32
    800005ce:	8082                	ret
        uartintr();
    800005d0:	00000097          	auipc	ra,0x0
    800005d4:	f14080e7          	jalr	-236(ra) # 800004e4 <uartintr>
    800005d8:	b7d5                	j	800005bc <devintr+0x20>
        diskIntr();
    800005da:	00000097          	auipc	ra,0x0
    800005de:	788080e7          	jalr	1928(ra) # 80000d62 <diskIntr>
    800005e2:	bfe9                	j	800005bc <devintr+0x20>

00000000800005e4 <kernelTrap>:

// interrupts and exceptions from kernel code go here via kernelvec,
// on whatever the current kernel stack is.
void kernelTrap() {
    800005e4:	1141                	addi	sp,sp,-16
    800005e6:	e406                	sd	ra,8(sp)
    800005e8:	e022                	sd	s0,0(sp)
    800005ea:	0800                	addi	s0,sp,16
    asm volatile("csrr %0, mcause" : "=r" (x) );
    800005ec:	342027f3          	csrr	a5,mcause
    uint64 mcause = r_mcause();
    if(mcause & (1ull << 63ull)) {
    800005f0:	0207d863          	bgez	a5,80000620 <kernelTrap+0x3c>
        if((mcause & ((1ull << 63ull) - 1)) != 11)
    800005f4:	0786                	slli	a5,a5,0x1
    800005f6:	8385                	srli	a5,a5,0x1
    800005f8:	472d                	li	a4,11
    800005fa:	00e79a63          	bne	a5,a4,8000060e <kernelTrap+0x2a>
            error("kernelTrap: Exception other than external");
        
        devintr();
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	f9e080e7          	jalr	-98(ra) # 8000059c <devintr>
    }
    else
        error("kernalTrap: Exception Occurred");
    80000606:	60a2                	ld	ra,8(sp)
    80000608:	6402                	ld	s0,0(sp)
    8000060a:	0141                	addi	sp,sp,16
    8000060c:	8082                	ret
            error("kernelTrap: Exception other than external");
    8000060e:	00002517          	auipc	a0,0x2
    80000612:	a2250513          	addi	a0,a0,-1502 # 80002030 <strlen+0xfa0>
    80000616:	00000097          	auipc	ra,0x0
    8000061a:	c2e080e7          	jalr	-978(ra) # 80000244 <error>
    8000061e:	b7c5                	j	800005fe <kernelTrap+0x1a>
        error("kernalTrap: Exception Occurred");
    80000620:	00002517          	auipc	a0,0x2
    80000624:	a4050513          	addi	a0,a0,-1472 # 80002060 <strlen+0xfd0>
    80000628:	00000097          	auipc	ra,0x0
    8000062c:	c1c080e7          	jalr	-996(ra) # 80000244 <error>
    80000630:	bfd9                	j	80000606 <kernelTrap+0x22>

0000000080000632 <binit>:
#include "declarations.h"
#include "functions.h"

void binit(void) {
    80000632:	1141                	addi	sp,sp,-16
    80000634:	e422                	sd	s0,8(sp)
    80000636:	0800                	addi	s0,sp,16
    Buffer *b;

    // Create linked list of buffers
    bcache.head.prev = &bcache.head;
    80000638:	00010797          	auipc	a5,0x10
    8000063c:	6b878793          	addi	a5,a5,1720 # 80010cf0 <bcache+0x8000>
    80000640:	00010717          	auipc	a4,0x10
    80000644:	45070713          	addi	a4,a4,1104 # 80010a90 <bcache+0x7da0>
    80000648:	dae7bc23          	sd	a4,-584(a5)
    bcache.head.next = &bcache.head;
    8000064c:	dce7b023          	sd	a4,-576(a5)
    for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80000650:	00008797          	auipc	a5,0x8
    80000654:	6a078793          	addi	a5,a5,1696 # 80008cf0 <bcache>
        b->next = bcache.head.next;
    80000658:	00010717          	auipc	a4,0x10
    8000065c:	69870713          	addi	a4,a4,1688 # 80010cf0 <bcache+0x8000>
        b->prev = &bcache.head;
    80000660:	00010697          	auipc	a3,0x10
    80000664:	43068693          	addi	a3,a3,1072 # 80010a90 <bcache+0x7da0>
        b->next = bcache.head.next;
    80000668:	dc073603          	ld	a2,-576(a4)
    8000066c:	f390                	sd	a2,32(a5)
        b->prev = &bcache.head;
    8000066e:	ef94                	sd	a3,24(a5)
        bcache.head.next->prev = b;
    80000670:	dc073603          	ld	a2,-576(a4)
    80000674:	ee1c                	sd	a5,24(a2)
        bcache.head.next = b;
    80000676:	dcf73023          	sd	a5,-576(a4)
    for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000067a:	43078793          	addi	a5,a5,1072
    8000067e:	fed795e3          	bne	a5,a3,80000668 <binit+0x36>
    }
}
    80000682:	6422                	ld	s0,8(sp)
    80000684:	0141                	addi	sp,sp,16
    80000686:	8082                	ret

0000000080000688 <bget>:

// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
Buffer* bget(uint dev, uint blockno) {
    80000688:	872a                	mv	a4,a0
    Buffer *b;

    // Is the block already cached?
    for(b = bcache.head.next; b != &bcache.head; b = b->next) {
    8000068a:	00010517          	auipc	a0,0x10
    8000068e:	42653503          	ld	a0,1062(a0) # 80010ab0 <bcache+0x7dc0>
    80000692:	00010797          	auipc	a5,0x10
    80000696:	3fe78793          	addi	a5,a5,1022 # 80010a90 <bcache+0x7da0>
    8000069a:	02f50163          	beq	a0,a5,800006bc <bget+0x34>
    8000069e:	86be                	mv	a3,a5
    800006a0:	a021                	j	800006a8 <bget+0x20>
    800006a2:	7108                	ld	a0,32(a0)
    800006a4:	00d50c63          	beq	a0,a3,800006bc <bget+0x34>
        if(b->dev == dev && b->blockno == blockno){
    800006a8:	451c                	lw	a5,8(a0)
    800006aa:	fee79ce3          	bne	a5,a4,800006a2 <bget+0x1a>
    800006ae:	455c                	lw	a5,12(a0)
    800006b0:	feb799e3          	bne	a5,a1,800006a2 <bget+0x1a>
            b->refcnt++;
    800006b4:	491c                	lw	a5,16(a0)
    800006b6:	2785                	addiw	a5,a5,1
    800006b8:	c91c                	sw	a5,16(a0)
            return b;
    800006ba:	8082                	ret
        }
    }

    // Not cached; recycle an unused buffer.
    for(b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    800006bc:	00010517          	auipc	a0,0x10
    800006c0:	3ec53503          	ld	a0,1004(a0) # 80010aa8 <bcache+0x7db8>
    800006c4:	00010797          	auipc	a5,0x10
    800006c8:	3cc78793          	addi	a5,a5,972 # 80010a90 <bcache+0x7da0>
    800006cc:	00f50863          	beq	a0,a5,800006dc <bget+0x54>
    800006d0:	86be                	mv	a3,a5
        if(b->refcnt == 0) {
    800006d2:	491c                	lw	a5,16(a0)
    800006d4:	c78d                	beqz	a5,800006fe <bget+0x76>
    for(b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    800006d6:	6d08                	ld	a0,24(a0)
    800006d8:	fed51de3          	bne	a0,a3,800006d2 <bget+0x4a>
Buffer* bget(uint dev, uint blockno) {
    800006dc:	1141                	addi	sp,sp,-16
    800006de:	e406                	sd	ra,8(sp)
    800006e0:	e022                	sd	s0,0(sp)
    800006e2:	0800                	addi	s0,sp,16
            b->refcnt = 1;
            return b;
        }
    }

    error("bget: no buffers");
    800006e4:	00002517          	auipc	a0,0x2
    800006e8:	99c50513          	addi	a0,a0,-1636 # 80002080 <strlen+0xff0>
    800006ec:	00000097          	auipc	ra,0x0
    800006f0:	b58080e7          	jalr	-1192(ra) # 80000244 <error>
    return 0;
    800006f4:	4501                	li	a0,0
}
    800006f6:	60a2                	ld	ra,8(sp)
    800006f8:	6402                	ld	s0,0(sp)
    800006fa:	0141                	addi	sp,sp,16
    800006fc:	8082                	ret
            b->dev = dev;
    800006fe:	c518                	sw	a4,8(a0)
            b->blockno = blockno;
    80000700:	c54c                	sw	a1,12(a0)
            b->valid = 0;
    80000702:	00052023          	sw	zero,0(a0)
            b->refcnt = 1;
    80000706:	4785                	li	a5,1
    80000708:	c91c                	sw	a5,16(a0)
}
    8000070a:	8082                	ret

000000008000070c <bread>:

// Return a locked buf with the contents of the indicated block.
Buffer* bread(uint dev, uint blockno) {
    8000070c:	1101                	addi	sp,sp,-32
    8000070e:	ec06                	sd	ra,24(sp)
    80000710:	e822                	sd	s0,16(sp)
    80000712:	e426                	sd	s1,8(sp)
    80000714:	1000                	addi	s0,sp,32
    Buffer *b;

    b = bget(dev, blockno);
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	f72080e7          	jalr	-142(ra) # 80000688 <bget>
    8000071e:	84aa                	mv	s1,a0
    if(!b->valid) {
    80000720:	411c                	lw	a5,0(a0)
    80000722:	c799                	beqz	a5,80000730 <bread+0x24>
        diskRW(b, 0);
        b->valid = 1;
    }
    return b;
}
    80000724:	8526                	mv	a0,s1
    80000726:	60e2                	ld	ra,24(sp)
    80000728:	6442                	ld	s0,16(sp)
    8000072a:	64a2                	ld	s1,8(sp)
    8000072c:	6105                	addi	sp,sp,32
    8000072e:	8082                	ret
        diskRW(b, 0);
    80000730:	4581                	li	a1,0
    80000732:	00000097          	auipc	ra,0x0
    80000736:	3d2080e7          	jalr	978(ra) # 80000b04 <diskRW>
        b->valid = 1;
    8000073a:	4785                	li	a5,1
    8000073c:	c09c                	sw	a5,0(s1)
    return b;
    8000073e:	b7dd                	j	80000724 <bread+0x18>

0000000080000740 <bwrite>:

// Write b's contents to disk.    Must be locked.
void bwrite(Buffer *b) {
    80000740:	1141                	addi	sp,sp,-16
    80000742:	e406                	sd	ra,8(sp)
    80000744:	e022                	sd	s0,0(sp)
    80000746:	0800                	addi	s0,sp,16
    diskRW(b, 1);
    80000748:	4585                	li	a1,1
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	3ba080e7          	jalr	954(ra) # 80000b04 <diskRW>
}
    80000752:	60a2                	ld	ra,8(sp)
    80000754:	6402                	ld	s0,0(sp)
    80000756:	0141                	addi	sp,sp,16
    80000758:	8082                	ret

000000008000075a <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void brelse(Buffer *b) {
    8000075a:	1141                	addi	sp,sp,-16
    8000075c:	e422                	sd	s0,8(sp)
    8000075e:	0800                	addi	s0,sp,16

    b->refcnt--;
    80000760:	491c                	lw	a5,16(a0)
    80000762:	37fd                	addiw	a5,a5,-1
    80000764:	0007871b          	sext.w	a4,a5
    80000768:	c91c                	sw	a5,16(a0)
    if (b->refcnt == 0) {
    8000076a:	eb05                	bnez	a4,8000079a <brelse+0x40>
        // no one is waiting for it.
        b->next->prev = b->prev;
    8000076c:	711c                	ld	a5,32(a0)
    8000076e:	6d18                	ld	a4,24(a0)
    80000770:	ef98                	sd	a4,24(a5)
        b->prev->next = b->next;
    80000772:	6d1c                	ld	a5,24(a0)
    80000774:	7118                	ld	a4,32(a0)
    80000776:	f398                	sd	a4,32(a5)
        b->next = bcache.head.next;
    80000778:	00010797          	auipc	a5,0x10
    8000077c:	57878793          	addi	a5,a5,1400 # 80010cf0 <bcache+0x8000>
    80000780:	dc07b703          	ld	a4,-576(a5)
    80000784:	f118                	sd	a4,32(a0)
        b->prev = &bcache.head;
    80000786:	00010717          	auipc	a4,0x10
    8000078a:	30a70713          	addi	a4,a4,778 # 80010a90 <bcache+0x7da0>
    8000078e:	ed18                	sd	a4,24(a0)
        bcache.head.next->prev = b;
    80000790:	dc07b703          	ld	a4,-576(a5)
    80000794:	ef08                	sd	a0,24(a4)
        bcache.head.next = b;
    80000796:	dca7b023          	sd	a0,-576(a5)
    }

}
    8000079a:	6422                	ld	s0,8(sp)
    8000079c:	0141                	addi	sp,sp,16
    8000079e:	8082                	ret

00000000800007a0 <bpin>:

void bpin(Buffer *b) {
    800007a0:	1141                	addi	sp,sp,-16
    800007a2:	e422                	sd	s0,8(sp)
    800007a4:	0800                	addi	s0,sp,16
    b->refcnt++;
    800007a6:	491c                	lw	a5,16(a0)
    800007a8:	2785                	addiw	a5,a5,1
    800007aa:	c91c                	sw	a5,16(a0)
}
    800007ac:	6422                	ld	s0,8(sp)
    800007ae:	0141                	addi	sp,sp,16
    800007b0:	8082                	ret

00000000800007b2 <bunpin>:

void bunpin(Buffer *b) {
    800007b2:	1141                	addi	sp,sp,-16
    800007b4:	e422                	sd	s0,8(sp)
    800007b6:	0800                	addi	s0,sp,16
    b->refcnt--;
    800007b8:	491c                	lw	a5,16(a0)
    800007ba:	37fd                	addiw	a5,a5,-1
    800007bc:	c91c                	sw	a5,16(a0)
    800007be:	6422                	ld	s0,8(sp)
    800007c0:	0141                	addi	sp,sp,16
    800007c2:	8082                	ret
	...

00000000800007d0 <kernelvec>:
    800007d0:	1161                	addi	sp,sp,-8
    800007d2:	e016                	sd	t0,0(sp)
    800007d4:	00008297          	auipc	t0,0x8
    800007d8:	36c28293          	addi	t0,t0,876 # 80008b40 <ksa>
    800007dc:	0012b023          	sd	ra,0(t0)
    800007e0:	0032b823          	sd	gp,16(t0)
    800007e4:	0042bc23          	sd	tp,24(t0)
    800007e8:	0262b423          	sd	t1,40(t0)
    800007ec:	0272b823          	sd	t2,48(t0)
    800007f0:	0282bc23          	sd	s0,56(t0)
    800007f4:	0492b023          	sd	s1,64(t0)
    800007f8:	04a2b423          	sd	a0,72(t0)
    800007fc:	04b2b823          	sd	a1,80(t0)
    80000800:	04c2bc23          	sd	a2,88(t0)
    80000804:	06d2b023          	sd	a3,96(t0)
    80000808:	06e2b423          	sd	a4,104(t0)
    8000080c:	06f2b823          	sd	a5,112(t0)
    80000810:	0702bc23          	sd	a6,120(t0)
    80000814:	0912b023          	sd	a7,128(t0)
    80000818:	0922b423          	sd	s2,136(t0)
    8000081c:	0932b823          	sd	s3,144(t0)
    80000820:	0942bc23          	sd	s4,152(t0)
    80000824:	0b52b023          	sd	s5,160(t0)
    80000828:	0b62b423          	sd	s6,168(t0)
    8000082c:	0b72b823          	sd	s7,176(t0)
    80000830:	0b82bc23          	sd	s8,184(t0)
    80000834:	0d92b023          	sd	s9,192(t0)
    80000838:	0da2b423          	sd	s10,200(t0)
    8000083c:	0db2b823          	sd	s11,208(t0)
    80000840:	0dc2bc23          	sd	t3,216(t0)
    80000844:	0fd2b023          	sd	t4,224(t0)
    80000848:	0fe2b423          	sd	t5,232(t0)
    8000084c:	0ff2b823          	sd	t6,240(t0)
    80000850:	6302                	ld	t1,0(sp)
    80000852:	0121                	addi	sp,sp,8
    80000854:	0022b423          	sd	sp,8(t0)
    80000858:	0262b023          	sd	t1,32(t0)
    8000085c:	d89ff0ef          	jal	ra,800005e4 <kernelTrap>
    80000860:	00008297          	auipc	t0,0x8
    80000864:	2e028293          	addi	t0,t0,736 # 80008b40 <ksa>
    80000868:	0002b083          	ld	ra,0(t0)
    8000086c:	0082b103          	ld	sp,8(t0)
    80000870:	0102b183          	ld	gp,16(t0)
    80000874:	0182b203          	ld	tp,24(t0)
    80000878:	0282b303          	ld	t1,40(t0)
    8000087c:	0302b383          	ld	t2,48(t0)
    80000880:	0382b403          	ld	s0,56(t0)
    80000884:	0402b483          	ld	s1,64(t0)
    80000888:	0482b503          	ld	a0,72(t0)
    8000088c:	0502b583          	ld	a1,80(t0)
    80000890:	0582b603          	ld	a2,88(t0)
    80000894:	0602b683          	ld	a3,96(t0)
    80000898:	0682b703          	ld	a4,104(t0)
    8000089c:	0702b783          	ld	a5,112(t0)
    800008a0:	0782b803          	ld	a6,120(t0)
    800008a4:	0802b883          	ld	a7,128(t0)
    800008a8:	0882b903          	ld	s2,136(t0)
    800008ac:	0902b983          	ld	s3,144(t0)
    800008b0:	0982ba03          	ld	s4,152(t0)
    800008b4:	0a02ba83          	ld	s5,160(t0)
    800008b8:	0a82bb03          	ld	s6,168(t0)
    800008bc:	0b02bb83          	ld	s7,176(t0)
    800008c0:	0b82bc03          	ld	s8,184(t0)
    800008c4:	0c02bc83          	ld	s9,192(t0)
    800008c8:	0c82bd03          	ld	s10,200(t0)
    800008cc:	0d02bd83          	ld	s11,208(t0)
    800008d0:	0d82be03          	ld	t3,216(t0)
    800008d4:	0e02be83          	ld	t4,224(t0)
    800008d8:	0e82bf03          	ld	t5,232(t0)
    800008dc:	0f02bf83          	ld	t6,240(t0)
    800008e0:	0202b283          	ld	t0,32(t0)
    800008e4:	30200073          	mret
    800008e8:	0000                	unimp
    800008ea:	0000                	unimp
	...

00000000800008ee <plicinit>:
#include "declarations.h"

// the riscv Platform Level Interrupt Controller (PLIC).

void plicinit(void) {
    800008ee:	1141                	addi	sp,sp,-16
    800008f0:	e422                	sd	s0,8(sp)
    800008f2:	0800                	addi	s0,sp,16
    // set desired IRQ priorities non-zero (otherwise disabled).
    *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800008f4:	0c0007b7          	lui	a5,0xc000
    800008f8:	4705                	li	a4,1
    800008fa:	d798                	sw	a4,40(a5)
    *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800008fc:	c3d8                	sw	a4,4(a5)
}
    800008fe:	6422                	ld	s0,8(sp)
    80000900:	0141                	addi	sp,sp,16
    80000902:	8082                	ret

0000000080000904 <plicinithart>:

void plicinithart(void) {
    80000904:	1141                	addi	sp,sp,-16
    80000906:	e422                	sd	s0,8(sp)
    80000908:	0800                	addi	s0,sp,16
    int hart = CPUID; // Only one cpu
    
    // set uart's enable bit for this hart's S-mode. 
    *(uint32*)PLIC_MENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    8000090a:	0c0027b7          	lui	a5,0xc002
    8000090e:	40200713          	li	a4,1026
    80000912:	c398                	sw	a4,0(a5)

    // set this hart's S-mode priority threshold to 0.
    *(uint32*)PLIC_MPRIORITY(hart) = 0;
    80000914:	0c2007b7          	lui	a5,0xc200
    80000918:	0007a023          	sw	zero,0(a5) # c200000 <_entry-0x73e00000>
}
    8000091c:	6422                	ld	s0,8(sp)
    8000091e:	0141                	addi	sp,sp,16
    80000920:	8082                	ret

0000000080000922 <plic_pending>:

// return a bitmap of which IRQs are waiting
// to be served.
uint64 plic_pending(void) {
    80000922:	1141                	addi	sp,sp,-16
    80000924:	e422                	sd	s0,8(sp)
    80000926:	0800                	addi	s0,sp,16
    //mask = *(uint32*)(PLIC + 0x1000);
    //mask |= (uint64)*(uint32*)(PLIC + 0x1004) << 32;
    mask = *(uint64*)PLIC_PENDING;

    return mask;
}
    80000928:	0c0017b7          	lui	a5,0xc001
    8000092c:	6388                	ld	a0,0(a5)
    8000092e:	6422                	ld	s0,8(sp)
    80000930:	0141                	addi	sp,sp,16
    80000932:	8082                	ret

0000000080000934 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int plic_claim(void) {
    80000934:	1141                	addi	sp,sp,-16
    80000936:	e422                	sd	s0,8(sp)
    80000938:	0800                	addi	s0,sp,16
    int hart = CPUID;
    //int irq = *(uint32*)(PLIC + 0x201004);
    int irq = *(uint32*)PLIC_MCLAIM(hart);
    return irq;
}
    8000093a:	0c2007b7          	lui	a5,0xc200
    8000093e:	43c8                	lw	a0,4(a5)
    80000940:	6422                	ld	s0,8(sp)
    80000942:	0141                	addi	sp,sp,16
    80000944:	8082                	ret

0000000080000946 <plic_complete>:

// tell the PLIC we've served this IRQ.
void plic_complete(int irq) {
    80000946:	1141                	addi	sp,sp,-16
    80000948:	e422                	sd	s0,8(sp)
    8000094a:	0800                	addi	s0,sp,16
    int hart = CPUID;
    //*(uint32*)(PLIC + 0x201004) = irq;
    *(uint32*)PLIC_MCLAIM(hart) = irq;
    8000094c:	0c2007b7          	lui	a5,0xc200
    80000950:	c3c8                	sw	a0,4(a5)
    80000952:	6422                	ld	s0,8(sp)
    80000954:	0141                	addi	sp,sp,16
    80000956:	8082                	ret

0000000080000958 <freeDesc>:
    }
    return -1;
}

// mark a descriptor as free.
static void freeDesc(int i) {
    80000958:	1101                	addi	sp,sp,-32
    8000095a:	ec06                	sd	ra,24(sp)
    8000095c:	e822                	sd	s0,16(sp)
    8000095e:	e426                	sd	s1,8(sp)
    80000960:	1000                	addi	s0,sp,32
    80000962:	84aa                	mv	s1,a0
  if(i >= NUM)
    80000964:	479d                	li	a5,7
    80000966:	04a7c563          	blt	a5,a0,800009b0 <freeDesc+0x58>
    error("diskIntr 1");

  if(disk.free[i])
    8000096a:	00004797          	auipc	a5,0x4
    8000096e:	69678793          	addi	a5,a5,1686 # 80005000 <disk>
    80000972:	00978733          	add	a4,a5,s1
    80000976:	6789                	lui	a5,0x2
    80000978:	97ba                	add	a5,a5,a4
    8000097a:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    8000097e:	e3b1                	bnez	a5,800009c2 <freeDesc+0x6a>
    error("diskIntr 2");

  disk.desc[i].addr = 0;
    80000980:	00449713          	slli	a4,s1,0x4
    80000984:	00006797          	auipc	a5,0x6
    80000988:	67c7b783          	ld	a5,1660(a5) # 80007000 <disk+0x2000>
    8000098c:	97ba                	add	a5,a5,a4
    8000098e:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80000992:	00004517          	auipc	a0,0x4
    80000996:	66e50513          	addi	a0,a0,1646 # 80005000 <disk>
    8000099a:	9526                	add	a0,a0,s1
    8000099c:	6489                	lui	s1,0x2
    8000099e:	94aa                	add	s1,s1,a0
    800009a0:	4785                	li	a5,1
    800009a2:	00f48c23          	sb	a5,24(s1) # 2018 <_entry-0x7fffdfe8>
}
    800009a6:	60e2                	ld	ra,24(sp)
    800009a8:	6442                	ld	s0,16(sp)
    800009aa:	64a2                	ld	s1,8(sp)
    800009ac:	6105                	addi	sp,sp,32
    800009ae:	8082                	ret
    error("diskIntr 1");
    800009b0:	00001517          	auipc	a0,0x1
    800009b4:	6e850513          	addi	a0,a0,1768 # 80002098 <strlen+0x1008>
    800009b8:	00000097          	auipc	ra,0x0
    800009bc:	88c080e7          	jalr	-1908(ra) # 80000244 <error>
    800009c0:	b76d                	j	8000096a <freeDesc+0x12>
    error("diskIntr 2");
    800009c2:	00001517          	auipc	a0,0x1
    800009c6:	6e650513          	addi	a0,a0,1766 # 800020a8 <strlen+0x1018>
    800009ca:	00000097          	auipc	ra,0x0
    800009ce:	87a080e7          	jalr	-1926(ra) # 80000244 <error>
    800009d2:	b77d                	j	80000980 <freeDesc+0x28>

00000000800009d4 <diskInit>:
void diskInit(void) {
    800009d4:	1101                	addi	sp,sp,-32
    800009d6:	ec06                	sd	ra,24(sp)
    800009d8:	e822                	sd	s0,16(sp)
    800009da:	e426                	sd	s1,8(sp)
    800009dc:	1000                	addi	s0,sp,32
    if(*RVIRT(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800009de:	100017b7          	lui	a5,0x10001
    800009e2:	4398                	lw	a4,0(a5)
    800009e4:	2701                	sext.w	a4,a4
    800009e6:	747277b7          	lui	a5,0x74727
    800009ea:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800009ee:	00f71963          	bne	a4,a5,80000a00 <diskInit+0x2c>
        *RVIRT(VIRTIO_MMIO_VERSION) != 1 ||
    800009f2:	100017b7          	lui	a5,0x10001
    800009f6:	43dc                	lw	a5,4(a5)
    800009f8:	2781                	sext.w	a5,a5
    if(*RVIRT(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800009fa:	4705                	li	a4,1
    800009fc:	0ce78163          	beq	a5,a4,80000abe <diskInit+0xea>
        error("could not find disk");
    80000a00:	00001517          	auipc	a0,0x1
    80000a04:	6b850513          	addi	a0,a0,1720 # 800020b8 <strlen+0x1028>
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	83c080e7          	jalr	-1988(ra) # 80000244 <error>
    *RVIRT(VIRTIO_MMIO_STATUS) = status;
    80000a10:	100017b7          	lui	a5,0x10001
    80000a14:	4705                	li	a4,1
    80000a16:	dbb8                	sw	a4,112(a5)
    *RVIRT(VIRTIO_MMIO_STATUS) = status;
    80000a18:	470d                	li	a4,3
    80000a1a:	dbb8                	sw	a4,112(a5)
    uint64 features = *RVIRT(VIRTIO_MMIO_DEVICE_FEATURES);
    80000a1c:	4b94                	lw	a3,16(a5)
    features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80000a1e:	c7ffe737          	lui	a4,0xc7ffe
    80000a22:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <currentProcess+0xffffffff47fec893>
    80000a26:	8f75                	and	a4,a4,a3
    *RVIRT(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80000a28:	2701                	sext.w	a4,a4
    80000a2a:	d398                	sw	a4,32(a5)
    *RVIRT(VIRTIO_MMIO_STATUS) = status;
    80000a2c:	472d                	li	a4,11
    80000a2e:	dbb8                	sw	a4,112(a5)
    *RVIRT(VIRTIO_MMIO_STATUS) = status;
    80000a30:	473d                	li	a4,15
    80000a32:	dbb8                	sw	a4,112(a5)
    *RVIRT(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80000a34:	6705                	lui	a4,0x1
    80000a36:	d798                	sw	a4,40(a5)
    *RVIRT(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80000a38:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
    uint32 max = *RVIRT(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80000a3c:	5bdc                	lw	a5,52(a5)
    80000a3e:	2781                	sext.w	a5,a5
    if(max == 0)
    80000a40:	c3cd                	beqz	a5,80000ae2 <diskInit+0x10e>
    if(max < NUM)
    80000a42:	471d                	li	a4,7
    80000a44:	0af77763          	bgeu	a4,a5,80000af2 <diskInit+0x11e>
    *RVIRT(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80000a48:	100014b7          	lui	s1,0x10001
    80000a4c:	47a1                	li	a5,8
    80000a4e:	dc9c                	sw	a5,56(s1)
    memset(disk.pages, 0, sizeof(disk.pages));
    80000a50:	6609                	lui	a2,0x2
    80000a52:	4581                	li	a1,0
    80000a54:	00004517          	auipc	a0,0x4
    80000a58:	5ac50513          	addi	a0,a0,1452 # 80005000 <disk>
    80000a5c:	00000097          	auipc	ra,0x0
    80000a60:	4ac080e7          	jalr	1196(ra) # 80000f08 <memset>
    *RVIRT(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80000a64:	00004717          	auipc	a4,0x4
    80000a68:	59c70713          	addi	a4,a4,1436 # 80005000 <disk>
    80000a6c:	00c75793          	srli	a5,a4,0xc
    80000a70:	2781                	sext.w	a5,a5
    80000a72:	c0bc                	sw	a5,64(s1)
    disk.desc = (struct VRingDesc *) disk.pages;
    80000a74:	00006797          	auipc	a5,0x6
    80000a78:	58c78793          	addi	a5,a5,1420 # 80007000 <disk+0x2000>
    80000a7c:	e398                	sd	a4,0(a5)
    disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80000a7e:	00004717          	auipc	a4,0x4
    80000a82:	60270713          	addi	a4,a4,1538 # 80005080 <disk+0x80>
    80000a86:	e798                	sd	a4,8(a5)
    disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80000a88:	00005717          	auipc	a4,0x5
    80000a8c:	57870713          	addi	a4,a4,1400 # 80006000 <disk+0x1000>
    80000a90:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80000a92:	4705                	li	a4,1
    80000a94:	00e78c23          	sb	a4,24(a5)
    80000a98:	00e78ca3          	sb	a4,25(a5)
    80000a9c:	00e78d23          	sb	a4,26(a5)
    80000aa0:	00e78da3          	sb	a4,27(a5)
    80000aa4:	00e78e23          	sb	a4,28(a5)
    80000aa8:	00e78ea3          	sb	a4,29(a5)
    80000aac:	00e78f23          	sb	a4,30(a5)
    80000ab0:	00e78fa3          	sb	a4,31(a5)
}
    80000ab4:	60e2                	ld	ra,24(sp)
    80000ab6:	6442                	ld	s0,16(sp)
    80000ab8:	64a2                	ld	s1,8(sp)
    80000aba:	6105                	addi	sp,sp,32
    80000abc:	8082                	ret
        *RVIRT(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80000abe:	100017b7          	lui	a5,0x10001
    80000ac2:	479c                	lw	a5,8(a5)
    80000ac4:	2781                	sext.w	a5,a5
        *RVIRT(VIRTIO_MMIO_VERSION) != 1 ||
    80000ac6:	4709                	li	a4,2
    80000ac8:	f2e79ce3          	bne	a5,a4,80000a00 <diskInit+0x2c>
        *RVIRT(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80000acc:	100017b7          	lui	a5,0x10001
    80000ad0:	47d8                	lw	a4,12(a5)
    80000ad2:	2701                	sext.w	a4,a4
        *RVIRT(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80000ad4:	554d47b7          	lui	a5,0x554d4
    80000ad8:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80000adc:	f2f712e3          	bne	a4,a5,80000a00 <diskInit+0x2c>
    80000ae0:	bf05                	j	80000a10 <diskInit+0x3c>
        error("virtio disk has no queue 0");
    80000ae2:	00001517          	auipc	a0,0x1
    80000ae6:	5ee50513          	addi	a0,a0,1518 # 800020d0 <strlen+0x1040>
    80000aea:	fffff097          	auipc	ra,0xfffff
    80000aee:	75a080e7          	jalr	1882(ra) # 80000244 <error>
        error("virtio disk max queue too short");
    80000af2:	00001517          	auipc	a0,0x1
    80000af6:	5fe50513          	addi	a0,a0,1534 # 800020f0 <strlen+0x1060>
    80000afa:	fffff097          	auipc	ra,0xfffff
    80000afe:	74a080e7          	jalr	1866(ra) # 80000244 <error>
    80000b02:	b799                	j	80000a48 <diskInit+0x74>

0000000080000b04 <diskRW>:
        }
    }
  return 0;
}

void diskRW(Buffer *b, int write) {
    80000b04:	7119                	addi	sp,sp,-128
    80000b06:	fc86                	sd	ra,120(sp)
    80000b08:	f8a2                	sd	s0,112(sp)
    80000b0a:	f4a6                	sd	s1,104(sp)
    80000b0c:	f0ca                	sd	s2,96(sp)
    80000b0e:	ecce                	sd	s3,88(sp)
    80000b10:	e8d2                	sd	s4,80(sp)
    80000b12:	e4d6                	sd	s5,72(sp)
    80000b14:	e0da                	sd	s6,64(sp)
    80000b16:	fc5e                	sd	s7,56(sp)
    80000b18:	f862                	sd	s8,48(sp)
    80000b1a:	f466                	sd	s9,40(sp)
    80000b1c:	f06a                	sd	s10,32(sp)
    80000b1e:	0100                	addi	s0,sp,128
    80000b20:	8c2a                	mv	s8,a0
    80000b22:	8d2e                	mv	s10,a1
    uint64 sector = b->blockno * (BSIZE / 512);
    80000b24:	00c52c83          	lw	s9,12(a0)
    80000b28:	001c9c9b          	slliw	s9,s9,0x1
    80000b2c:	1c82                	slli	s9,s9,0x20
    80000b2e:	020cdc93          	srli	s9,s9,0x20
    for(int i = 0; i < 3; i++) {
    80000b32:	4901                	li	s2,0
    for(int i = 0; i < NUM; i++){
    80000b34:	4ba1                	li	s7,8
            disk.free[i] = 0;
    80000b36:	00004b17          	auipc	s6,0x4
    80000b3a:	4cab0b13          	addi	s6,s6,1226 # 80005000 <disk>
    80000b3e:	6a89                	lui	s5,0x2
    for(int i = 0; i < 3; i++) {
    80000b40:	4a0d                	li	s4,3
    for(int i = 0; i < NUM; i++){
    80000b42:	89ca                	mv	s3,s2
    for(int i = 0; i < 3; i++) {
    80000b44:	f9040713          	addi	a4,s0,-112
    80000b48:	84ca                	mv	s1,s2
    80000b4a:	a829                	j	80000b64 <diskRW+0x60>
            disk.free[i] = 0;
    80000b4c:	00fb06b3          	add	a3,s6,a5
    80000b50:	96d6                	add	a3,a3,s5
    80000b52:	00068c23          	sb	zero,24(a3)
        idx[i] = allocDesc();
    80000b56:	c21c                	sw	a5,0(a2)
        if(idx[i] < 0){
    80000b58:	0207c563          	bltz	a5,80000b82 <diskRW+0x7e>
    for(int i = 0; i < 3; i++) {
    80000b5c:	2485                	addiw	s1,s1,1
    80000b5e:	0711                	addi	a4,a4,4
    80000b60:	17448963          	beq	s1,s4,80000cd2 <diskRW+0x1ce>
        idx[i] = allocDesc();
    80000b64:	863a                	mv	a2,a4
    for(int i = 0; i < NUM; i++){
    80000b66:	00006697          	auipc	a3,0x6
    80000b6a:	4b268693          	addi	a3,a3,1202 # 80007018 <disk+0x2018>
    80000b6e:	87ce                	mv	a5,s3
        if(disk.free[i]){
    80000b70:	0006c583          	lbu	a1,0(a3)
    80000b74:	fde1                	bnez	a1,80000b4c <diskRW+0x48>
    for(int i = 0; i < NUM; i++){
    80000b76:	2785                	addiw	a5,a5,1
    80000b78:	0685                	addi	a3,a3,1
    80000b7a:	ff779be3          	bne	a5,s7,80000b70 <diskRW+0x6c>
        idx[i] = allocDesc();
    80000b7e:	57fd                	li	a5,-1
    80000b80:	c21c                	sw	a5,0(a2)
            for(int j = 0; j < i; j++)
    80000b82:	fc9051e3          	blez	s1,80000b44 <diskRW+0x40>
                freeDesc(idx[j]);
    80000b86:	f9042503          	lw	a0,-112(s0)
    80000b8a:	00000097          	auipc	ra,0x0
    80000b8e:	dce080e7          	jalr	-562(ra) # 80000958 <freeDesc>
            for(int j = 0; j < i; j++)
    80000b92:	4785                	li	a5,1
    80000b94:	fa97d8e3          	bge	a5,s1,80000b44 <diskRW+0x40>
                freeDesc(idx[j]);
    80000b98:	f9442503          	lw	a0,-108(s0)
    80000b9c:	00000097          	auipc	ra,0x0
    80000ba0:	dbc080e7          	jalr	-580(ra) # 80000958 <freeDesc>
            for(int j = 0; j < i; j++)
    80000ba4:	4789                	li	a5,2
    80000ba6:	f897dfe3          	bge	a5,s1,80000b44 <diskRW+0x40>
                freeDesc(idx[j]);
    80000baa:	f9842503          	lw	a0,-104(s0)
    80000bae:	00000097          	auipc	ra,0x0
    80000bb2:	daa080e7          	jalr	-598(ra) # 80000958 <freeDesc>
            for(int j = 0; j < i; j++)
    80000bb6:	b779                	j	80000b44 <diskRW+0x40>
    disk.desc[idx[0]].next = idx[1];

    disk.desc[idx[1]].addr = (uint64) b->data;
    disk.desc[idx[1]].len = BSIZE;
    if(write)
        disk.desc[idx[1]].flags = 0; // device reads b->data
    80000bb8:	00006717          	auipc	a4,0x6
    80000bbc:	44873703          	ld	a4,1096(a4) # 80007000 <disk+0x2000>
    80000bc0:	973e                	add	a4,a4,a5
    80000bc2:	00071623          	sh	zero,12(a4)
    else
        disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80000bc6:	00004517          	auipc	a0,0x4
    80000bca:	43a50513          	addi	a0,a0,1082 # 80005000 <disk>
    80000bce:	00006717          	auipc	a4,0x6
    80000bd2:	43270713          	addi	a4,a4,1074 # 80007000 <disk+0x2000>
    80000bd6:	6314                	ld	a3,0(a4)
    80000bd8:	96be                	add	a3,a3,a5
    80000bda:	00c6d603          	lhu	a2,12(a3)
    80000bde:	00166613          	ori	a2,a2,1
    80000be2:	00c69623          	sh	a2,12(a3)
    disk.desc[idx[1]].next = idx[2];
    80000be6:	f9842683          	lw	a3,-104(s0)
    80000bea:	6310                	ld	a2,0(a4)
    80000bec:	97b2                	add	a5,a5,a2
    80000bee:	00d79723          	sh	a3,14(a5)

    disk.info[idx[0]].status = 0;
    80000bf2:	20080613          	addi	a2,a6,512
    80000bf6:	0612                	slli	a2,a2,0x4
    80000bf8:	962a                	add	a2,a2,a0
    80000bfa:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
    disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80000bfe:	00469793          	slli	a5,a3,0x4
    80000c02:	00073883          	ld	a7,0(a4)
    80000c06:	98be                	add	a7,a7,a5
    80000c08:	6689                	lui	a3,0x2
    80000c0a:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80000c0e:	96ae                	add	a3,a3,a1
    80000c10:	96aa                	add	a3,a3,a0
    80000c12:	00d8b023          	sd	a3,0(a7)
    disk.desc[idx[2]].len = 1;
    80000c16:	6314                	ld	a3,0(a4)
    80000c18:	96be                	add	a3,a3,a5
    80000c1a:	4585                	li	a1,1
    80000c1c:	c68c                	sw	a1,8(a3)
    disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80000c1e:	6314                	ld	a3,0(a4)
    80000c20:	96be                	add	a3,a3,a5
    80000c22:	4889                	li	a7,2
    80000c24:	01169623          	sh	a7,12(a3)
    disk.desc[idx[2]].next = 0;
    80000c28:	6314                	ld	a3,0(a4)
    80000c2a:	97b6                	add	a5,a5,a3
    80000c2c:	00079723          	sh	zero,14(a5)

    // record struct buf for diskIntr().
    b->disk = 1;
    80000c30:	00bc2223          	sw	a1,4(s8)
    disk.info[idx[0]].b = b;
    80000c34:	03863423          	sd	s8,40(a2)

    // avail[0] is flags
    // avail[1] tells the device how far to look in avail[2...].
    // avail[2...] are desc[] indices the device should process.
    // we only tell device the first index in our chain of descriptors.
    disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    80000c38:	6714                	ld	a3,8(a4)
    80000c3a:	0026d783          	lhu	a5,2(a3)
    80000c3e:	8b9d                	andi	a5,a5,7
    80000c40:	2789                	addiw	a5,a5,2
    80000c42:	0786                	slli	a5,a5,0x1
    80000c44:	97b6                	add	a5,a5,a3
    80000c46:	01079023          	sh	a6,0(a5)
    // __sync_synchronize();
    disk.avail[1] = disk.avail[1] + 1;
    80000c4a:	6718                	ld	a4,8(a4)
    80000c4c:	00275783          	lhu	a5,2(a4)
    80000c50:	2785                	addiw	a5,a5,1
    80000c52:	00f71123          	sh	a5,2(a4)

    *RVIRT(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80000c56:	100017b7          	lui	a5,0x10001
    80000c5a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>
    asm volatile("csrr %0, mie" : "=r" (x) );
    80000c5e:	304027f3          	csrr	a5,mie
    w_mie(r_mie() | MIE_MEIE);
    80000c62:	6705                	lui	a4,0x1
    80000c64:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000c68:	8fd9                	or	a5,a5,a4
    asm volatile("csrw mie, %0" : : "r" (x));
    80000c6a:	30479073          	csrw	mie,a5
    asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000c6e:	300027f3          	csrr	a5,mstatus
    w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000c72:	0087e793          	ori	a5,a5,8
    asm volatile("csrw mstatus, %0" : : "r" (x));
    80000c76:	30079073          	csrw	mstatus,a5

    // Wait for diskIntr() to say request has finished.

    intr_dev_on();
    asm("wfi");
    80000c7a:	10500073          	wfi
    asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000c7e:	300027f3          	csrr	a5,mstatus
    w_mstatus(r_mstatus() & ~(MSTATUS_MIE | MSTATUS_MPIE));
    80000c82:	f777f793          	andi	a5,a5,-137
    asm volatile("csrw mstatus, %0" : : "r" (x));
    80000c86:	30079073          	csrw	mstatus,a5
    asm volatile("csrr %0, mie" : "=r" (x) );
    80000c8a:	304027f3          	csrr	a5,mie
    w_mie(r_mie() & (~(MIE_MEIE | MIE_MTIE | MIE_MSIE)));
    80000c8e:	777d                	lui	a4,0xfffff
    80000c90:	77770713          	addi	a4,a4,1911 # fffffffffffff777 <currentProcess+0xffffffff7ffed8ab>
    80000c94:	8ff9                	and	a5,a5,a4
    asm volatile("csrw mie, %0" : : "r" (x));
    80000c96:	30479073          	csrw	mie,a5
    intr_all_off();

    disk.info[idx[0]].b = 0;
    80000c9a:	f9042483          	lw	s1,-112(s0)
    80000c9e:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    80000ca2:	0792                	slli	a5,a5,0x4
    80000ca4:	953e                	add	a0,a0,a5
    80000ca6:	02053423          	sd	zero,40(a0)
        if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80000caa:	00006917          	auipc	s2,0x6
    80000cae:	35690913          	addi	s2,s2,854 # 80007000 <disk+0x2000>
        freeDesc(i);
    80000cb2:	8526                	mv	a0,s1
    80000cb4:	00000097          	auipc	ra,0x0
    80000cb8:	ca4080e7          	jalr	-860(ra) # 80000958 <freeDesc>
        if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80000cbc:	0492                	slli	s1,s1,0x4
    80000cbe:	00093783          	ld	a5,0(s2)
    80000cc2:	94be                	add	s1,s1,a5
    80000cc4:	00c4d783          	lhu	a5,12(s1)
    80000cc8:	8b85                	andi	a5,a5,1
    80000cca:	cfb5                	beqz	a5,80000d46 <diskRW+0x242>
            i = disk.desc[i].next;
    80000ccc:	00e4d483          	lhu	s1,14(s1)
        freeDesc(i);
    80000cd0:	b7cd                	j	80000cb2 <diskRW+0x1ae>
    if(write)
    80000cd2:	01a037b3          	snez	a5,s10
    80000cd6:	f8f42023          	sw	a5,-128(s0)
    buf0.reserved = 0;
    80000cda:	f8042223          	sw	zero,-124(s0)
    buf0.sector = sector;
    80000cde:	f9943423          	sd	s9,-120(s0)
    disk.desc[idx[0]].addr = (uint64) &buf0;
    80000ce2:	f9042803          	lw	a6,-112(s0)
    80000ce6:	00481593          	slli	a1,a6,0x4
    80000cea:	00006717          	auipc	a4,0x6
    80000cee:	31670713          	addi	a4,a4,790 # 80007000 <disk+0x2000>
    80000cf2:	631c                	ld	a5,0(a4)
    80000cf4:	97ae                	add	a5,a5,a1
    80000cf6:	f8040693          	addi	a3,s0,-128
    80000cfa:	e394                	sd	a3,0(a5)
    disk.desc[idx[0]].len = sizeof(buf0);
    80000cfc:	631c                	ld	a5,0(a4)
    80000cfe:	97ae                	add	a5,a5,a1
    80000d00:	46c1                	li	a3,16
    80000d02:	c794                	sw	a3,8(a5)
    disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80000d04:	631c                	ld	a5,0(a4)
    80000d06:	97ae                	add	a5,a5,a1
    80000d08:	4685                	li	a3,1
    80000d0a:	00d79623          	sh	a3,12(a5)
    disk.desc[idx[0]].next = idx[1];
    80000d0e:	f9442783          	lw	a5,-108(s0)
    80000d12:	6314                	ld	a3,0(a4)
    80000d14:	96ae                	add	a3,a3,a1
    80000d16:	00f69723          	sh	a5,14(a3)
    disk.desc[idx[1]].addr = (uint64) b->data;
    80000d1a:	0792                	slli	a5,a5,0x4
    80000d1c:	6314                	ld	a3,0(a4)
    80000d1e:	96be                	add	a3,a3,a5
    80000d20:	030c0613          	addi	a2,s8,48
    80000d24:	e290                	sd	a2,0(a3)
    disk.desc[idx[1]].len = BSIZE;
    80000d26:	6318                	ld	a4,0(a4)
    80000d28:	973e                	add	a4,a4,a5
    80000d2a:	40000693          	li	a3,1024
    80000d2e:	c714                	sw	a3,8(a4)
    if(write)
    80000d30:	e80d14e3          	bnez	s10,80000bb8 <diskRW+0xb4>
        disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80000d34:	00006717          	auipc	a4,0x6
    80000d38:	2cc73703          	ld	a4,716(a4) # 80007000 <disk+0x2000>
    80000d3c:	973e                	add	a4,a4,a5
    80000d3e:	4689                	li	a3,2
    80000d40:	00d71623          	sh	a3,12(a4)
    80000d44:	b549                	j	80000bc6 <diskRW+0xc2>
    freeChain(idx[0]);
}
    80000d46:	70e6                	ld	ra,120(sp)
    80000d48:	7446                	ld	s0,112(sp)
    80000d4a:	74a6                	ld	s1,104(sp)
    80000d4c:	7906                	ld	s2,96(sp)
    80000d4e:	69e6                	ld	s3,88(sp)
    80000d50:	6a46                	ld	s4,80(sp)
    80000d52:	6aa6                	ld	s5,72(sp)
    80000d54:	6b06                	ld	s6,64(sp)
    80000d56:	7be2                	ld	s7,56(sp)
    80000d58:	7c42                	ld	s8,48(sp)
    80000d5a:	7ca2                	ld	s9,40(sp)
    80000d5c:	7d02                	ld	s10,32(sp)
    80000d5e:	6109                	addi	sp,sp,128
    80000d60:	8082                	ret

0000000080000d62 <diskIntr>:

void diskIntr() {
    while((disk.used_idx % NUM) != (disk.used->id % NUM)) {
    80000d62:	00006717          	auipc	a4,0x6
    80000d66:	29e70713          	addi	a4,a4,670 # 80007000 <disk+0x2000>
    80000d6a:	02075783          	lhu	a5,32(a4)
    80000d6e:	6b18                	ld	a4,16(a4)
    80000d70:	00275683          	lhu	a3,2(a4)
    80000d74:	8ebd                	xor	a3,a3,a5
    80000d76:	8a9d                	andi	a3,a3,7
    80000d78:	c2d1                	beqz	a3,80000dfc <diskIntr+0x9a>
void diskIntr() {
    80000d7a:	7179                	addi	sp,sp,-48
    80000d7c:	f406                	sd	ra,40(sp)
    80000d7e:	f022                	sd	s0,32(sp)
    80000d80:	ec26                	sd	s1,24(sp)
    80000d82:	e84a                	sd	s2,16(sp)
    80000d84:	e44e                	sd	s3,8(sp)
    80000d86:	e052                	sd	s4,0(sp)
    80000d88:	1800                	addi	s0,sp,48
        int id = disk.used->elems[disk.used_idx].id;

        if(disk.info[id].status != 0)
    80000d8a:	00004997          	auipc	s3,0x4
    80000d8e:	27698993          	addi	s3,s3,630 # 80005000 <disk>
        error("diskIntr status");
    80000d92:	00001a17          	auipc	s4,0x1
    80000d96:	37ea0a13          	addi	s4,s4,894 # 80002110 <strlen+0x1080>
        
        disk.info[id].b->disk = 0;   // disk is done with buf

        disk.used_idx = (disk.used_idx + 1) % NUM;
    80000d9a:	00006917          	auipc	s2,0x6
    80000d9e:	26690913          	addi	s2,s2,614 # 80007000 <disk+0x2000>
    80000da2:	a815                	j	80000dd6 <diskIntr+0x74>
        error("diskIntr status");
    80000da4:	8552                	mv	a0,s4
    80000da6:	fffff097          	auipc	ra,0xfffff
    80000daa:	49e080e7          	jalr	1182(ra) # 80000244 <error>
        disk.info[id].b->disk = 0;   // disk is done with buf
    80000dae:	20048493          	addi	s1,s1,512
    80000db2:	0492                	slli	s1,s1,0x4
    80000db4:	94ce                	add	s1,s1,s3
    80000db6:	749c                	ld	a5,40(s1)
    80000db8:	0007a223          	sw	zero,4(a5)
        disk.used_idx = (disk.used_idx + 1) % NUM;
    80000dbc:	02095783          	lhu	a5,32(s2)
    80000dc0:	2785                	addiw	a5,a5,1
    80000dc2:	8b9d                	andi	a5,a5,7
    80000dc4:	02f91023          	sh	a5,32(s2)
    while((disk.used_idx % NUM) != (disk.used->id % NUM)) {
    80000dc8:	01093703          	ld	a4,16(s2)
    80000dcc:	00275683          	lhu	a3,2(a4)
    80000dd0:	8a9d                	andi	a3,a3,7
    80000dd2:	00f68d63          	beq	a3,a5,80000dec <diskIntr+0x8a>
        int id = disk.used->elems[disk.used_idx].id;
    80000dd6:	078e                	slli	a5,a5,0x3
    80000dd8:	97ba                	add	a5,a5,a4
    80000dda:	43c4                	lw	s1,4(a5)
        if(disk.info[id].status != 0)
    80000ddc:	20048793          	addi	a5,s1,512
    80000de0:	0792                	slli	a5,a5,0x4
    80000de2:	97ce                	add	a5,a5,s3
    80000de4:	0307c783          	lbu	a5,48(a5)
    80000de8:	d3f9                	beqz	a5,80000dae <diskIntr+0x4c>
    80000dea:	bf6d                	j	80000da4 <diskIntr+0x42>
    }
}
    80000dec:	70a2                	ld	ra,40(sp)
    80000dee:	7402                	ld	s0,32(sp)
    80000df0:	64e2                	ld	s1,24(sp)
    80000df2:	6942                	ld	s2,16(sp)
    80000df4:	69a2                	ld	s3,8(sp)
    80000df6:	6a02                	ld	s4,0(sp)
    80000df8:	6145                	addi	sp,sp,48
    80000dfa:	8082                	ret
    80000dfc:	8082                	ret

0000000080000dfe <logDataInit>:
#include "declarations.h"
#include "functions.h"

void logDataInit() {
    80000dfe:	1141                	addi	sp,sp,-16
    80000e00:	e422                	sd	s0,8(sp)
    80000e02:	0800                	addi	s0,sp,16
    block_no = LOGSTART;
    80000e04:	38400793          	li	a5,900
    80000e08:	00011717          	auipc	a4,0x11
    80000e0c:	0af72e23          	sw	a5,188(a4) # 80011ec4 <block_no>
    off = 0;
    80000e10:	00011797          	auipc	a5,0x11
    80000e14:	0a07a823          	sw	zero,176(a5) # 80011ec0 <off>
}
    80000e18:	6422                	ld	s0,8(sp)
    80000e1a:	0141                	addi	sp,sp,16
    80000e1c:	8082                	ret

0000000080000e1e <logData>:

void logData(char *prt_str) {
    80000e1e:	715d                	addi	sp,sp,-80
    80000e20:	e486                	sd	ra,72(sp)
    80000e22:	e0a2                	sd	s0,64(sp)
    80000e24:	fc26                	sd	s1,56(sp)
    80000e26:	f84a                	sd	s2,48(sp)
    80000e28:	f44e                	sd	s3,40(sp)
    80000e2a:	f052                	sd	s4,32(sp)
    80000e2c:	ec56                	sd	s5,24(sp)
    80000e2e:	e85a                	sd	s6,16(sp)
    80000e30:	e45e                	sd	s7,8(sp)
    80000e32:	0880                	addi	s0,sp,80
    80000e34:	84aa                	mv	s1,a0
    Buffer *buff = bread(-1, block_no);
    80000e36:	00011597          	auipc	a1,0x11
    80000e3a:	08e5a583          	lw	a1,142(a1) # 80011ec4 <block_no>
    80000e3e:	557d                	li	a0,-1
    80000e40:	00000097          	auipc	ra,0x0
    80000e44:	8cc080e7          	jalr	-1844(ra) # 8000070c <bread>
    80000e48:	89aa                	mv	s3,a0

    while((*prt_str) != '\0') {
    80000e4a:	0004c783          	lbu	a5,0(s1)
    80000e4e:	cbc1                	beqz	a5,80000ede <logData+0xc0>
        if(off == BSIZE) {
    80000e50:	00011917          	auipc	s2,0x11
    80000e54:	07090913          	addi	s2,s2,112 # 80011ec0 <off>
    80000e58:	40000a13          	li	s4,1024
            bwrite(buff);
            brelse(buff);
            block_no ++;
    80000e5c:	00011a97          	auipc	s5,0x11
    80000e60:	068a8a93          	addi	s5,s5,104 # 80011ec4 <block_no>
            off = 0;
            if(block_no == DISKSIZE)
    80000e64:	3e800b13          	li	s6,1000
                error("logData: log blocks filled");
    80000e68:	00001b97          	auipc	s7,0x1
    80000e6c:	2b8b8b93          	addi	s7,s7,696 # 80002120 <strlen+0x1090>
    80000e70:	a805                	j	80000ea0 <logData+0x82>

            buff = bread(-1, block_no);
    80000e72:	000aa583          	lw	a1,0(s5)
    80000e76:	557d                	li	a0,-1
    80000e78:	00000097          	auipc	ra,0x0
    80000e7c:	894080e7          	jalr	-1900(ra) # 8000070c <bread>
    80000e80:	89aa                	mv	s3,a0
        }
        buff->data[off] = *prt_str;
    80000e82:	00092783          	lw	a5,0(s2)
    80000e86:	0004c683          	lbu	a3,0(s1)
    80000e8a:	00f98733          	add	a4,s3,a5
    80000e8e:	02d70823          	sb	a3,48(a4)
        prt_str ++;
    80000e92:	0485                	addi	s1,s1,1
        off ++;
    80000e94:	2785                	addiw	a5,a5,1
    80000e96:	00f92023          	sw	a5,0(s2)
    while((*prt_str) != '\0') {
    80000e9a:	0004c783          	lbu	a5,0(s1)
    80000e9e:	c3a1                	beqz	a5,80000ede <logData+0xc0>
        if(off == BSIZE) {
    80000ea0:	00092783          	lw	a5,0(s2)
    80000ea4:	fd479fe3          	bne	a5,s4,80000e82 <logData+0x64>
            bwrite(buff);
    80000ea8:	854e                	mv	a0,s3
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	896080e7          	jalr	-1898(ra) # 80000740 <bwrite>
            brelse(buff);
    80000eb2:	854e                	mv	a0,s3
    80000eb4:	00000097          	auipc	ra,0x0
    80000eb8:	8a6080e7          	jalr	-1882(ra) # 8000075a <brelse>
            block_no ++;
    80000ebc:	000aa783          	lw	a5,0(s5)
    80000ec0:	2785                	addiw	a5,a5,1
    80000ec2:	0007871b          	sext.w	a4,a5
    80000ec6:	00faa023          	sw	a5,0(s5)
            off = 0;
    80000eca:	00092023          	sw	zero,0(s2)
            if(block_no == DISKSIZE)
    80000ece:	fb6712e3          	bne	a4,s6,80000e72 <logData+0x54>
                error("logData: log blocks filled");
    80000ed2:	855e                	mv	a0,s7
    80000ed4:	fffff097          	auipc	ra,0xfffff
    80000ed8:	370080e7          	jalr	880(ra) # 80000244 <error>
    80000edc:	bf59                	j	80000e72 <logData+0x54>
    }

    bwrite(buff);
    80000ede:	854e                	mv	a0,s3
    80000ee0:	00000097          	auipc	ra,0x0
    80000ee4:	860080e7          	jalr	-1952(ra) # 80000740 <bwrite>
    brelse(buff);
    80000ee8:	854e                	mv	a0,s3
    80000eea:	00000097          	auipc	ra,0x0
    80000eee:	870080e7          	jalr	-1936(ra) # 8000075a <brelse>
    80000ef2:	60a6                	ld	ra,72(sp)
    80000ef4:	6406                	ld	s0,64(sp)
    80000ef6:	74e2                	ld	s1,56(sp)
    80000ef8:	7942                	ld	s2,48(sp)
    80000efa:	79a2                	ld	s3,40(sp)
    80000efc:	7a02                	ld	s4,32(sp)
    80000efe:	6ae2                	ld	s5,24(sp)
    80000f00:	6b42                	ld	s6,16(sp)
    80000f02:	6ba2                	ld	s7,8(sp)
    80000f04:	6161                	addi	sp,sp,80
    80000f06:	8082                	ret

0000000080000f08 <memset>:
#include "declarations.h"

void* memset(void *dst, int c, uint n) {
    80000f08:	1141                	addi	sp,sp,-16
    80000f0a:	e422                	sd	s0,8(sp)
    80000f0c:	0800                	addi	s0,sp,16
    char *cdst = (char *) dst;
    int i;
    for(i = 0; i < n; i++){
    80000f0e:	ce09                	beqz	a2,80000f28 <memset+0x20>
    80000f10:	87aa                	mv	a5,a0
    80000f12:	fff6071b          	addiw	a4,a2,-1
    80000f16:	1702                	slli	a4,a4,0x20
    80000f18:	9301                	srli	a4,a4,0x20
    80000f1a:	0705                	addi	a4,a4,1
    80000f1c:	972a                	add	a4,a4,a0
        cdst[i] = c;
    80000f1e:	00b78023          	sb	a1,0(a5)
    for(i = 0; i < n; i++){
    80000f22:	0785                	addi	a5,a5,1
    80000f24:	fee79de3          	bne	a5,a4,80000f1e <memset+0x16>
    }
    return dst;
}
    80000f28:	6422                	ld	s0,8(sp)
    80000f2a:	0141                	addi	sp,sp,16
    80000f2c:	8082                	ret

0000000080000f2e <memcmp>:

int memcmp(const void *v1, const void *v2, uint n) {
    80000f2e:	1141                	addi	sp,sp,-16
    80000f30:	e422                	sd	s0,8(sp)
    80000f32:	0800                	addi	s0,sp,16
    const uchar *s1, *s2;

    s1 = v1;
    s2 = v2;
    while(n-- > 0){
    80000f34:	ca05                	beqz	a2,80000f64 <memcmp+0x36>
    80000f36:	fff6069b          	addiw	a3,a2,-1
    80000f3a:	1682                	slli	a3,a3,0x20
    80000f3c:	9281                	srli	a3,a3,0x20
    80000f3e:	0685                	addi	a3,a3,1
    80000f40:	96aa                	add	a3,a3,a0
        if(*s1 != *s2)
    80000f42:	00054783          	lbu	a5,0(a0)
    80000f46:	0005c703          	lbu	a4,0(a1)
    80000f4a:	00e79863          	bne	a5,a4,80000f5a <memcmp+0x2c>
        return *s1 - *s2;
        s1++, s2++;
    80000f4e:	0505                	addi	a0,a0,1
    80000f50:	0585                	addi	a1,a1,1
    while(n-- > 0){
    80000f52:	fed518e3          	bne	a0,a3,80000f42 <memcmp+0x14>
    }

    return 0;
    80000f56:	4501                	li	a0,0
    80000f58:	a019                	j	80000f5e <memcmp+0x30>
        return *s1 - *s2;
    80000f5a:	40e7853b          	subw	a0,a5,a4
}
    80000f5e:	6422                	ld	s0,8(sp)
    80000f60:	0141                	addi	sp,sp,16
    80000f62:	8082                	ret
    return 0;
    80000f64:	4501                	li	a0,0
    80000f66:	bfe5                	j	80000f5e <memcmp+0x30>

0000000080000f68 <memmove>:

void* memmove(void *dst, const void *src, uint n) {
    80000f68:	1141                	addi	sp,sp,-16
    80000f6a:	e422                	sd	s0,8(sp)
    80000f6c:	0800                	addi	s0,sp,16
    const char *s;
    char *d;

    s = src;
    d = dst;
    if(s < d && s + n > d){
    80000f6e:	02a5e563          	bltu	a1,a0,80000f98 <memmove+0x30>
        s += n;
        d += n;
        while(n-- > 0)
        *--d = *--s;
    } else
        while(n-- > 0)
    80000f72:	fff6069b          	addiw	a3,a2,-1
    80000f76:	ce11                	beqz	a2,80000f92 <memmove+0x2a>
    80000f78:	1682                	slli	a3,a3,0x20
    80000f7a:	9281                	srli	a3,a3,0x20
    80000f7c:	0685                	addi	a3,a3,1
    80000f7e:	96ae                	add	a3,a3,a1
    80000f80:	87aa                	mv	a5,a0
        *d++ = *s++;
    80000f82:	0585                	addi	a1,a1,1
    80000f84:	0785                	addi	a5,a5,1
    80000f86:	fff5c703          	lbu	a4,-1(a1)
    80000f8a:	fee78fa3          	sb	a4,-1(a5)
        while(n-- > 0)
    80000f8e:	fed59ae3          	bne	a1,a3,80000f82 <memmove+0x1a>

    return dst;
}
    80000f92:	6422                	ld	s0,8(sp)
    80000f94:	0141                	addi	sp,sp,16
    80000f96:	8082                	ret
    if(s < d && s + n > d){
    80000f98:	02061713          	slli	a4,a2,0x20
    80000f9c:	9301                	srli	a4,a4,0x20
    80000f9e:	00e587b3          	add	a5,a1,a4
    80000fa2:	fcf578e3          	bgeu	a0,a5,80000f72 <memmove+0xa>
        d += n;
    80000fa6:	972a                	add	a4,a4,a0
        while(n-- > 0)
    80000fa8:	fff6069b          	addiw	a3,a2,-1
    80000fac:	d27d                	beqz	a2,80000f92 <memmove+0x2a>
    80000fae:	02069613          	slli	a2,a3,0x20
    80000fb2:	9201                	srli	a2,a2,0x20
    80000fb4:	fff64613          	not	a2,a2
    80000fb8:	963e                	add	a2,a2,a5
        *--d = *--s;
    80000fba:	17fd                	addi	a5,a5,-1
    80000fbc:	177d                	addi	a4,a4,-1
    80000fbe:	0007c683          	lbu	a3,0(a5)
    80000fc2:	00d70023          	sb	a3,0(a4)
        while(n-- > 0)
    80000fc6:	fec79ae3          	bne	a5,a2,80000fba <memmove+0x52>
    80000fca:	b7e1                	j	80000f92 <memmove+0x2a>

0000000080000fcc <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void* memcpy(void *dst, const void *src, uint n) {
    80000fcc:	1141                	addi	sp,sp,-16
    80000fce:	e406                	sd	ra,8(sp)
    80000fd0:	e022                	sd	s0,0(sp)
    80000fd2:	0800                	addi	s0,sp,16
    return memmove(dst, src, n);
    80000fd4:	00000097          	auipc	ra,0x0
    80000fd8:	f94080e7          	jalr	-108(ra) # 80000f68 <memmove>
}
    80000fdc:	60a2                	ld	ra,8(sp)
    80000fde:	6402                	ld	s0,0(sp)
    80000fe0:	0141                	addi	sp,sp,16
    80000fe2:	8082                	ret

0000000080000fe4 <strncmp>:

int strncmp(const char *p, const char *q, uint n) {
    80000fe4:	1141                	addi	sp,sp,-16
    80000fe6:	e422                	sd	s0,8(sp)
    80000fe8:	0800                	addi	s0,sp,16
    while(n > 0 && *p && *p == *q)
    80000fea:	ce11                	beqz	a2,80001006 <strncmp+0x22>
    80000fec:	00054783          	lbu	a5,0(a0)
    80000ff0:	cf89                	beqz	a5,8000100a <strncmp+0x26>
    80000ff2:	0005c703          	lbu	a4,0(a1)
    80000ff6:	00f71a63          	bne	a4,a5,8000100a <strncmp+0x26>
        n--, p++, q++;
    80000ffa:	367d                	addiw	a2,a2,-1
    80000ffc:	0505                	addi	a0,a0,1
    80000ffe:	0585                	addi	a1,a1,1
    while(n > 0 && *p && *p == *q)
    80001000:	f675                	bnez	a2,80000fec <strncmp+0x8>
    if(n == 0)
        return 0;
    80001002:	4501                	li	a0,0
    80001004:	a809                	j	80001016 <strncmp+0x32>
    80001006:	4501                	li	a0,0
    80001008:	a039                	j	80001016 <strncmp+0x32>
    if(n == 0)
    8000100a:	ca09                	beqz	a2,8000101c <strncmp+0x38>
    return (uchar)*p - (uchar)*q;
    8000100c:	00054503          	lbu	a0,0(a0)
    80001010:	0005c783          	lbu	a5,0(a1)
    80001014:	9d1d                	subw	a0,a0,a5
}
    80001016:	6422                	ld	s0,8(sp)
    80001018:	0141                	addi	sp,sp,16
    8000101a:	8082                	ret
        return 0;
    8000101c:	4501                	li	a0,0
    8000101e:	bfe5                	j	80001016 <strncmp+0x32>

0000000080001020 <strncpy>:

char* strncpy(char *s, const char *t, int n) {
    80001020:	1141                	addi	sp,sp,-16
    80001022:	e422                	sd	s0,8(sp)
    80001024:	0800                	addi	s0,sp,16
    char *os;

    os = s;
    while(n-- > 0 && (*s++ = *t++) != 0)
    80001026:	872a                	mv	a4,a0
    80001028:	8832                	mv	a6,a2
    8000102a:	367d                	addiw	a2,a2,-1
    8000102c:	01005963          	blez	a6,8000103e <strncpy+0x1e>
    80001030:	0705                	addi	a4,a4,1
    80001032:	0005c783          	lbu	a5,0(a1)
    80001036:	fef70fa3          	sb	a5,-1(a4)
    8000103a:	0585                	addi	a1,a1,1
    8000103c:	f7f5                	bnez	a5,80001028 <strncpy+0x8>
        ;
    while(n-- > 0)
    8000103e:	86ba                	mv	a3,a4
    80001040:	00c05c63          	blez	a2,80001058 <strncpy+0x38>
        *s++ = 0;
    80001044:	0685                	addi	a3,a3,1
    80001046:	fe068fa3          	sb	zero,-1(a3)
    while(n-- > 0)
    8000104a:	fff6c793          	not	a5,a3
    8000104e:	9fb9                	addw	a5,a5,a4
    80001050:	010787bb          	addw	a5,a5,a6
    80001054:	fef048e3          	bgtz	a5,80001044 <strncpy+0x24>
    return os;
}
    80001058:	6422                	ld	s0,8(sp)
    8000105a:	0141                	addi	sp,sp,16
    8000105c:	8082                	ret

000000008000105e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char* safestrcpy(char *s, const char *t, int n) {
    8000105e:	1141                	addi	sp,sp,-16
    80001060:	e422                	sd	s0,8(sp)
    80001062:	0800                	addi	s0,sp,16
    char *os;

    os = s;
    if(n <= 0)
    80001064:	02c05363          	blez	a2,8000108a <safestrcpy+0x2c>
    80001068:	fff6069b          	addiw	a3,a2,-1
    8000106c:	1682                	slli	a3,a3,0x20
    8000106e:	9281                	srli	a3,a3,0x20
    80001070:	96ae                	add	a3,a3,a1
    80001072:	87aa                	mv	a5,a0
        return os;
    while(--n > 0 && (*s++ = *t++) != 0)
    80001074:	00d58963          	beq	a1,a3,80001086 <safestrcpy+0x28>
    80001078:	0585                	addi	a1,a1,1
    8000107a:	0785                	addi	a5,a5,1
    8000107c:	fff5c703          	lbu	a4,-1(a1)
    80001080:	fee78fa3          	sb	a4,-1(a5)
    80001084:	fb65                	bnez	a4,80001074 <safestrcpy+0x16>
        ;
    *s = 0;
    80001086:	00078023          	sb	zero,0(a5)
    return os;
}
    8000108a:	6422                	ld	s0,8(sp)
    8000108c:	0141                	addi	sp,sp,16
    8000108e:	8082                	ret

0000000080001090 <strlen>:

int strlen(const char *s) {
    80001090:	1141                	addi	sp,sp,-16
    80001092:	e422                	sd	s0,8(sp)
    80001094:	0800                	addi	s0,sp,16
    int n;

    for(n = 0; s[n]; n++)
    80001096:	00054783          	lbu	a5,0(a0)
    8000109a:	cf91                	beqz	a5,800010b6 <strlen+0x26>
    8000109c:	0505                	addi	a0,a0,1
    8000109e:	87aa                	mv	a5,a0
    800010a0:	4685                	li	a3,1
    800010a2:	9e89                	subw	a3,a3,a0
    800010a4:	00f6853b          	addw	a0,a3,a5
    800010a8:	0785                	addi	a5,a5,1
    800010aa:	fff7c703          	lbu	a4,-1(a5)
    800010ae:	fb7d                	bnez	a4,800010a4 <strlen+0x14>
        ;
    return n;
}
    800010b0:	6422                	ld	s0,8(sp)
    800010b2:	0141                	addi	sp,sp,16
    800010b4:	8082                	ret
    for(n = 0; s[n]; n++)
    800010b6:	4501                	li	a0,0
    800010b8:	bfe5                	j	800010b0 <strlen+0x20>
	...
