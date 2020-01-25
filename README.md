# Tema-PP
													 Tema PP
												- H a s k e l l -
																		-- Lungu-Stan Vlad-Constantin 324CB
																		
	a. Pentru containerul de clasa am folosit Map-ul din Haskell, asa cum ne-a fost indicat:
		- initEmptyClass -> initializeaza un ClassState cu un Map gol
		- insertIntoClass -> insereaza in Map-ul din ClssState o instructiune care contine tipul necesar si
		  informatiile asociate. Variabilele sunt identificate dupa [nume,tip], iar functiile dupa nume:parametrii
		- getValues -> intoarce lista de informatii pentru fie variabile, fie functii, interogand Map-ul
	
	b. Pentru a rezolva puntul b am facut un TDA pentru clasa, care contine numele clasei, numele parintelui clasei.
	   Pentru acest TDA am functii care extrag datele din el, cat si un soi de Wrapper care insereaza in ClassState-ul
	   clasei vizate instructiunea aferenta.
	   Programul este definit ca un Map de Class-uri, unde fiecare class e identificat prin nume.
	   
	   Pentru parsare am mai multe functii ajutatoare:
	   ->elimDuplicateWhites: care elimina spatiile albe duplicate dintr-un string
	   ->elimWhites: care elimina toate spatiile albe dintr-un sir
	   ->elimFirstWhites: care elimina toate spatiile albe de la inceputul unui string
	   ->first_word: care extrage primul cuvant pana la tokenurile care se intalnesc in program (' '  : ( = . )
	     ( probabil era mai bine sa dau ca parametru si tokenul dorit, dar asa am gandit prima data, si n-am mai modificat dupa)
	   ->rest_word: care extrage restul sirului dupa un first_word
	   ->split_lines: care primeste un fisier, si extrage liniile, punandu-le intr-o lista de siruri
	   ->parseClass: o functie care primeste un string care stiu ca reprezinta informatiile pentru 
	     crearea unei noi clase si genereaza instructiunea aferenta Informatiile unei clase sunt numele si parintele(default, Global)
	   ->parseVar: face acelasi lucru, dar pentru Variabile. Informatii unei variabile sunt numele si tipul
	   ->parseFunc: la fel, dar pentru functii. Informatiile sunt clasa, numele, tipul returnat si parametrii
	     Parametrii sunt obtinuti prin functia get_params, care primeste un string si intaorce o lista de stringuri, lista parametrilor
	   ->parseInfer: la fel, dar pentru inferente. Informatiile necesare sunt numele noii variabile si stringul care reprezinta expresia de 
	     interpretat
	   ->parse_chooser: primeste un string si determina tipul de instructiune pe care il reprezinta. Apeleaza, apoi, functia de parsare
	     potrivita pentru a transforma stringul in instructiune. Functiile parse*** primesc doar informatiile necesare pentru crearea
		 instructiunii
	   
	    In sfarsit, functia parse. Aceasta primeste un str, tot programul. Prima data elimina spatiile albe duplicate, dupa care imparte
	    programul in linii(in cazul nostru, instructiuni). Pe lista de siruri apeleaza cu foldr parse_chooser, obtinand lista de instructiuni
	    rezultata din parsarea fisierului.
		
		  Pentru functia interpret am o functie ajutatoare care verifica daca argumentele functiei sunt valide.
		  In cazul in care instructiunea este pentru introducerea unei clase, verific daca parintele este printre
		clasele din program. Daca este, inserez noua clasa in program cu parintele specificat, altfel pun parintele
		"Global".
		  In cazul unei variabile, verific daca variabila are un tip valid. Daca este valid, il introduc in clasa "Global"(pentru ca asa trebuie,
		aparent). Daca nu, las programul asa cum e.
		  In cazul functiilor verific daca returneaza un tip de data corect, daca sunt introduse intr-o clasa existenta si daca parametrii sunt
		valizi. Daca toate cele de mai sus sunt satisfacute, inserez functia in clasa specificata. Daca nu, programul ramane la fel
		
	c. Pentru realizarea inferarii folosesc mai multe functii ajutatoare:
		-> gaseste, care cauta in variabilele programului o variabila anume. daca o gaseste, intoarce Just tipul ei, daca nu intoarce Nothing.
		-> check_params, care verifica daca vreun membru al listei de parametrii a apelului unei functii este Nothing, dupa rezolvarea expresiilor 
           resprective
        -> member_func, verifica daca o functie data se gaseste printre functiile unei clase. Daca se gaseste, intoarce tipul returnat, sau Nothing
		   in cazul in care nu se gaseste
		-> find_func, incearca sa gaseasca o functie in program. Daca se gaseste, intoarce tipul returnat, daca nu intoarce Nothing
		
		Functia de inferare: Daca primeste la inferat o variabila, o cauta in program si intoarce tipul ei, sau Nothing in caz ca nu se gaseste.
		Daca primeste o functie, verifica daca variabila din care e chemata exista. Daca nu exista, intoarce imediat Nothing. Daca exista, verifica
	daca parametrii functiei sunt valizi. Daca sunt valizi, din nou, intoarce Nothing.( Verific mai intai parametrii, pentru ca pot fi la randul lor
	expresii de inferat. Daca doar una din ele nu este valida, totul va fi nevalid. In plus, pentru a verifica existenta unei functii, am nevoie de 
    lista cu tipurile parametrilor). Daca si parametrii sunt in regula, caut functia in program cu ajutorul functiei find_func. Aceasta intoarce tipul
	returnat daca se gaseste, sau Nothing daca nu se afla in program. 
	
	Bonus. Pentru bonus am introdus in logica programului instructiunea Infer si am explicat mai sus cum fac asta. In plus am realizat parsarea unei 
	expresii. 
	
	Parsarea o fac asta cu mai multe functii: 
	->isPoint verifica daca undeva in expresie se afla un punct. Daca este, inseamna ca expresia respectiva reprezinta un apel de functie.
	->getBetweenCommas primeste parametrii apelului unei functii si un int si intoarce primul string care reprezinta o subinstructiune(fie variabila, fie 
	  alt apel de functie. Int-ul, initial 0, il folosesc pentru cazul in care subexpresia contine alt apel de functie. Daca dau de '(', inseamna ca am un
	  apel de functie in apelul de functie, si incrementez int-ul cu 1. la gasirea unui ')' il decrementez. Daca dau de o , dar int-ul e diferit de 0, inseamna
	  ca am o virgula intr-un apel de functie interior. Daca e 0, inseamna ca am ajuns la virgula care desparte argumentele apelului curent de functie. 
	->afterComma, se foloseste de un procedeu similar celui de mai sus, dar intoarce sirul format de restul argumentelelor, cele de dupa cel extras cu ajutorul
	  functie getBetweenCommas
	->getParamsInfer, primeste stringul reprezentat de argumentele apelului curent de functie si extrage subexpresiile
	parseExpr primeste un sir si intoarce Expr-esia aferenta sirului respectiv. Daca nu gasesc un punct in expresie, inseamna ca am de a face cu o variabila,
	caz in care intorc direct Va s. Daca este apel de functie, extrag numele variabilei si numele functiei de apelat, parsez argumentele si aplic recursiv functia 
	pentru fiecare argument in parte. 
	
	Intructiunea Infer se interpreteaza foarte usor. Prima data aplic functia infer expresiei obtinute prin parsarea stringului dat ca parametru. Daca imi este intors 
	un tip valid, introduc in clasa global noua variabila cu numele dat si cu tipul dat de rezultatul expresiei. Daca nu, programul ramane nemodificat.
