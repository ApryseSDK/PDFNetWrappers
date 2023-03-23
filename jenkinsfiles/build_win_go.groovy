pipeline {
    agent { label 'windows_fleet' }

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
                    "PDFNetC64 VS2013/" + getWrappersBranch(branch: env.BRANCH_NAME),
                    "PDFNetC64.zip"
                )

                powershell '''
                    python3 PDFTronGo/build_go.py
                '''
            }
        }

        stage ('Run test samples') {
            steps {
                withCredentials([string(credentialsId: 'jenkins/core-sdk-key', variable: 'ENV_LICENSE_KEY')]) {
                    dir('build/PDFTronGo/pdftron/samples') {
                        sh '''
                            ./runall_go.bat
                        '''
                    }
                }
            }
        }

        stage ('Upload') {
            steps {
                powershell 'move build/PDFTronGo.zip build/PDFTronGoWin.zip'
                s3ArtifactUpload("build/PDFTronGoWin.zip")
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
