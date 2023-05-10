#include <stdio.h>
#define N_MUNU 8

int subMenu(char*,int);


int main(int argc, char **argv)
{
    int isRoot = 0;
    
    if(argc >1){

        if (argv[1][0] == '2' &&
        argv[1][1] == '2' &&
        argv[1][2] == '4' &&
        argv[1][3] == '4') {
            
            isRoot = 1;
        }
        
    }else{
        isRoot=0;
    }
    
    
    char menu_list[N_MUNU][30] = 
    {
        {"Setting automobile:"}, {"Data: 15/06/2014"}, {"Ora: 15:32"}, 
        {"Blocco automatico porte:"}, {"Back-home:"}, {"Check olio"}, 
        {"Frecce direzione"}, {"Reset pressione gomme"}
    };
    
    
    
    
    
    int i_menu = 0;
    char cmd[3];
    
    int max = 0;
    
    if (isRoot)
        max = 1;
    else
        max = 3;
        
    
    int block_door = 1, back_home = 1, frecce_direzione = 3;     
    
    
    
    int loop = 1;
    while (loop) {
        printf("%d. %s \n", i_menu + 1, menu_list[i_menu]);
        
        for (int i = 0; i < 4; i++)
        {
            scanf("%c", &cmd[i]);    
        }
        
        
        if (cmd[2] == 'B') {
            if (i_menu < (N_MUNU-max)) {
                i_menu++;
            }
            else {
                i_menu = 0;
            }
        }

        else if (cmd[2] == 'A') {
            if (i_menu > 0) {
                i_menu--;
            }else{
                i_menu = N_MUNU-max;
            }
        }
            
        // sub menu
        else if (cmd[2] == 'C') {
            
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
            
            
            
        cmd[2] = ' '; 
    }
    
}

int subMenu(char* menu_list, int value) {
    char cmd[3];
    
    while (1) {
        if (value)
            printf("%s ON \n", menu_list);
        else
            printf("%s OFF \n", menu_list);
            
            

        for (int i = 0; i < 3; i++)
        {
            scanf("%c", &cmd[i]);
            
            if (cmd[0]=='\n')
            {
                printf("Enter detect");
                break;
            }
            

        }

        if (cmd[0]=='\n' && cmd[2] == 0)
        {
            
            printf("sono qu@\n");
            return value;
        }

        
        if (cmd[2] == 'B') {
            if (value)
                value = 0;
            else
                value = 1;
            
            cmd[2] = 99;
        }
        else if (cmd[2] == 'A') {
            if (value)
                value = 0;
            else
                value = 1;
                
            cmd[2] = 99;
        }
        else {
            cmd[2] = 0;
        }
        
        
        
        /*else {
            return value;
        }*/
        
        
        cmd[0] = 0; 
        cmd[1] = 0;
        cmd[3] = 0;
    }
}