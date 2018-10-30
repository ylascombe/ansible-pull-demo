Ce dossier contient l'ensemble du code nécessaire pour tester une commande ansible-pull sur une instance AWS.

cloud-init :
* met à jour le système
* installe les paquets Git et Ansible (un repository est configuré pour avoir la version 2.7 d'ansible)
* crée un script shell qui permet d'exécuter `ansible-pull` dans le dossier /etc/ansible-pull/cron.sh
* configure une crontab pour exécuter le script `/etc/ansible-pull/cron.sh` toutes les 30 minutes

ansible-pull :
* écrit simplement le fichier /etc/ansible


# Pré-requis
 Positionner les variables AWS
 ```
 cat > setenv.sh <<EOF
 #! /bin/bash
 
 export AWS_ACCESS_KEY_ID=<your AWS OPS User Access Key ID>
 export AWS_SECRET_ACCESS_KEY=<your AWS OPS User Secret Access Key>
 export AWS_REGION=eu-central-1
 export KEY_PAIR=<your key name>
 EOF
 source setenv.sh
 ```
 
Positionner des valeurs pour les variables Terraform. Exemple en créant un fichier
 ```
 cat > terraform/terraform.tfvars <<EOF
aws_trigram= "yol"
aws_keypair = "yol"

node_type = "primary"
env = "demo"
EOF
```

Stocker la clé privée qui permet d'accéder aux VMs.

# Initialiser terraform

Juste la première fois, effectuer  un terraform init

```
terraform init
```

# Provisioning de l'infrastructure sur AWS

```
terraform apply
```

# Vérification que le cloud-init s'est correctement exécuté

Vu que c'est cloud-init qui installe les outils (Git, ansible) et qui configure le crontab pour lancer le script shell qui exécute ansible-pull, 
il faut voir s'il s'exécute correctement.

Pour cela, ouvrir une connexion SSH sur la machine `puller-web` (son adresse s'affiche en fin de commande terraform) puis : 

```
sudo tail -f /var/log/cloud-init-output.log
```

Exemple de fin de srotie de console attendue: 

```
Setting up python-pyasn1 (0.1.9-1) ...
Setting up python-cryptography (1.2.3-1ubuntu0.1) ...
Setting up ansible (2.7.0-1ppa~xenial) ...
Cloud-init v. 17.1 running 'modules:final' at Sun, 21 Oct 2018 22:21:21 +0000. Up 21.74 seconds.
Cloud-init v. 17.1 finished at Sun, 21 Oct 2018 22:22:56 +0000. Datasource DataSourceEc2Local.  Up 116.78 seconds
```


# Vérification qu'ansible-pull s'est terminé

Les logs sont d'ansible-pull sont écrits dans le fichier `/var/log/ansible-pull.log`.
Le playbook `provision.yml` lancé ansible-pull écrit simplement le fichier /etc/env_infos.

Pour éviter d'attendre le prochain lancement du crontab, il est possible d'exécuter directement le script avec la commande suivante : 
```
sudo su -
/etc/ansible-pull/cron.sh > /var/log/ansible-pull.log 2>&1
```
