node('ec2-fleet') {
    
    // Clone infrastructure repository for tooling
    sshagent(credentials: ['jenkins-aws-ssh']) {
        sh 'ssh -o StrictHostKeyChecking=no thiyagarajan.selvaraj@opsguru.io || true'
        sh 'git clone git@github.com:thiyaguselva/TFAMIBuild.git || true'
        sh 'cd infrastructure && git pull'
    }
    
    // Install Ansible and pip
    sh 'while pgrep dpkg > /dev/null; do echo "Waiting for updates to finish..."; sleep 10; done'
    sh 'sudo apt-get install -y software-properties-common'
    sh' sudo apt-add-repository ppa:ansible/ansible'
    sh 'sudo apt-get update'
    sh 'sudo apt-get install -y ansible python-pip'
    
    // Download Ansible roles
    sh './infrastructure/bin/role_update.sh'
    
    withEnv(["ANSIBLE_ROLES_PATH=$WORKSPACE/infrastructure/roles-shared/:$WORKSPACE/infrastructure/roles-shared/external/"]){
        dir('infrastructure/packer/jenkins_aws/') {
            
            // Download packer and build AMI
            sh 'wget -c https://releases.hashicorp.com/packer/1.1.0/packer_1.1.0_linux_amd64.zip'
            sh 'unzip -o packer_1.1.0_linux_amd64.zip'
            sh './packer build -color=false jenkins_agent_ami.json'

            // Update AMI in Jenkins EC2 plugin
            sh 'wget -c https://raw.githubusercontent.com/burukuru/jenkins-update-ec2-ami/master/jenkins-update-ec2-ami.py'
            sh 'pip install requests boto'
            sh 'JENKINS_AUTH_USER="packer" JENKINS_AUTH_PASSWORD="SECRETPASSWORD" EC2_CLOUD_INSTANCE=ec2 AMI_PROFILE_NAME="aws-jenkins-agent" AWS_REGION="eu-west-1" python jenkins-update-ec2-ami.py'
        }
    }
}
