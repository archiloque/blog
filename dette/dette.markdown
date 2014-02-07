# Le concept de dette technique

D'après Wikipedia:

> Il s'inspire du concept existant de dette dans le contexte du financement des entreprises et l'applique au domaine du développement logiciel.
> En résumé quand on code au plus vite et de manière non optimale, on contracte une dette technique que l'on rembourse tout au long de la vie 
> du projet sous forme de temps de développement de plus en plus long et de bugs de plus en plus fréquents.

# Est ce que j'ai de la dette technique chez moi et comment la reconnaitre ?

Oui, sauf exception si vous avez du code vous avez de la dette. ce n'est pas parce vous n'en parlez pas ou que vous ne la traitez pas qu'il n'y en a pas, c'est même plutôt le contraire.

Pour savoir où elle se cache, il y a des expressions et des comportements qui ne trompent pas :
- "On ne touche pas à cette partie sinon ça va casser", même si à l'heure actuelle elle n'a pas de bug
- On duplique par morceaux les fonctionnalités d’un composant dans un autre sans le dire
- "Il n’y a que X qui connait ce morceau, personne d'autre n'intervient dessus"
- Un composant pour lesquels les chiffrages sont anormalement élevés par rapport aux autres

Les endroits endettés sont souvent connus par les développeurs. On peut les garder longtemps sous le tapis si les membres du projet ne sont pas sensibilisés à ce problème ou si on leur refuse les moyens de s’en occuper. Une réunion courte avec pour thème « Parlez nous des parties du code qui vous posent des problèmes » suffit pour les identifier. 

![Chat décidé](sophiscated_cat_scaled.png)

*J'ai décidé de m'occupper de ma dette technique*

# Comment elle arrive ?

Développer c'est faire de la dette.

La dette volontaire :
- Des décisions calculées pour atteindre un objectif à court terme comme une date de livraison importante.
- Développer c'est faire des choix et donc parfois se tromper, même quand on a pris la meilleure décision possible où moment où on l'a fait. C'est valable lorsque ces décisions sont formalisées et visibles (un nouveau framework à utiliser) ou moins visibles au fil de l'eau.

La dette involontaire:
- Un composant qui évolue beaucoup et qu'on ne refactore pas suffisament régulièrement.
- Un refactoring mal fait mis en place quand même.
- Un composant laissé sans test automatisés tant qu'il est chaud car on n'en ressent pas le besoin puis qui refroidit dans son coin.
- Un composant dont la connaissance s'est perdue avec le temps ou les changements de personnes, notament quand on développe un composant particulier dans une technologie spécifique.

On a toujours certaines parties d'un projet de moins bonne qualité que les autres: ce n'est pas causé par un problème de niveau des développeurs (sauf dans les cas graves) mais une conséquence directe du fait que le développement logiciel est une activité artisanale.

[Pour un axe supplémentaire différenciant la dette prudente et la dette téméraire, voir le quadrant de Fowler](http://martinfowler.com/bliki/TechnicalDebtQuadrant.html)

# Pourquoi la traiter

Comme l'indique la définition du code endetté va être plus difficile à faire évoluer car pour cela il faudra "rembourser la dette". Investir pour garder la dette technique sous contrôle permet de conserver un système adaptable et d'éviter d'être coincé.

![Chat bloqué](cat_glass_jar.jpg)

*Bloqués par la dette technique*

L'enjeu est que cette vision soit partagée par l'équipe de développement et le product owner ou chef de projet.

Quand on leur parle de code endetté les non développeurs ont souvent une vision de développeurs qui veulent se faire plaisir et faire de la sur-qualité en refactorant pour des raisons esthétiques alors que le sujet est bel est bien un enjeu de capacité à délivrer.

Lorsqu'il y a un désaccord sur ce point, il faut factualiser au maximum la dette. Mettre en regard le coût prévu de désendettement et les gains escomptés en terme de risque et de gain de vélocité prévu permet d'échanger de manière concrète. Mais accepter les propositions des développeurs quand choisir de traiter la dette signifie de développer moins de nouvelles fonctionnalités demande une certaine confiance dans leur jugement. Si vous vous fiez aux développeurs dans leur capacité à réaliser ce que vous leur demandez il faut aussi le faire dans ce cas là, ou vous prenez un risque réel sur le futur.

# Comment la traiter

La première étape est d'admettre qu'elle existe et de faire un état des lieux. Ensuite en fonction du temps disponible et de l'urgence il sera le moment de s'en occuper.

On peut la matérialiser dans un backlog: ça permet d'avoir une bonne visibilité et de rester vigilant, attention cependant au backlog kilométrique qui fait disparaitre les bonnes volontés ou au backlog bouc-émissaire qui permet de dire que ce n'est pas grave de traiter les problèmes tant qu'on les identifie et qu'on sait qu'ils sont là.

Dans la vie de tous les jours pour une base de code saine un investissement raisonnable mais régulier permet de traiter les cas simples mais n'est jamais suffisante. Pour les autres cas voir plus bas.

## Règle d'or

Pas de remboursement de dette technique sans tests automatisés. S'il n'y en a pas ou pas assez le premier pas doit être d’ajouter des tests même si ça veut dire ne plus avoir de temps pour mener le refactoring maintenant. Le risque est trop grand que de ne pas aboutir ou d'aboutir à une situation objectivement pas meilleure tout en ayant l'impression d'avoir progressé.

![Sans test](light.jpg)

*Le refactoring sans test*


## Les manière douces

- Au fil de l’eau avec la règle du boy-scout : un bout de code doit être plus propre quand tu arrête de travailler dessus que quand tu as commencé.
- Un tache technique budgétée à chaque sprint qui porte en partie sur la gestion de la dette sous la responsabilité du tech-lead (attention à ne pas la placer systématiquement en fin de sprint au risque qu'elle saute à chaque fois)
- Journée du jardinage : 1 fois par mois, l'équipe bloque sa journée sur des tâches de désendettement qui n'ont pas été traité sur le mois, qui donne en plus l'occasion d'échanger collectivement sur le sujet

## Les manières plus lourdes

Quand un bloc est trop gros, la priorité est de ne pas stopper les livraisons d'éléments qui apportent du fonctionnel pour ne pas modifier la dynamique du projet. Il vaut mieux dédier un développeur seul pendant un ou plusieurs sprints en compartimentant les éléments à traiter plutôt que de mobiliser toute l'équipe.

![Chat caché](cat_mouth_scaled.jpg)

*Votre chef de projet si vous lui proposez que l'équipe consacre 6 mois à temps plein à refactorer*

Attention à bien organiser ces tâches qui peuvent plaire à certains mais qui seront une punition pour d'autres. Comme ces taches peuvent être l'occasion de reprendre de la connaissance sur des composants oubliés il faut faire attention à maintenir un équilibre entre les membres de l'équipe, pour éviter de basculer d'un "personne ne sait plus" à "X fait tous les refactoring donc maintenant c'est lui qui sait".

# Garder le contrôle

Sur le long terme l'important est d'avoir un système qui ne s'endette pas trop et de garder le contrôle. Les apports de l'agile et de software craftmanship sont ici précieux: il faut être vigilant, échanger et traiter à temps. Les feedback réguliers et les revues de code sous une forme ou une autre sont essentiels. Même s'ils sont imparfaits et ne remplacent pas un œil humain, les outils automatisés (détection de la duplication ....) sont également utiles.

La première et la plus importante des choses est que l'équipe au sens large ait conscience des enjeux et soit impliquée sur le sujet.

![Chat dans la neige](snow-cat_scaled.png)

*Quand le code est sous contrôle, rien ne vous arrête*

# Les limites de la métaphore, les mots qui fâchent

À l'origine La métaphore est due à Ward Cunningham qui l'expliquait grosso modo ainsi: quelques fois, on peut faire un écart /TEMPORAIRE/ à nos règles de qualités du design (simplicité, DRY, etc.) en vue de livrer rapidement (comprendre d'ici la fin du sprint) une solution démontrable. 

Pour une dette financière on élabore un budget soutenable et on établit un contrat signé avec une banque. La dette technique n'a pas du tout ce fonctionnement là car c'est quelque chose que se créé en partie involontairement et de bien plus difficile à maitriser.

Parler d'une base de code "lourdement endettée" c'est se voiler la face, il vaut mieux parler de code de mauvaise qualité ou de code pourri: ça fait grincer des dents mais au moins les choses sont claires et tout le monde comprend qu'il faut faire quelque chose.

# Conclusion et au delà

La dette vous en avez, si jusqu'à présent ce n'est pas un sujet que vous traité il est vital de faire un état des lieux (et si vous voulez, [on peut vous aider](http://octo.com))

La dette ce n'est pas que dans le code, c'est aussi vos outils (usine de développement, infrastructure) et ailleurs (process et organisation)


*Cet article doit beaucoup aux échanges internes à Octo, que les participants soient remerciés.*