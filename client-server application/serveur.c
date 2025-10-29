// serveur.c
#include "pse.h"

#define NOM_JOURNAL   "journal.log"
#define MAX_CLIENTS   100

typedef struct {
  int canal;
} DATA_THREAD;

void *threadSessionClient(void *arg);
void sessionClient(int canal);
int ecrireJournal(char *ligne);
void remiseAZeroJournal(void);

int ajouter_identifiant(const char *id);
int supprimer_identifiant(const char *id);
void listeOnline(int canal);
void envoyerMessagePublic(const char *expediteur, const char *message);
int envoyerMessagePrive(const char *expediteur, const char *destinataire, const char *message, int canal_src);
void resultatVote(void);

int fdJournal;
pthread_mutex_t mutexJournal = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t mutexIdentifiants = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t mutexVote = PTHREAD_MUTEX_INITIALIZER;

char *identifiants[MAX_CLIENTS];
int canaux_clients[MAX_CLIENTS];

char vote_question[LIGNE_MAX] = "";
char vote_createur[LIGNE_MAX] = "";
int vote_oui = 0;
int vote_non = 0;
int vote_en_cours = 0;
int deja_vote[MAX_CLIENTS] = {0};

int main(int argc, char *argv[]) {
  short port;
  int ecoute, canal, ret;
  struct sockaddr_in adrEcoute, adrClient;
  unsigned int lgAdrClient;
  pthread_t idThread;
  DATA_THREAD *dataThread;

  for (int i = 0; i < MAX_CLIENTS; i++) {
    identifiants[i] = NULL;
    canaux_clients[i] = -1;
  }

  fdJournal = open(NOM_JOURNAL, O_CREAT|O_WRONLY|O_APPEND, 0600);
  if (fdJournal == -1)
    erreur_IO("ouverture journal");
  remiseAZeroJournal();

  if (argc != 2)
    erreur("usage: %s port\n", argv[0]);

  port = (short)atoi(argv[1]);

  ecoute = socket(AF_INET, SOCK_STREAM, 0);
  if (ecoute < 0)
    erreur_IO("socket");

  adrEcoute.sin_family = AF_INET;
  adrEcoute.sin_addr.s_addr = INADDR_ANY;
  adrEcoute.sin_port = htons(port);
  ret = bind(ecoute, (struct sockaddr *)&adrEcoute, sizeof(adrEcoute));
  if (ret < 0)
    erreur_IO("bind");

  ret = listen(ecoute, 5);
  if (ret < 0)
    erreur_IO("listen");

  while (VRAI) {
    printf("Serveur. attente connexion\n");
    lgAdrClient = sizeof(adrClient);
    canal = accept(ecoute, (struct sockaddr *)&adrClient, &lgAdrClient);
    if (canal < 0)
      erreur_IO("accept");

    printf("Serveur. connexion recue : client adr %s, port %hu\n",
           stringIP(ntohl(adrClient.sin_addr.s_addr)),
           ntohs(adrClient.sin_port));

    dataThread = malloc(sizeof(DATA_THREAD));
    dataThread->canal = canal;
    ret = pthread_create(&idThread, NULL, threadSessionClient, dataThread);
    if (ret != 0)
      erreur_IO("creation thread");
  }

  if (close(ecoute) == -1)
    erreur_IO("fermeture socket ecoute");

  if (close(fdJournal) == -1)
    erreur_IO("fermeture journal");

  exit(EXIT_SUCCESS);
}

void *threadSessionClient(void *arg) {
  DATA_THREAD *dataThread = (DATA_THREAD *)arg;
  sessionClient(dataThread->canal);
  free(dataThread);
  pthread_exit(NULL);
}

void sessionClient(int canal) {
  int fin = FAUX;
  char ligne[LIGNE_MAX];
  char identifiant[LIGNE_MAX];
  int lgLue;

  lgLue = lireLigne(canal, identifiant);
  if (lgLue <= 0) {
    close(canal);
    return;
  }
  identifiant[strcspn(identifiant, "\n")] = '\0';

  if (!ajouter_identifiant(identifiant)) {
    ecrireLigne(canal, "Identifiant déjà utilisé.\n");
    close(canal);
    return;
  }

  pthread_mutex_lock(&mutexIdentifiants);
  for (int i = 0; i < MAX_CLIENTS; i++) {
    if (identifiants[i] && strcmp(identifiants[i], identifiant) == 0) {
      canaux_clients[i] = canal;
      break;
    }
  }
  pthread_mutex_unlock(&mutexIdentifiants);

  ecrireLigne(canal, "Identifiant connecté.\n");
  char log_connexion[LIGNE_MAX * 3];
  snprintf(log_connexion, sizeof(log_connexion), "utilisateur %s s'est connecté\n", identifiant);
  ecrireJournal(log_connexion);

  while (!fin) {
    lgLue = lireLigne(canal, ligne);
    if (lgLue == -1)
      erreur_IO("lecture ligne");

    ligne[strcspn(ligne, "\n")] = '\0';

    if (lgLue == 0 || strcmp(ligne, "/fin") == 0) {
      fin = VRAI;
    } else if (strcmp(ligne, "/online") == 0) {
      listeOnline(canal);
    } else if (strncmp(ligne, "/public ", 8) == 0) {
      envoyerMessagePublic(identifiant, ligne + 8);
      char log_pub[LIGNE_MAX * 2];
      snprintf(log_pub, sizeof(log_pub), "Utilisateur %s a envoyé un message public : %s\n", identifiant, ligne + 8);
      ecrireJournal(log_pub);
    } else if (strncmp(ligne, "/private ", 9) == 0) {
      char *dest = ligne + 9;
      char *msg = strchr(dest, ' ');
      if (msg) {
        *msg = '\0';
        msg++;
        if (!envoyerMessagePrive(identifiant, dest, msg, canal)) {
          char erreur_msg[LIGNE_MAX];
          snprintf(erreur_msg, sizeof(erreur_msg), "Utilisateur '%s' introuvable ou non connecté.\n", dest);
          ecrireLigne(canal, erreur_msg);
        } else {
          char log_priv[LIGNE_MAX * 2];
          snprintf(log_priv, sizeof(log_priv), "Utilisateur %s a envoyé un message privé à utilisateur %s : %s\n", identifiant, dest, msg);
          ecrireJournal(log_priv);
        }
      } else {
        ecrireLigne(canal, "Usage: /private identifiant message\n");
      }
    } else if (strncmp(ligne, "/vote ", 6) == 0) {
      pthread_mutex_lock(&mutexVote);
      if (vote_en_cours) {
        ecrireLigne(canal, "[ERREUR] Un vote est déjà en cours.\n");
      } else {
        strncpy(vote_question, ligne + 6, LIGNE_MAX - 1);
        strncpy(vote_createur, identifiant, LIGNE_MAX - 1);
        vote_oui = 0;
        vote_non = 0;
        vote_en_cours = 1;
        for (int i = 0; i < MAX_CLIENTS; i++) deja_vote[i] = 0;
        resultatVote();
        char log_vote[LIGNE_MAX * 3];
        snprintf(log_vote, sizeof(log_vote), "Utilisateur %s a lancé un vote : %s\n", identifiant, vote_question);
        ecrireJournal(log_vote);
      }
      pthread_mutex_unlock(&mutexVote);
    } else if (strncmp(ligne, "/OUI", 4) == 0 || strncmp(ligne, "/NON", 4) == 0) {
      pthread_mutex_lock(&mutexVote);
      if (!vote_en_cours) {
        ecrireLigne(canal, "[ERREUR] Aucun vote en cours.\n");
      } else {
        int trouve = 0;
        for (int i = 0; i < MAX_CLIENTS; i++) {
          if (identifiants[i] && strcmp(identifiants[i], identifiant) == 0) {
            if (deja_vote[i]) {
              ecrireLigne(canal, "[ERREUR] Vous avez déjà voté.\n");
            } else {
              deja_vote[i] = 1;
              if (strncmp(ligne, "/OUI", 4) == 0) vote_oui++;
              else vote_non++;
              resultatVote();
              char log_vote[LIGNE_MAX * 5];
              snprintf(log_vote, sizeof(log_vote), "Utilisateur %s a voté %s\n", identifiant, strncmp(ligne, "/OUI", 4) == 0 ? "OUI" : "NON");
              ecrireJournal(log_vote);
            }
            trouve = 1;
            break;
          }
        }
        if (!trouve) ecrireLigne(canal, "[ERREUR] Identifiant non reconnu.\n");
      }
      pthread_mutex_unlock(&mutexVote);
    } else if (strcmp(ligne, "/endvote") == 0) {
      pthread_mutex_lock(&mutexVote);
      if (!vote_en_cours) {
        ecrireLigne(canal, "[ERREUR] Aucun vote en cours.\n");
      } else if (strcmp(identifiant, vote_createur) != 0) {
        ecrireLigne(canal, "[ERREUR] Seul l'initiateur peut terminer le vote.\n");
      } else {
        char resultat[LIGNE_MAX*5];
        snprintf(resultat, sizeof(resultat),
                 "[VOTE TERMINÉ] %s (OUI: %d, NON: %d)\n", vote_question, vote_oui, vote_non);
        vote_en_cours = 0;
        envoyerMessagePublic("Serveur", resultat);
        char log_fin_vote[LIGNE_MAX * 2];
        snprintf(log_fin_vote, sizeof(log_fin_vote), "Le vote \"%s\" est terminé, Le résutlat : OUI=%d, NON=%d\n", vote_question, vote_oui, vote_non);
        ecrireJournal(log_fin_vote);
        vote_question[0] = '\0';
        vote_createur[0] = '\0';
      }
      pthread_mutex_unlock(&mutexVote);
    }
  }

  supprimer_identifiant(identifiant);
  pthread_mutex_lock(&mutexIdentifiants);
  for (int i = 0; i < MAX_CLIENTS; i++) {
    if (canaux_clients[i] == canal) {
      canaux_clients[i] = -1;
      break;
    }
  }
  pthread_mutex_unlock(&mutexIdentifiants);

  char log_deconnexion[LIGNE_MAX * 3];
  snprintf(log_deconnexion, sizeof(log_deconnexion), "Utilisateur %s s'est déconnecté\n", identifiant);
  ecrireJournal(log_deconnexion);

  if (close(canal) == -1)
    erreur_IO("fermeture canal");
}

int ecrireJournal(char *ligne) {
  int lg;
  pthread_mutex_lock(&mutexJournal);
  lg = ecrireLigne(fdJournal, ligne);
  pthread_mutex_unlock(&mutexJournal);
  return lg;
}

void remiseAZeroJournal(void) {
  pthread_mutex_lock(&mutexJournal);
  if (close(fdJournal) == -1)
    erreur_IO("fermeture journal pour remise a zero");

  fdJournal = open(NOM_JOURNAL, O_TRUNC|O_WRONLY|O_APPEND, 0600);
  if (fdJournal == -1)
    erreur_IO("ouverture journal pour remise a zero");
  pthread_mutex_unlock(&mutexJournal);
}

int ajouter_identifiant(const char *id) {
  pthread_mutex_lock(&mutexIdentifiants);
  for (int i = 0; i < MAX_CLIENTS; i++) {
    if (identifiants[i] && strcmp(identifiants[i], id) == 0) {
      pthread_mutex_unlock(&mutexIdentifiants);
      return 0;
    }
  }
  for (int i = 0; i < MAX_CLIENTS; i++) {
    if (identifiants[i] == NULL) {
      identifiants[i] = strdup(id);
      pthread_mutex_unlock(&mutexIdentifiants);
      return 1;
    }
  }
  pthread_mutex_unlock(&mutexIdentifiants);
  return 0;
}

int supprimer_identifiant(const char *id) {
  pthread_mutex_lock(&mutexIdentifiants);
  for (int i = 0; i < MAX_CLIENTS; i++) {
    if (identifiants[i] != NULL && strcmp(identifiants[i], id) == 0) {
      free(identifiants[i]);
      identifiants[i] = NULL;
      pthread_mutex_unlock(&mutexIdentifiants);
      return 1;
    }
  }
  pthread_mutex_unlock(&mutexIdentifiants);
  return 0;
}

void listeOnline(int canal) {
  char ligne[LIGNE_MAX];
  snprintf(ligne, sizeof(ligne), "[ONLINE] Liste utilisateurs en ligne: ");
  ecrireLigne(canal, ligne);
  
  pthread_mutex_lock(&mutexIdentifiants);
  for (int i = 0; i < MAX_CLIENTS; i++) {
    if (identifiants[i] != NULL) {
      snprintf(ligne, sizeof(ligne), " %d) %s\n", i+1, identifiants[i]);
      ecrireLigne(canal, ligne);
    }
  }
  pthread_mutex_unlock(&mutexIdentifiants);
}

void envoyerMessagePublic(const char *expediteur, const char *message) {
  char buffer[LIGNE_MAX * 3];
  snprintf(buffer, sizeof(buffer), "[PUBLIC] %s: %s\n", expediteur, message);

  pthread_mutex_lock(&mutexIdentifiants);
  for (int i = 0; i < MAX_CLIENTS; i++) {
    if (canaux_clients[i] != -1 && identifiants[i] != NULL) {
      ecrireLigne(canaux_clients[i], buffer);
    }
  }
  pthread_mutex_unlock(&mutexIdentifiants);
}

int envoyerMessagePrive(const char *expediteur, const char *destinataire, const char *message, int canal_src) {
  char ligne[LIGNE_MAX * 5];
  snprintf(ligne, sizeof(ligne), "[PRIVATE] %s → %s: %s\n", expediteur, destinataire, message);

  pthread_mutex_lock(&mutexIdentifiants);
  for (int i = 0; i < MAX_CLIENTS; i++) {
    if (identifiants[i] && strcmp(identifiants[i], destinataire) == 0 && canaux_clients[i] != -1) {
      ecrireLigne(canaux_clients[i], ligne);
      pthread_mutex_unlock(&mutexIdentifiants);
      char confirmation[LIGNE_MAX];
      snprintf(confirmation, sizeof(confirmation), "Message privé envoyé à %s.\n", destinataire);
      ecrireLigne(canal_src, confirmation);
      return 1;
    }
  }
  pthread_mutex_unlock(&mutexIdentifiants);
  return 0;
}

void resultatVote(void) {
  char ligne[LIGNE_MAX * 5];
  snprintf(ligne, sizeof(ligne),
           "[VOTE] %s (OUI: %d, NON: %d)\n", vote_question, vote_oui, vote_non);

  pthread_mutex_lock(&mutexIdentifiants);
  for (int i = 0; i < MAX_CLIENTS; i++) {
    if (canaux_clients[i] != -1 && identifiants[i] != NULL) {
      ecrireLigne(canaux_clients[i], ligne);
    }
  }
  pthread_mutex_unlock(&mutexIdentifiants);
}
