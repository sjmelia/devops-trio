# A Trio Of Ops

Three small tasks.

## docker-compose
```
cd docker-compose
docker-compose up -d
docker exec -ti nginx bash
# within container
apt-get update
apt-get install iputils-ping
ping postgres
# ^c
apt-get install postgresql-client
psql -h postgres -U postgres =W # password is postgresa
```
## ansible

- In the spirit of doing the simplest possible thing, this will not create vpc, security group, keypair
etc. so these variables will need to be added when setting `playbooks/group_vars/all`
- For simplicity the role is assigned all s3 permissions instead of a more appropriate granular set
- The task to create a role does not wait for completion; so I added a pause to allow the role to be created
before adding an EC2 instance for that profile
- s3 bucket creation is dependent on a unique name being specified

```
# prerequisite: ansible
sudo pip install boto
cd ansible
cp all.default playbooks/group_vars/all
# edit playbooks/group_vars/all for variables from AWS dashboard
ansible-playbook -i inventory/hosts playbooks/aws.yml
# connect via ssh
# download the pem file matching keypair specified in vars, e.g. devops-ansible.pem
chmod 400 devops-ansible.pem
ssh -i "devops-ansible.pem" <hostname of instance>
# once connected to host
aws s3 ls
echo 'Hello, World!' >> file.txt
aws s3 cp file.text s3://devops-ansible-s3/
# file is now available in bucket
```

## bootstrap

- Doing the simplest possible thing: there is no error checking in the script and it may
only work with Amazon AMIs.
- The logical volume is mounted to `/opt/ephemeral` because '/opt' already contained some
files on my chosen AMI

- Create a new instance using "Amazon Linux AMI 2017.09.1 (HVM), SSD Volume Type - ami-e3051987"
- This must be an instance which supports instance/ephemeral storage e.g. `d2.xlarge`
- Check that the machine has additional Instance Store storage e.g. three additional devices
- Launch the instance with a given keypair e.g. `devops-ansible.pem`

```
# copy the script up
scp -i "devops-ansible.pem" ephemeral/bootstrap.sh <user>@<host>:~/bootstrap.sh
# ssh in
ssh -i "devops-ansible.pem" <user>@<host>
# run the script
chmod +x bootstrap.sh
sudo ./bootstrap.sh
ls /opt/ephemeral/
```

