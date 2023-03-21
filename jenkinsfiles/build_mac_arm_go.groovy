String cron_default = "0 0 * * *"

String cron_string = isBaseBranch(env.BRANCH_NAME) ? cron_default : ""

pipeline {
    agent { label 'Silitron' }

    options {
        quietPeriod(60)
        disableConcurrentBuilds()
        timeout(time: 2, unit: 'HOURS')
    }

    environment {
        BUILD_TYPE   = "experimental"
    }

    parameters {
        string(defaultValue: "", description: "The calling build number", name: "INVOKER_BUILD_ID")
    }

    stages {
        stage('Checkout') {
            steps {
                toolsCheckout()
            }
        }

        stage ('Build') {
            steps {
                script {
                    def pulling_branch = env.BRANCH_NAME
                    if (env.BRANCH_NAME == 'next_release') {
                        pulling_branch = 'master'
                    }

                    s3ArtifactCopyInvoke("PDFNet Mac/9.5", "PDFNetCMac.zip", params.INVOKER_BUILD_ID)
                }

                sh '''
                    python3 build.py
                '''
            }
        }

        // stage ('Run test samples') {
        //     steps {
        //         dir('build/PDFTronGo/pdftron/samples') {
        //             sh './runall_go.sh'
        //         }
        //     }
        // }

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
