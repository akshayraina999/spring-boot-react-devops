pipeline{
    agent any

    tools{
        maven 'maven_3_5_0'
    }

    environment {
		DOCKERHUB_CREDENTIALS=credentials('dockerpasswd')
	} 

    parameters{
        // gitParameter branchFilter: 'origin/(.*)', defaultValue: 'master', name: 'BRANCH', type: 'PT_BRANCH'
        gitParameter branchFilter: 'origin.*/(.*)', defaultValue: 'master', name: 'BRANCH', type: 'PT_BRANCH'
        // gitParameter branch: '', branchFilter: '.*', defaultValue: 'master', name: 'BRANCH', quickFilterEnabled: false, selectedValue: 'NONE', sortMode: 'NONE', tagFilter: '*', type: 'GitParameterDefinition'
    }

    stages{
        stage("Java SCM Checkout"){
            steps{
                echo "========Java Code Checkout========"
                git branch: "${params.BRANCH}", url: 'https://github.com/akshayraina999/spring-boot-react-app.git'
            }
        }
        stage("Compile"){
            steps{
                echo "========Compiling Code========"
                sh 'mvn clean install'
            }
        }
        stage("SCM for DevOps files"){
            steps{
                echo "========Source Code Checkout for DevOps files========"
                git credentialsId: 'github',
                    url: 'https://github.com/akshayraina999/spring-boot-react-devops.git'
            }
        }
        stage("Docker Image Build"){
            steps{
                echo "========Building Docker Image========"
                sh 'docker build . -t akshayraina/${JOB_NAME}:v1.${BUILD_ID}'
            }
        }
        stage("Saving Image to DockerHub"){
            steps{
                echo "========Pushing Docker Image========"
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh 'docker push akshayraina/$JOB_NAME:v1.$BUILD_ID'
                sh 'docker rmi akshayraina/$JOB_NAME:v1.$BUILD_ID'
            }
        }
        stage("Transferring files to Ansible Server"){
            steps{
                echo "========Transferring files to Kubernetes Server========"
                sshagent(['ansible_server']){
                    sh 'ssh -o StrictHostKeyChecking=no root@10.154.14.18 [ -d /home/ubuntu/${JOB_NAME}-scripts ] || mkdir /home/ubuntu/${JOB_NAME}-scripts/'
                    sh 'scp /var/lib/jenkins/workspace/${JOB_NAME}/make_dir.sh root@10.154.14.18:/home/ubuntu/${JOB_NAME}-scripts/'
                    sh 'ssh -o StrictHostKeyChecking=no root@10.154.14.18 chmod +x /home/ubuntu/${JOB_NAME}-scripts/make_dir.sh'
                    sh 'ssh -o StrictHostKeyChecking=no root@10.154.14.18 /home/ubuntu/${JOB_NAME}-scripts/make_dir.sh ${JOB_NAME}'
                    sh 'ssh -o StrictHostKeyChecking=no root@10.154.14.18 cd /home/ubuntu/spring-boot-websocket/'
                    sh 'scp /var/lib/jenkins/workspace/${JOB_NAME}/playbook.yml root@10.154.14.18:/home/ubuntu/${JOB_NAME}/'
                }
            }
        }
        stage("Transferring files to Kubernetes Server"){
            steps{
                echo "========Transferring files to Kubernetes Server========"
                sshagent(['kubernetes_server']){
                // sh 'ssh -o StrictHostKeyChecking=no akshay@192.168.1.88 cd /home/pc/spring-boot-websocket/'
                // sh 'mkdir -p /home/pc/${JOB_NAME}/' 192.168.1.88
                sh 'ssh -o StrictHostKeyChecking=no akshay@192.168.1.88 [ -d /home/pc/${JOB_NAME}-scripts ] || mkdir /home/pc/${JOB_NAME}-scripts/'
                sh 'scp /var/lib/jenkins/workspace/${JOB_NAME}/make_dir.sh akshay@192.168.1.88:/home/pc/${JOB_NAME}-scripts/'
                sh 'scp /var/lib/jenkins/workspace/${JOB_NAME}/deploy.yml akshay@192.168.1.88:/home/pc/${JOB_NAME}/'
                sh "ssh -o StrictHostKeyChecking=no akshay@192.168.1.88 sed -i 's/image_name/${JOB_NAME}/' /home/pc/${JOB_NAME}/deploy.yml"
                sh "ssh -o StrictHostKeyChecking=no akshay@192.168.1.88 sed -i 's/build_number/${BUILD_ID}/' /home/pc/${JOB_NAME}/deploy.yml"
                }
            }
        }
        stage("Deploy on Kubernetes"){
            steps{
                echo "========Deploying on Kubernetes Server========"
                sshagent(['ansible_server']){
                    sh "ssh -o StrictHostKeyChecking=no root@10.154.14.18 sed -i 's/folder_name/${JOB_NAME}/' /home/pc/${JOB_NAME}/deploy.yml"
                    sh 'ssh -o StrictHostKeyChecking=no root@10.154.14.18 ansible-playbook /home/ubuntu/${JOB_NAME}/playbook.yml'
                }
            }
        }
    }
}