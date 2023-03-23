pipeline {
    agent { label 'Silitron' }

    options {
        quietPeriod(60)
        disableConcurrentBuilds()
        timeout(time: 2, unit: 'HOURS')
    }

    environment {
        GOCACHE      = "/tmp/.cache"
    }

    stages {
        stage ('Build') {
            steps {
                s3ArtifactCopyInvoke(
                    "PDFNet Mac/" + getWrappersBranch(branch: env.BRANCH_NAME),
                    "PDFNetCMac.zip"
                )

                sh '''
                    python3 PDFTronGo/build_go.py
                '''
            }
        }

        stage ('Run test samples') {
            steps {
                withCredentials([string(credentialsId: 'jenkins/core-sdk-key', variable: 'ENV_LICENSE_KEY')]) {
                    dir('build/PDFTronGo/pdftron/samples') {
                        sh '''
                            ./runall_go.sh
                        '''
                    }
                }
            }
        }

        stage ('Upload') {
            steps {
                sh 'mv build/PDFTronGo.zip build/PDFTronGoMacArm.zip'
                s3ArtifactUpload("build/PDFTronGoMacArm.zip")
            }
        }
    }

    post {
        failure {
            sendMail([
                currentBuild: currentBuild,
                env: env
            ])
        }
    }
}
