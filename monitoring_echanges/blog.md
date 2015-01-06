+ Présent et avenir du monitoring de flux 

Nous allons vous présenter les pratiques actuelles et les évolutions en cours du monitoring de flux.
Cela devrait vous permettre de comparer votre système actuel avec les pratiques généralement observées et de vos donner des idées pour la suite.

+ Monitoring de flux ?

On appelle un *flux* un **ensemble d'appels de services et d'envois de messages qui ensemble forment un service métier**. Dans un système d'information complexe, un tel flux traverse souvent plusieurs applications et utilise parfois plusieurs technologie: par exemple le traitement d'un appel de service SOAP provoquera l'envoi de messages JMS qui eux-même pourront déclencher d'autres traitements.

Monitorer ces flux revient donc à un monitoring des activité métier *(Business Activity Monitor)* qui consiste à collecter des données à différents niveaux et de les corréler pour présenter **une vision transverse agrégée**. Ce monitoring doit fournir à tout moment **l'état de santé et la performance des fonctions métiers importantes** *(Key Performance Indicator)*.

++ Pour avoir un bon monitoring de flux

## Fonctionalités

La fonctionalité essentielle est d'être capable d'**identifier les flux métier** dans les messages atomiques. Généralement cela passe par l'utilisation d'un identifiant unique *(correlation id), qui doit être porté par tous les messages d'un même flux, identifiant qui se retrouvera dans les messages d’audit. Pour gérer cet identifiant il est donc nécessaire de mettre en place une brique spécfique dans les différents applicatifs pour générer l'identifiant en début de chaîne et le propager dans les traitements.

Le système doit être capable d'*intégrer des évènements hétérogènes*: si les messages envoyés par les différents composants comportent des éléments communs (horodatage par exemple) ils comportent aussi des informations spécifiques liées au métier du service (nom du service métier, type d'objet traité). Être capable d'intégrer facilement ces différentes données permettra de construire au plus juste des métriques métiers qui évolueront en même temps que les services.

Ensuite il faut disposer d'un système de *dashboarding customizable*: il ne s'agit pas seulent de prédéfinir un ensemble d'écrans de monitoring fixes, mais aussi de pouvoir s'en servir pour investiguer des comportements en s'appuyant sur les informations métier. Cela signifie qu'une fois mis en place il doit être configurable dynamiquement pour modifier des écrans ou en créer de nouveaux à la volée. Les systèmes de monitoring utilisés habituellement pour les systèmes de production sont donc généralement mal adaptés à ce type d'usage.

La base de donnée doit fournir des fonctionalités d'indexation avec une couverture maximum, l'idéal étant d'*indexer l'intégralité des données*. Cela permet de simplifier considérablement les investigation en cas d'erreur en pouvant chercher tous les messages lié à un certain identtifiant métier, par exemple tous les messages lié à un certain compte avec son numéro. Pour des questions de volume on pourra limiter l'indexation dans le temps (48 heures par exemple), en gardant la possibilité de réindexer des messages passés.

## Constraintes

Tout d'abord un échec dans la piste d'audit ne doit *pas entrainer de conséquences sur le fonctionel*, il faut donc bien isoler techniquement les deux.

Ensuire le monitoring ne doit *pas entrainer de baisse de performances* du traitement principal, les informations de monitoring doivent être envoyées sous forme d’évènements asynchrones (pattern [wiretap](http://www.enterpriseintegrationpatterns.com/WireTap.html)). Pour cela on s'appuie sur un middleware de messages, souvent la même technlogie que celui utilisé pour les flux métier.

Il est souvent pertinent d'avoir une infrastructure de message dédiée au monitoring:
- le nombre de message de monitoring est important – souvent plus que de messages  métier, on évite ainsi un engorgement
- en cas de problème dans le monitoring des flux on est certain de ne pas avoir d'impact business

Il faut *limiter les développement métier dans les briques de monitoring*: si de la configuration ou un peu de développement spécifique lié au métier est inévitable, nottament pout les métriques les plus précises, il faut éviter de recoder des comportement fonctionnels. Cela se produit souvent quand on veut s'appuyer sur les message de monitoring pour reproduire l'état des échanges dans le système monitoré pour mettre en place des stratégies de rejeu partiel. Le résultat est souvent fragile et va rendre plus difficile les évolutions du métier.

+ Pratiques actuelles

++ Limites

+ L'avenir

