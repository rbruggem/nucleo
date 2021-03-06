// io.s
//
#define ASM 1
#include "costanti.h"

////////////////////////////////////////////////////////////////////////////////
//                                 COSTANTI                                   //
////////////////////////////////////////////////////////////////////////////////

// Tipi delle interruzioni delle chiamate di sistema usate
// Devono coincidere con quelli usati in sistema.s e utente.s
//
.set tipo_a,  TIPO_A
.set tipo_t,  TIPO_T
.set tipo_si, TIPO_SI
.set tipo_w,  TIPO_W
.set tipo_s,  TIPO_S
.set tipo_nd, TIPO_ND
.set tipo_d,  TIPO_D
.set tipo_l,	TIPO_L

// Tipi delle interruzioni usate per interfacciarsi al modulo
//  sistema
// Devono coincidere con quelli usati in sistema.s
//
.set tipo_ae,   TIPO_AE
.set tipo_nwfi, TIPO_NWFI
.set tipo_va,   TIPO_VA
.set tipo_p,    TIPO_P
.set tipo_ab,   TIPO_AB
.set tipo_fg,   TIPO_FG
.set tipo_rl,   TIPO_RL


// Tipi delle interruzioni usate dalle primitive di IO
// Devono coincidere con quelli usati in utente.s
//
.set io_tipo_rsen,  IO_TIPO_RSEN
.set io_tipo_rseln, IO_TIPO_RSELN
.set io_tipo_wsen,  IO_TIPO_WSEN
.set io_tipo_wse0,  IO_TIPO_WSE0
.set io_tipo_rkbd,  IO_TIPO_RKBD		
.set io_tipo_ikbd,  IO_TIPO_IKBD		
.set io_tipo_skbd,  IO_TIPO_SKBD		
.set io_tipo_wfikbd, IO_TIPO_WFIKBD
.set io_tipo_smon,  IO_TIPO_SMON		
.set io_tipo_wmon,  IO_TIPO_WMON		
.set io_tipo_cmon,  IO_TIPO_CMON		
.set io_tipo_gmon,  IO_TIPO_GMON		
.set io_tipo_lkbd,  IO_TIPO_LKBD
.set io_tipo_kmon,  IO_TIPO_KMON		
.set io_tipo_pkbd,  IO_TIPO_PKBD


////////////////////////////////////////////////////////////////////////////////
//                  MACRO PER LA MANIPOLAZIONE DEI PARAMETRI                  //
////////////////////////////////////////////////////////////////////////////////

// Copia dei parametri di una chiamata di sistema dalla pila utente
//  alla pila sistema
.macro copia_param n_long offset
        movl $\offset, %ecx
        movl 4(%esp, %ecx, 4), %eax     // cs in eax
        testl $3, %eax			// verifica del livello di privilegio
					//  del chiamante
        jz 1f                           // copia da pila sistema

        movl 12(%esp, %ecx, 4), %eax    // vecchio esp (della pila utente)
					//  in eax
        leal 4(%eax), %esi		// indirizzo del primo parametro in
					//  esi
        jmp 2f
1:
        leal 16(%esp, %ecx, 4), %esi	// indirizzo del primo parametro in esi
2:
        movl $\n_long, %eax		// creazione in pila dello spazio per
        shll $2, %eax			//  la copia dei parametri
        subl %eax, %esp
        leal (%esp), %edi		// indirizzo della destinazione del
					//  primo parametro in edi

        movl $\n_long, %ecx
        cld
        rep
           movsl			// copia dei parametri
.endm

// Salvataggio dei registri in pila
.macro salva_registri
	pushl %eax
	pushl %ecx
	pushl %edx
	pushl %ebx
	pushl %esi
	pushl %edi
	pushl %ebp
.endm

// Caricamento dei registri dalla pila (duale rispetto a salva_registri)
.macro carica_registri
	popl %ebp
	popl %edi
	popl %esi
	popl %ebx
	popl %edx
	popl %ecx
	popl %eax
.endm

// salvataggio dei registri in pila per chiamate di sistema che ritornano
//  un valore in eax, che non viene salvato
.macro salva_reg_rit

	pushl %ecx
	pushl %edx
	pushl %ebx
	pushl %esi
	pushl %edi
	pushl %ebp

.endm


// ripristino dei registri (tutti meno eax) dalla pila (duale rispetto a
//  salva_reg_rit)
.macro carica_reg_rit

	popl %ebp
	popl %edi
	popl %esi
	popl %ebx
	popl %edx
	popl %ecx

.endm

// Chiama _fill_gate con i parametri specificati
.macro fill_io_gate gate off
	pushl $LIV_UTENTE
	pushl $\off
	pushl $\gate
	call _fill_gate
	addl $12, %esp
.endm

.global start, _start
start:
_start:	jmp _cmain

////////////////////////////////////////////////////////////////////////////////
//                             SEZIONE DATI                                   //
////////////////////////////////////////////////////////////////////////////////

	.data

// Descrittori delle interfacce seriali
	.global _com		// non comi, como
_com:	.long	0x03f8		// com[0].indreg.iRBR
	.long	0x03f8		// com[0].indreg.iTHR
	.long	0x03fd		// com[0].indreg.iLSR
	.long	0x03f9		// com[0].indreg.iIER
	.long	0x03fa		// com[0].indreg.iIIR
	.long	0		// com[0].mutex
	.long	0		// com[0].sincr
	.long	0		// com[0].cont
	.long	0		// com[0].punt
	.long	0		// com[0].funzione
	.long	0		// com[0].stato
	.long	0x02f8		// com[1].indreg.iRBR
	.long	0x02f8		// com[1].indreg.iTHR
	.long	0x03fd		// com[1].indreg.iLSR
	.long	0x02f9		// com[1].indreg.iIER
	.long	0x02fa		// com[1].indreg.iIIR
	.long	0		// com[1].mutex
	.long	0		// com[1].sincr
	.long	0		// com[1].cont
	.long	0		// com[1].punt
	.long	0		// com[1].funzione
	.long	0		// com[1].stato



////////////////////////////////////////////////////////////////////////////////
//                            SEZIONE TESTO                                   //
////////////////////////////////////////////////////////////////////////////////

	.text

////////////////////////////////////////////////////////////////////////////////
//                          CHIAMATE DI SISTEMA                               //
////////////////////////////////////////////////////////////////////////////////

	.text
	.global _activate_p
_activate_p:
	int $tipo_a
	ret

	.global _terminate_p
_terminate_p:
	int $tipo_t
	ret

	.global _sem_ini
_sem_ini:
	int $tipo_si
	ret

	.global _sem_wait
_sem_wait:
	int $tipo_w
	ret

	.global _sem_signal
_sem_signal:
	int $tipo_s
	ret

////////////////////////////////////////////////////////////////////////////////
//                     INTERFACCIA VERSO IL MODULO SISTEMA                    //
////////////////////////////////////////////////////////////////////////////////

	.global _activate_pe
_activate_pe:
	int $tipo_ae
	ret

	.global _nwfi
_nwfi:
	int $tipo_nwfi
	ret

	.global _verifica_area
_verifica_area:
	int $tipo_va
	ret

	.global _panic
_panic:
	int $tipo_p
	ret

	.global _abort_p
_abort_p:
	int $tipo_ab
	ret

	.global _fill_gate
_fill_gate:
	int $tipo_fg
	ret

	.global _delay
_delay:
	int $tipo_d
	ret

	.global _log
_log:
	int $tipo_l
	ret
 
////////////////////////////////////////////////////////////////////////////////
//                         FUNZIONI DI SUPPORTO                               //
////////////////////////////////////////////////////////////////////////////////

// Ingresso di un byte da una porta di IO
	.global _inputb
_inputb:
	pushl %eax
	pushl %edx
	movl 12(%esp), %edx
	inb %dx, %al
	movl 16(%esp), %edx
	movb %al, (%edx)
	popl %edx
	popl %eax
	ret

// Uscita di un byte su una porta di IO
	.global _outputb
_outputb:
	pushl %eax
	pushl %edx
	movb 12(%esp), %al
	movl 16(%esp), %edx
	outb %al, %dx
	popl %edx
	popl %eax
	ret

// Ingresso di una word da una porta di IO
	.global _inputw
_inputw:
	pushl %eax
	pushl %edx
	movl 12(%esp), %edx
	inw %dx, %ax
	movl 16(%esp), %edx
	movw %ax, (%edx)
	popl %edx
	popl %eax
	ret

// Uscita di una word su una porta di IO
	.global _outputw
_outputw:
	pushl %eax
	pushl %edx
	movw 12(%esp), %ax
	movl 16(%esp), %edx
	outw %ax, %dx
	popl %edx
	popl %eax
	ret

// Ingresso di un buffer continuo da un buffer di IO di word
	.global _inputbuffw
_inputbuffw:
	pushl %eax
	pushl %edx
	pushl %edi
	pushl %ecx
	
	movl 20(%esp), %edx
	movl 24(%esp), %edi
	movl 28(%esp),%ecx
	cld
	rep
	insw
	
	popl %ecx
	popl %edi
	popl %edx
	popl %eax
	ret

// Uscita di un buffer continuo su una buffer di IO di word
	.global _outputbuffw
_outputbuffw:
	pushl %eax
	pushl %edx
	pushl %esi
	pushl %ecx
	
	movl 24(%esp), %edx
	movl 20(%esp), %esi
	movl 28(%esp),%ecx
	cld
	rep
	outsw
	
	popl %ecx
	popl %esi
	popl %edx
	popl %eax
	ret

// Indirizzi delle porte del controllore delle interruzioni
.set OCW1M, 0x21
.set OCW2M, 0x20
.set OCW1S, 0xa1
.set OCW2S, 0xa0
.set EOI, 0x20

// Inizio dell' ingresso da una interfaccia seriale
	.global _go_inputse
_go_inputse:
	pushl %eax
	pushl %edx

	movl 12(%esp), %edx		// ind. di IER in edx
	inb %dx, %al
	orb $0x01, %al			// abilitazione dell' interfaccia a
					//  generare interruzioni in ingresso
	outb %al, %dx

	cmpw $0x03f9, %dx
	jne 1f
	movb $0b11101111, %ah
	jmp 2f

1:
	movb $0b11110111, %ah
2:
	cli
	inb $OCW1M, %al
	andb %ah, %al
	outb %al, $OCW1M		// abilitazione del controllore ad
					//  accettare richieste di interruzione
					//  da parte dell' interfaccia
	sti

	popl %edx
	popl %eax
	ret

// Fine dell' ingresso da un' interfaccia seriale
	.global _halt_inputse
_halt_inputse:
	pushl %eax
	pushl %edx

	movl 12(%esp), %edx		// ind. di IER in edx
	inb %dx, %al
	and $0xfe, %al
	outb %al, %dx			// disabilitazione della generazione
					//  di interruzioni

	cmpw $0x03f9, %dx
	jne 1f
	movb $0b00010000, %ah
	jmp 2f

1:
	movb $0b00001000, %ah
2:
	cli
	inb $OCW1M, %al
	andb %ah, %al
	outb %al, $OCW1M		// disabilitazione dell 'interruzione al
					//  controllore
	sti

	popl %edx
	popl %eax
	ret

// Inizio dell' uscita su interfaccia seriale
	.global _go_outputse
_go_outputse:
	pushl %eax
	pushl %edx

	movl 12(%esp), %edx		// ind. di IER in edx
	inb %dx, %al
	orb $0x02, %al
	outb %al, %dx

	cmpw $0x03f9, %dx
	jne 1f
	movb $0b11101111, %ah
	jmp 2f

1:
	movb $0b11110111, %ah
2:
	cli
	inb $OCW1M, %al
	andb %ah, %al
	outb %al, $OCW1M
	sti

	popl %edx
	popl %eax
	ret

// Fine dell' uscita su interfaccia seriale
	.global _halt_outputse
_halt_outputse:
	pushl %eax
	pushl %edx

	movl 12(%esp), %edx		// ind. di IER in edx
	inb %dx, %al
	and $0xfd, %al
	outb %al, %dx

	cmpw $0x03f9, %dx
	jne 1f
	movb $0b00010000, %ah
	jmp 2f

1:
	movb $0b00001000, %ah
2:
	cli
	inb $OCW1M, %al
	andb %ah, %al
	outb %al, $OCW1M
	sti

	popl %edx
	popl %eax
	ret

// Indirizzi delle porte delle interfacce seriali
.set LCR1, 0x03fb
.set LCR2, 0x02fb
.set DLR_LSB1, 0x03f8
.set DLR_LSB2, 0x02f8
.set DLR_MSB1, 0x03f9
.set DLR_MSB2, 0x02f9
.set IER1, 0x03f9
.set IER2, 0x02f9
.set RBR1, 0x03f8
.set RBR2, 0x02f8
.set MCR1, 0x03fc
.set MCR2, 0x02fc


// Inizializzazione delle interfacce seriali
	.global _com_setup
_com_setup:
	pushl %eax
	pushl %edx

	movb $0x80, %al
	movw $LCR1, %dx
	outb %al, %dx
	movw $0x000c, %ax
	movw $DLR_LSB1, %dx
	outb %al, %dx
	movb %ah, %al
	movw $DLR_MSB1, %dx
	outb %al, %dx
	movb $0x03, %al
	movw $LCR1, %dx
	outb %al, %dx
	movb $0x00, %al
	movw $IER1, %dx
	outb %al, %dx
	movw $RBR1, %dx
	movw $MCR1, %dx			// abilitazione porta 3-state
	movb $0b00001000, %al
	outb %al, %dx
	inb %dx, %al

	movb $0x80, %al
	movw $LCR2, %dx
	outb %al, %dx
	movw $0x000c, %ax
	movw $DLR_LSB2, %dx
	outb %al, %dx
	movb %ah, %al
	movw $DLR_MSB2, %dx
	outb %al, %dx
	movb $0x03, %al
	movw $LCR2, %dx
	outb %al, %dx
	movb $0x00, %al
	movw $IER2, %dx
	outb %al, %dx
	movw $RBR2, %dx
	movw $MCR2, %dx
	movb $0b00001000, %al
	outb %al, %dx

	inb %dx, %al

	popl %edx
	popl %eax

	ret

// Abilitazione del controllore delle interruzioni ad inoltrare le richieste
//  provenienti dalla tastera
	.global _kbd_enable
_kbd_enable:
	inb $OCW1M, %al
	andb $0b11111101, %al
	outb %al, $OCW1M
	ret

.macro wait_kbd
1:	inb $0x64, %al	  // leggi stato
	testb $0x02, %al  // busy?
	jnz 1b
.endm

	.global _kbd_set_leds
_kbd_set_leds:
	pushl %ebp
	movl  %esp, %ebp
	pushl %eax

	wait_kbd
	movb $0xad, %al // disabilita tastiera
	outb %al, $0x64
	wait_kbd
	movb $0xed, %al   // comando "set led"
	outb %al, $0x60
	wait_kbd
	movb 8(%ebp), %al // stato dei led
	outb %al, $0x60
	wait_kbd
	movb $0xae, %al // abilita tastiera
	outb %al, $0x64
	
	popl %eax
	leave
	ret

// indirizzi delle porte relative alla gestione del cursore, nel controllore 
// della scheda video
.set CUR_HIGH, 0x0e
.set CUR_LOW, 0x0f
.set CUR_START, 0x0a
.set ADD_P, 0x03d4
.set DAT_P, 0x03d5

	.global _console_set_cursor_size
_console_set_cursor_size:
	pushl %ebp
	movl %esp, %ebp
	pushl %edx
	pushl %eax

	movw $ADD_P, %dx
	movb $CUR_START, %al
	outb %al, %dx
	movw $DAT_P, %dx
	movl 8(%ebp), %eax
	andb $0x1f, %al
	outb %al, %dx

	popl %eax
	popl %edx
	leave
	ret

	

// visualizza il cursore nella posizione passata come parametro
	.global _console_cursor
_console_cursor:
	pushl %ebp
	movl %esp, %ebp
	pushl %edx
	pushl %eax

	movw $ADD_P, %dx
	movb $CUR_HIGH, %al
	outb %al, %dx
	movw $DAT_P, %dx
	movw 8(%ebp), %ax
	movb %ah, %al
	outb %al, %dx
	movw $ADD_P, %dx
	movb $CUR_LOW, %al
	outb %al, %dx
	movw $DAT_P, %dx
	movw 8(%ebp), %ax
	outb %al, %dx

	popl %eax
	popl %edx
	leave
	ret



// Inizializzazione dei gate per le primitive di IO
	.global _fill_io_gates
_fill_io_gates:
	pushl %ebp
	movl %esp, %ebp

	fill_io_gate	io_tipo_rsen	a_readse_n
	fill_io_gate	io_tipo_rseln	a_readse_ln
	fill_io_gate	io_tipo_wsen	a_writese_n
	fill_io_gate	io_tipo_wse0	a_writese_0
	fill_io_gate	io_tipo_rkbd	a_vkbd_read
	fill_io_gate	io_tipo_ikbd	a_vkbd_intr_enable
	fill_io_gate	io_tipo_skbd	a_vkbd_switch
	fill_io_gate	io_tipo_wfikbd	a_vkbd_wfi
	fill_io_gate	io_tipo_smon	a_vmon_switch
	fill_io_gate	io_tipo_wmon	a_vmon_write_n
	fill_io_gate	io_tipo_cmon	a_vmon_setcursor
	fill_io_gate	io_tipo_gmon	a_vmon_getsize
	fill_io_gate	io_tipo_lkbd	a_vkbd_leds
	fill_io_gate	io_tipo_kmon	a_vmon_cursor_shape
	fill_io_gate	io_tipo_pkbd	a_vkbd_send
	leave
	ret

////////////////////////////////////////////////////////////////////////////////
//                              PRIMITIVE DI IO                               //
////////////////////////////////////////////////////////////////////////////////

	.global a_readse_n
	.extern _c_readse_n
a_readse_n:
	salva_registri
	copia_param 4 7
	call _c_readse_n
	addl $16, %esp
	carica_registri
	iret

	.global a_readse_ln
	.extern _c_readse_ln
a_readse_ln:
	salva_registri
	copia_param 4 7
	call _c_readse_ln
	addl $16, %esp
	carica_registri
	iret

	.global a_writese_n
	.extern _c_writese_n
a_writese_n:
	salva_registri
	copia_param 3 7
	call _c_writese_n
	addl $12, %esp
	carica_registri
	iret

	.global a_writese_0
	.extern _c_writese_0	// non _c_writese_ln, che va lo stesso
a_writese_0:
	salva_registri
	copia_param 3 7
	call _c_writese_0
	addl $12, %esp
	carica_registri
	iret

	.global a_vkbd_read
	.extern _c_vkbd_read	
a_vkbd_read:
	salva_reg_rit
	copia_param 1 6
	call _c_vkbd_read
	addl $4, %esp
	carica_reg_rit
	iret

	.global a_vkbd_intr_enable
	.extern _c_vkbd_intr_enable
a_vkbd_intr_enable:
	salva_registri
	copia_param 2 7
	call _c_vkbd_intr_enable
	addl $8, %esp
	carica_registri
	iret

	.global a_vkbd_switch
	.extern _c_vkbd_switch
a_vkbd_switch:
	salva_registri
	copia_param 1 7
	call _c_vkbd_switch
	addl $4, %esp
	carica_registri
	iret

	.global a_vkbd_wfi
	.extern _c_vkbd_wfi
a_vkbd_wfi:
	salva_registri
	copia_param 1 7
	call _c_vkbd_wfi
	addl $4, %esp
	carica_registri
	iret

	.global a_vmon_switch
	.extern _c_vmon_switch
a_vmon_switch:
	salva_registri
	copia_param 1 7
	call _c_vmon_switch
	addl $4, %esp
	carica_registri
	iret

	.global a_vmon_write_n
	.extern _c_vmon_write_n
a_vmon_write_n:
	salva_registri
	copia_param 4 7
	call _c_vmon_write_n
	addl $16, %esp
	carica_registri
	iret

	.global a_vmon_setcursor
	.extern _c_vmon_setcursor
a_vmon_setcursor:
	salva_registri
	copia_param 2 7
	call _c_vmon_setcursor
	addl $8, %esp
	carica_registri
	iret

	.global a_vmon_getsize
	.extern _c_vmon_getsize
a_vmon_getsize:
	salva_reg_rit
	copia_param 3 6
	call _c_vmon_getsize
	addl $12, %esp
	carica_reg_rit
	iret

	.global a_vkbd_leds
	.extern _c_vkbd_leds
a_vkbd_leds:
	salva_registri
	copia_param 3 7
	call _c_vkbd_leds
	addl $12, %esp
	carica_registri
	iret

	.global a_vmon_cursorshape
	.extern _c_vmon_cursorshape
a_vmon_cursor_shape:
	salva_reg_rit
	copia_param 2 6
	call _c_vmon_cursor_shape
	addl $8, %esp
	carica_reg_rit
	iret

	.global a_vkbd_send
	.extern _c_vkbd_send
a_vkbd_send:
	salva_registri
	copia_param 3 7
	call _c_vkbd_send
	addl $12, %esp
	carica_registri
	iret
