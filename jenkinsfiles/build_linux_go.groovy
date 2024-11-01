String cron_default = "0 0 * * *"
String cron_string = (env.BRANCH_NAME == "pre_release" || env.BRANCH_NAME == "master" || env.BRANCH_NAME == "next_release") && getWrappersBranch(env.BRANCH_NAME) != "disabled" ? cron_default : ""

pipeline {
    agent {
        docker {
            label 'linux_fleet'
            image 'linux_gowrappers:latest'
            registryUrl 'https://448036597521.dkr.ecr.us-east-1.amazonaws.com'
            registryCredentialsId 'ecr:us-east-1:Jenkins'
            alwaysPull true
        }
    }

    options {
        quietPeriod(60)
        disableConcurrentBuilds()
        timeout(time: 2, unit: 'HOURS')
    }


    triggers { cron(cron_string) }

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
                script {
                    if (params.FORCE_BRANCH_VERSION?.trim()) {
                        s3ArtifactCopyInvoke(
                            "PDFNetC64_GCC48/" + params.FORCE_BRANCH_VERSION.replace("/", "%2F"),
                            "PDFNetC64.tar.gz"
                        )
                    } else {
                        s3ArtifactCopyInvoke(
                            "PDFNetC64_GCC48/" + getWrappersBranch(env.BRANCH_NAME),
                            "PDFNetC64.tar.gz"
                        )
                    }
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
                sh 'mv build/PDFTronGo.zip build/PDFTronGoLinux.zip'
                s3ArtifactUpload("build/PDFTronGoLinux.zip")
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
