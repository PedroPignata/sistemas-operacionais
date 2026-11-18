/* Dispara a chamada sysinfo no kernel que estiver em execucao. */
#include <stdio.h>
#include <stdlib.h>
#include <sys/sysinfo.h>

int main(void)
{
    struct sysinfo info;

    if (sysinfo(&info) == -1) {
        perror("sysinfo");
        return EXIT_FAILURE;
    }

    puts("Chamada sysinfo executada com sucesso.");
    printf("Tempo desde a inicializacao: %ld segundos\n", info.uptime);
    printf("RAM total: %llu bytes\n",
           (unsigned long long)info.totalram * info.mem_unit);
    printf("RAM livre: %llu bytes\n",
           (unsigned long long)info.freeram * info.mem_unit);
    printf("Quantidade de processos: %u\n", (unsigned int)info.procs);
    puts("No kernel da atividade, consulte o dmesg para localizar a resposta.");

    return EXIT_SUCCESS;
}
