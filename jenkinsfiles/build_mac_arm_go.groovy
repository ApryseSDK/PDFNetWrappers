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

    parameters {
        string(name: "FORCE_BRANCH_VERSION", defaultValue: "" ,
               description: "Set to a version if you wish to change the core SDK version used.")
    }

    stages {
        stage ('Build') {
            steps {
                if (params.FORCE_BRANCH_VERSION?.trim()) {
                    s3ArtifactCopyInvoke(
                        "PDFNet Mac/" + params.FORCE_BRANCH_VERSION.replace("/", "%2F"),
                        "PDFNetCMac.zip"
                    )
                } else {
                    s3ArtifactCopyInvoke(
                        "PDFNet Mac/" + getWrappersBranch(branch: env.BRANCH_NAME),
                        "PDFNetCMac.zip"
                    )
                }

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
