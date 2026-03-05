#include <stdio.h>
#include <stdlib.h>

extern int sum_array(int *arr, long n);

int main(int argc, char *argv[]){
    if (argc != 2){
        printf("Usage: %s <datafile>\n", argv[0]);
        return 1;
    }

    FILE *fp = fopen(argv[1], "r");
    if (fp == NULL){
        perror("Error opening file");
        return 1;
    }
    long n;
    if (fscanf(fp, "%ld", &n) != 1 || n <= 0){
        printf("Incorect file format (missing/invalid count)\n");
        fclose(fp);
        return 1;
    }

    int *arr = malloc(n * sizeof(int));
    if (arr == NULL){
        perror("Memory allocation failed");
        fclose(fp);
        return 1;
    }

    for (long i = 0; i < n; i++){
        if (fscanf(fp, "%d", &arr[i]) != 1){
            printf("Incorrect file format (missing array elements)\n");
            free(arr);
            fclose(fp);
            return 1;
        }
    }

    fclose (fp);

    int result = sum_array(arr, n);
    printf("Sum: %d\n", result);

    free(arr);
    return 0;
}
