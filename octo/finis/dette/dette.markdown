# @@ La dette technique @@

# Le concept de dette technique

D'après Wikipedia :

> Il s'inspire du concept existant de dette dans le contexte du financement des entreprises et l'applique au domaine du développement logiciel.
> En résumé, quand on code au plus vite et de manière non optimale, on contracte une dette technique que l'on rembourse tout au long de la vie 
> du projet sous forme de temps de développement de plus en plus long et de bugs de plus en plus fréquents.

# Est-ce que j'ai de la dette technique chez moi et comment la reconnaître ?

Sauf exception, si vous avez du code, vous avez de la dette. Ce n'est pas parce vous n'en parlez pas ou que vous ne la traitez pas qu'il n'y en a pas, c'est même plutôt le contraire.

Pour savoir où elle se cache, il y a des expressions et des comportements qui ne trompent pas :
- « On ne touche pas à cette partie sinon ça va casser », même si elle n'a pas de bug actuellement.
- On duplique par morceaux les fonctionnalités d’un composant dans un autre sans le dire.
- « Il n’y a que X qui connait ce morceau, personne d'autre n'intervient dessus. »
- Un composant pour lequel les chiffrages sont anormalement élevés par rapport aux autres.

Les endroits endettés sont souvent connus par les développeurs. On peut les garder longtemps sous le tapis si les membres du projet ne sont pas sensibilisés à ce problème ou si on leur refuse les moyens de s’en occuper. Pour les identifier une réunion courte sur le thème « Parlez-nous des parties du code qui vous posent des problèmes » suffit. 

![Chat décidé](sophiscated_cat_scaled.png)

*J'ai décidé de m'occuper de ma dette technique*

# Comment arrive-t-elle ?

Développer, c'est faire de la dette.

La dette volontaire :
- Des décisions calculées pour atteindre un objectif à court terme comme une date de livraison importante.
- Développer, c'est faire des choix et donc parfois se tromper, même quand on a pris la meilleure décision possible au moment où on l'a fait. C'est valable lorsqu'elles sont formalisées et visibles (un nouveau framework à utiliser) et pour les choix moins visibles qu'on fait au fil de l'eau en codant.

La dette involontaire :
- Un composant qui évolue beaucoup et qu'on ne refactore pas suffisament régulièrement.
- Un mauvais refactoring qui a quand même été mis en place.
- Un composant laissé sans test automatisé tant qu'il est chaud car on n'en ressent pas le besoin puis qui refroidit dans son coin.
- Un composant dont la connaissance s'est perdue avec le temps ou les changements de personnes, notamment quand on développe un composant particulier dans une technologie spécifique.

Certaines parties d'un projet sont toujours de moins bonne qualité que les autresx car le développement logiciel est une activité artisanale qui produit des résultats imparfait.

[Pour un axe supplémentaire différenciant la dette prudente et la dette téméraire, voir le quadrant de Fowler](http://martinfowler.com/bliki/TechnicalDebtQuadrant.html)

# Pourquoi la traiter ?

Comme l'indique la définition, du code endetté va être plus difficile à faire évoluer car, pour cela, il faudra « rembourser la dette ». Investir pour garder la dette technique sous contrôle permet de conserver un système adaptable et d'éviter d'être bloqué.

![Chat bloqué](cat_glass_jar.jpg)

*Coincés par la dette technique*

L'enjeu est que cette vision soit partagée par l'équipe de développement et le product owner ou chef de projet.

Les non-développeurs ont parfois une vision erronée du refactoring: pour eux refactorer du code qui fonctionne est vu comme de la sur-qualité alors que le sujet est bel est bien la capacité à délivrer.

Lorsqu'il y a un désaccord sur ce point, il faut essayer de factualiser la dette au maximum. Mettre en regard le coût prévu de désendettement et les gains escomptés – diminution de risque et gain de vélocité – permet d'échanger de manière concrète. Mais ces prévisions ne sont jamais certaines, et accepter de développer moins de fonctionnalités pour traiter la dette demande de faire confiance aux développeurs. Si vous vous fiez à leur capacité de réaliser vos demandes, il faut aussi le faire dans ce cas là, ou vous prenez un risque réel sur le futur.

# Comment la traiter ?

La première étape est d'admettre qu'elle existe et de faire un état des lieux. 

On peut la matérialiser dans un backlog : ça permet d'avoir une bonne visibilité et de rester vigilant, attention cependant au backlog kilométrique qui étouffe les bonnes volontés et au backlog bouc émissaire où noter les problèmes permet d'éviter de les traiter.

Un investissement raisonnable mais régulier permet de traiter les cas simples en partant d'une base de code saine. Pour les cas moins favorables vous trouverez des suggestions plus bas..

## Règle d'or

Pas de remboursement de dette technique sans tests automatisés. S'il n'y en a pas ou pas assez, le premier pas doit être d'en ajouter. 
Si un temps limité impose de choisir entre test et refactoring mieux vaut mieux privilégier les tests quitte à reprendre le code plus tard : le risque est trop grand de ne pas aboutir ou d'aboutir à une situation plus mauvaise tout en ayant l'impression d'avoir progressé.

![Sans test](light.jpg)

*Le refactoring sans test*


## Les manière douces

- Au fil de l’eau avec la règle du boy-scout : à chaque intervention sur un bout de code, on essaie de l'améliorer même juste un peu. 
- Une tâche technique budgétée à chaque itération qui porte en partie sur la gestion de la dette sous la responsabilité du tech-lead (attention à ne pas la placer systématiquement en fin de planning car il est alors tentant de la remplacer chaque fois par quelque chose de « plus urgent »). 
- Journée du jardinage : une fois par mois, l'équipe bloque sa journée sur des tâches de désendettement, ce qui donne en plus l'occasion d'échanger collectivement sur le sujet.

## Les manières plus lourdes

Lors d'une longue action de refactoring, la priorité est de ne pas stopper les livraisons d'éléments qui apportent de la valeur fonctionnelle pour ne pas modifier la dynamique du projet. Il vaut mieux dédier un développeur seul pendant une ou plusieurs itérations en compartimentant les éléments à traiter plutôt que de mobiliser toute l'équipe.

![Chat caché](cat_mouth_scaled.jpg)

*Votre chef de projet si vous lui proposez que l'équipe consacre six mois à temps plein à reprendre le code existant*

Attention à bien organiser ces tâches qui peuvent plaire à certains mais qui seront une punition pour d'autres. Comme elles peuvent être l'occasion de reprendre de la connaissance sur des composants oubliés, il faut faire attention à maintenir un équilibre entre les membres de l'équipe, pour éviter de basculer d'un « personne ne sait plus » à « X fait tous les refactoring donc maintenant c'est lui qui sait ».

# Garder le contrôle

Sur le long terme, l'important est d'avoir un système qui ne s'endette pas trop et de garder le contrôle. Les apports de l'agile et de software craftmanship sont ici précieux : il faut être vigilant, échanger et traiter à temps. Les feedback réguliers et les revues de code sous une forme ou une autre sont essentiels. Même s'ils sont imparfaits et ne remplacent pas un œil humain, les outils automatisés (détection de duplication… ) sont également utiles.

La première et la plus importante des choses est que l'équipe au sens large ait conscience des enjeux et soit impliquée sur le sujet.

![Chat volant](flying_cats.jpg)

*Quand le code est sous contrôle, rien ne vous arrête*

# Les limites de la métaphore, les mots qui fâchent

À l'origine, la métaphore est due à [Ward Cunningham](http://fr.wikipedia.org/wiki/Ward_Cunningham) qui l'expliquait ainsi : parfois, on peut faire un écart *temporaire* à nos règles de qualités du design (simplicité, DRY, etc.) en vue de livrer rapidement (comprendre d'ici la fin de l'itération) une solution démontrable. 

Pour une dette financière qui passe par un emprunt, on élabore un budget soutenable et on établit un contrat signé avec une banque. La dette technique n'a pas du tout ce fonctionnement là car elle se créé en partie involontairement et est bien plus difficile à maitriser.

Parler d'une base de code « lourdement endettée », c'est se voiler la face, il vaut mieux parler de code de mauvaise qualité ou de code pourri : cela fait grincer des dents mais au moins les choses sont claires et tout le monde comprend qu'il faut s'en occuper.

# Conclusion et au-delà

La dette technique vous en avez. Si jusqu'à présent ce n'est pas un sujet que vous traitez, il est vital de faire un état des lieux (et si vous voulez, [on peut vous aider](http://octo.com)).

La dette ce n'est pas que dans le code, c'est aussi vos outils (usine de développement, infrastructure) et vote méthode (process et organisation).

*Cet article doit beaucoup aux échanges internes à Octo, merci aux participants.*