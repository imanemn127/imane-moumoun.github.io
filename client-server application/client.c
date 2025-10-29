#include "pse.h"

int sock;

void *reception(void *arg);

int main(int argc, char *argv[]) {
  struct sockaddr_in *adrServ;
  int fin = FAUX;
  char ligne[LIGNE_MAX];
  int lgEcr, lgLue;
  pthread_t thread_id;

  signal(SIGPIPE, SIG_IGN);

  if (argc != 4)
    erreur("usage: %s machine port username\n", argv[0]);

  char *identifiant = argv[3];

  sock = socket(AF_INET, SOCK_STREAM, 0);
  if (sock < 0)
    erreur_IO("socket");

  adrServ = resolv(argv[1], argv[2]);
  if (adrServ == NULL)
    erreur("adresse %s port %s inconnus\n", argv[1], argv[2]);

  if (connect(sock, (struct sockaddr *)adrServ, sizeof(struct sockaddr_in)) < 0)
    erreur_IO("connect");

  lgEcr = ecrireLigne(sock, identifiant);
  if (lgEcr == -1)
    erreur_IO("ecriture identifiant");

  lgLue = lireLigne(sock, ligne);
  if (lgLue > 0 && strncmp(ligne, "Identifiant déjà utilisé", 24) == 0) {
    printf("Erreur: %s\n", ligne);
    close(sock);
    return EXIT_FAILURE;
  }

  printf("[INFO] Connecté avec succès en tant que %s", identifiant);
  printf("Commandes disponibles :\n"
         "  /vote question               → lancer un vote\n"
         "  /OUI | /NON                  → voter\n"
         "  /endvote                     → terminer le vote (créateur)\n"
         "  /online                      → afficher les utilisateurs en ligne\n"
         "  /public message              → message à tout le monde\n"
         "  /private nom message         → message privé\n"
         "  /fin                         → quitter\n\n");

  pthread_create(&thread_id, NULL, reception, NULL);

  while (!fin) {
    if (fgets(ligne, LIGNE_MAX, stdin) == NULL)
      break;

    lgEcr = ecrireLigne(sock, ligne);
    if (lgEcr == -1)
      erreur_IO("ecriture ligne");

    if (strcmp(ligne, "/fin\n") == 0)
      fin = VRAI;
  }

  if (close(sock) == -1)
    erreur_IO("fermeture socket");

  exit(EXIT_SUCCESS);
}

void *reception(void *arg) {
  char ligne[LIGNE_MAX];
  while (1) {
    int lg = lireLigne(sock, ligne);
    if (lg <= 0) {
      printf("[DECONNEXION] Serveur fermé.\n");
      exit(EXIT_FAILURE);
    }
    printf("%s\n", ligne);
    fflush(stdout);
  }
  return NULL;
}
