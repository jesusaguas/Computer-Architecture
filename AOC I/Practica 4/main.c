#include <stdlib.h>			/* fichero con declaracion de funciones srand,rand */
#define M 5							/* numero de tablas a ordenar */
#define N 10						/* tamaño tabla a ordenar */

int T[N];								/* tabla de datos a ordenar */

extern
void ordena( int *tabla, int num_elem ); 	/* declara funcion externa de ordenacion */

int main() {
  int i,j,k;
	
	k=1<<30; 							/* k=2^30 */
	srand(23456); 				/* semilla numeros pseudo-aleatorios */
	
	for (i=0;i<M;i=i+1) { /* M ordenaciones a realizar*/ 
		for (j=0;j<N;j=j+1) {
			T[j]=rand()-k;		/* numeros enteros aleatorio en [-2^30,2^30-1]*/
		}
		ordena(T,N);				/* llamada a funcion de ordenacion */
	} 
	while(1);							/* bucle infinito de finalizacion */
}