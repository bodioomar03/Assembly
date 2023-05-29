#include <stdio.h>
#define N_MUNU 8

// Funzione per determinare il tipo di input
int subMenu(char* menu_list, int value) {
    getchar(); //Consuma i caratteri nel buffer del main
    
    char carattere;
    
    while (1) {
        if (value)
            printf("%s ON \n", menu_list);
        else
            printf("%s OFF \n", menu_list);
        
        
        scanf("%c", &carattere);
        
        if (carattere == '\n') {
            return value; // Esce dal ciclo while
            
        } else if (carattere == '\033') {
            // Leggi il carattere successivo per determinare il tipo di freccia
            getchar(); // Ignora il carattere '['
            char freccia = getchar();
    
            if (freccia == 'A') {
                if (value)
                    value = 0;
                else
                    value = 1;
            } else if (freccia == 'B') {
                if (value)
                    value = 0;
                else
                    value = 1;
            }
        }

        getchar(); // Consuma il carattere di newline residuo nel buffer
    }
}



int main(int argc, char **argv)
{
    int i_menu = 0;
    int max = 0;
    int isRoot = 0;
    int block_door = 1, back_home = 1, frecce_direzione = 3;
    char carattere;
    
    if(argc > 1){

        if (argv[1][0] == '2' &&
        argv[1][1] == '2' &&
        argv[1][2] == '4' &&
        argv[1][3] == '4') {
            
            isRoot = 1;
            max = 1;
        }
        
    }else{
        isRoot=0;
        max=0;
    }
    
    
    char menu_list[N_MUNU][30] = 
    {
        {"Setting automobile:"}, {"Data: 15/06/2014"}, {"Ora: 15:32"}, 
        {"Blocco automatico porte:"}, {"Back-home:"}, {"Check olio"}, 
        {"Frecce direzione"}, {"Reset pressione gomme"}
    };
    while (1) {
        printf("%d. %s \n", i_menu + 1, menu_list[i_menu]);
        
        scanf(" %c", &carattere);
        
        if (carattere == '\033') {
            // Leggi il carattere successivo per determinare il tipo di freccia
            getchar(); // Ignora il carattere '['
            char freccia = getchar();
    
            if (freccia == 'A') {
                if (i_menu > 0) {
                    i_menu--;
                }else{
                    i_menu = N_MUNU-max;
                }
            } else if (freccia == 'B') {
                if (i_menu < (N_MUNU-max)) {
                    i_menu++;
                }
                else {
                    i_menu = 0;
                }
            }
            else if (freccia == 'C') {
                if (i_menu+1 == 4)
                    block_door = subMenu(menu_list[i_menu], block_door);
                
                else if (i_menu+1 == 5)
                    back_home = subMenu(menu_list[i_menu], back_home);
                    
                    
                    
                if (isRoot) {
                    if (i_menu+1 == 7) {
                        printf("%s %d \n", menu_list[i_menu], frecce_direzione);
                        
                        scanf("%d", &frecce_direzione);
                        
                        if (frecce_direzione < 2) {
                            frecce_direzione = 2;
                        }
                        else if (frecce_direzione > 5) {
                            frecce_direzione = 5;
                        }
                    }
                    else if (i_menu+1 == 8) {
                        printf("Pressione gomme resettata \n");
                    }
                }
            }
        }
    }
}
