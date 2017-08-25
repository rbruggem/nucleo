#include <sys.h>
#include <lib.h>


extern short int in1;
extern short int in2;
extern short int es1;
extern short int controllore;



struct Informazione {
	int a;
};

struct elem {
	Informazione inf;
	elem* pun;
};

class Coda: public Object {
	int num;
	elem* testa;
	elem* fondo;

	public:
	Coda () : Object() {testa = fondo = 0; num = 0;}
	void inscoda (Informazione);
	Informazione estcoda();
	void stampacoda(int);
};
		
void Coda::inscoda(Informazione og){
	synchronized_begin();
	while (num == 10) wait();
	elem* p = (elem*)mem_alloc(sizeof(elem));
	num++;
	p->inf = og;
	p->pun = 0;
	if (testa == 0) {testa=p; fondo=p;}
	else {fondo->pun = p; fondo = p;}
	notifyall();
	synchronized_end();
}

Informazione Coda::estcoda() {
	synchronized_begin();
	Informazione og;
	while (num == 0) wait();
	og = testa->inf;
	testa=testa->pun;
	num--;
	if (testa == 0) fondo=0;
	notifyall();
	synchronized_end();
	return og;
}

void Coda::stampacoda(int terminale){
	synchronized_begin();
	printf(terminale, "Numero elementi: %d\n", num);
	elem* p = testa;
	for (int i=0; i<num; i++){
		printf(terminale, "Coda elemento %d: %d\n", i+1, p->inf.a);
		p = p-> pun;
	}
	synchronized_end();
}


int n=1;
int conta=1;
Coda q;
void inserisci(int a)
{
	printf(a, "proc=%d\n", getid());
	Informazione og;
	while(!isinterrupted()) {
		og.a=n++;
		q.inscoda(og);
		printf(a, "%d Inserimento %d\n", conta++, og.a);
		delay(60);
	}
	printf(a, "Fine\n");

	terminate_p();
}
void estrai(int a)
{
	printf(a, "proc=%d\n", getid());
	Informazione og;
	while(!isinterrupted()) {
		og=q.estcoda();
		printf(a, "%d Estratto: %d\n", conta++, og.a);
		delay(60);
	}
	printf(a, "Fine\n");

	terminate_p();
}
void controlla(int a)
{
	char c;
	printf(a, "proc=%d\n", getid());
	delay(300);
	interrupt(in1);
	interrupt(es1);
	q.stampacoda(a);
	printf(a,"Premi un tasto per interrompere\n");
	readvterm_ln(a, &c, 1);
	interrupt(in2);
	q.stampacoda(a);
	printf(a, "Fine\n");

	terminate_p();
}
#include <sys.h>
#include <lib.h>
#include <colors.h>

log_msg __logger_buf;
log_msg __logger_msg;

char *__logger_sev_names[] = { "DBG", "INF", "WRN", "ERR" };
int __logger_sev_fgcol[]  = { COL_BLUE, COL_GREEN, COL_RED, COL_BLACK };
int __logger_sev_bgcol[]  = { COL_BLACK, COL_BLACK, COL_BLACK, COL_RED };

enum __logger_cmd_types { NEW_MSG, QUIT } __logger_cmd;

extern int __logger_non_busy;
extern int __logger_new_cmd;
extern int __logger_mutex;
void __logger_send_cmd(__logger_cmd_types cmd)
{
	sem_wait(__logger_mutex);
	sem_wait(__logger_non_busy);
	__logger_cmd = cmd;
	__logger_msg = __logger_buf;
	sem_signal(__logger_new_cmd);
	sem_signal(__logger_mutex);
}

__logger_cmd_types __logger_recv_cmd(log_msg& msg)
{
	__logger_cmd_types work;
	sem_wait(__logger_new_cmd);
	work = __logger_cmd;
	msg = __logger_msg;
	sem_signal(__logger_non_busy);
	return work;
}

bool __logger_quit = false;

void __logger_main(int a)
{
	__logger_cmd_types my_cmd;
	log_msg my_msg;

	if (!vterm_setresident(a)) {
		flog(LOG_WARN, "log di sistema non residente");
	}

	while (!__logger_quit) {
		my_cmd = __logger_recv_cmd(my_msg);
		switch (my_cmd) {
		case NEW_MSG:
			vterm_setcolor(a, __logger_sev_fgcol[my_msg.sev],
					  __logger_sev_bgcol[my_msg.sev]);
			printf(a, "%s %d\t%s\n", __logger_sev_names[my_msg.sev],
						 my_msg.identifier,
						 my_msg.msg);
			break;
		default:
			break;
		}
	}
	printf(a, "*** logger (main) terminato ***\n");

	terminate_p();
}
void __logger_reader(int a)
{

	if (resident(&__logger_buf, sizeof(__logger_buf)) < sizeof(__logger_buf))
		goto out;

	while (!__logger_quit) {
		readlog(__logger_buf);
		if (!__logger_quit) {
			__logger_send_cmd(NEW_MSG);
		}
	}

out:
	printf(a, "*** logger (reader) terminato ***\n");

	terminate_p();
}
char __logger_ctrl_buf;

void __logger_ctrl(int a)
{
	
	for (;;) {
		readvterm_n(a, &__logger_ctrl_buf, 1, VTERM_NOECHO);
		switch (__logger_ctrl_buf) {
		case 'Q':
			vterm_shutdown();
			delay(5);
			__logger_quit = true;
			__logger_send_cmd(QUIT);
			*(int *)0 = 1;
			break;
		default:
			break;
		}
	}

	terminate_p();
}
#include <sys.h>
#include <lib.h>

extern int sync;
extern int sync2;
extern short sonno1;
extern short sonno2;
extern short sonno3;

void pint(int a)
{
	printf(a, "proc=%d\n", getid());
	printf(a, "INTERRUTTORE\n");
	interrupt(sonno3);
	printf(a,"Interrotto processo %d\n", sonno3);
	sem_signal(sync);

	sem_wait(sync2);
	delay(120);
	interrupt(sonno2);
	printf(a,"Interrotto processo %d\n", sonno2);

	delay(100);
	interrupt(sonno1);
	printf(a,"Interrotto processo %d\n", sonno1);
	printf(a, "Fine\n");

	terminate_p();
}
void ps1(int a)
{
	printf(a, "proc=%d\n", getid());
	printf(a, "Se interrotto termina,\n");
	printf(a, "altrimenti prosegue altri 2.5 secondi\n");
	while (!isinterrupted())
	{
		printf(a, "Delay 2.5 sec\n");
		delay(50);
	}
	printf(a, "Fine\n");

	terminate_p();
}
void ps2(int a)
{
	printf(a, "proc=%d\n", getid());
	printf(a, "Interrotto durante il sonno\n");
	printf(a, "Sleep 10 sec\n");
	sem_signal(sync2);
	sleep(10000);
	printf(a, "Fine\n");

	terminate_p();
}
void ps3(int a)
{
	printf(a, "proc=%d\n", getid());
	printf(a, "Interrotto prima del sonno\n");
	sem_wait(sync);
	if (isinterrupted())
		printf(a, "Sono stato interrotto prima del sonno\n");
	else
		printf(a, "Non sono stato interrotto prrima del sonno\n");
	sleep(60000);
	printf(a, "Fine\n");

	terminate_p();
}
short controllore;
short in1;
short in2;
short es1;
short __logger_p0;
short __logger_p1;
short __logger_p2;
int __logger_non_busy;
int __logger_new_cmd;
int __logger_mutex;
short interruttore;
short sonno1;
short sonno2;
short sonno3;
int sync;
int sync2;

int main()
{
	controllore = activate_p(controlla, 5, 10, LIV_UTENTE);
	in1 = activate_p(inserisci, 6, 10, LIV_UTENTE);
	in2 = activate_p(inserisci, 7, 10, LIV_UTENTE);
	es1 = activate_p(estrai, 8, 10, LIV_UTENTE);
	q.sem();
	__logger_p0 = activate_p(__logger_main, 0, 201, LIV_UTENTE);
	__logger_p1 = activate_p(__logger_reader, 0, 200, LIV_UTENTE);
	__logger_p2 = activate_p(__logger_ctrl, 0, 200, LIV_UTENTE);
	__logger_non_busy = sem_ini(1);
	__logger_new_cmd = sem_ini(0);
	__logger_mutex = sem_ini(1);
	interruttore = activate_p(pint, 1, 5, LIV_UTENTE);
	sonno1 = activate_p(ps1, 2, 10, LIV_UTENTE);
	sonno2 = activate_p(ps2, 3, 10, LIV_UTENTE);
	sonno3 = activate_p(ps3, 4, 10, LIV_UTENTE);
	sync = sem_ini(0);
	sync2 = sem_ini(0);
	lib_init();

	terminate_p();
}

extern"C" void __main()
{
}
