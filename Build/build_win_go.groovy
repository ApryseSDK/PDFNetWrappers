String cron_default = "0 0 * * *"

String cron_string = isBaseBranch(env.BRANCH_NAME) ? cron_default : ""

pipeline {
    agent { label 'windows_fleet' }

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
                    dir('PDFNetC') {
                        s3ArtifactCopyInvoke("PDFNetC64 VS2013/" + pulling_branch.replace("/", "%2F"), "PDFNetC64.zip", params.INVOKER_BUILD_ID)
                    }
                }


                powershell '''
                    python3 build.py --skip_dl
                '''

                zip zipFile: "build/PDFTronGo.zip", dir: "build/PDFTronGo/pdftron", overwrite: true
            }
        }

        // stage ('Samples') {
        //     steps {
        //         dir('build/PDFTronGo/pdftron/Samples') {
        //             sh './runall_go.sh'
        //         }
        //     }
        // }

        stage ('Upload') {
            steps {
                s3ArtifactUpload("build/PDFTronGo.zip")
                withCredentials([usernamePassword(credentialsId: 'jenkins/s3-upload-user', passwordVariable: 'AWS_SECRET', usernameVariable: 'AWS_ACCESS')]) {
                    powershell '''
                        python3 ./script_tools/scripts/PDFTronUploaderGit.py build/PDFTronGo.zip -ak $env:AWS_ACCESS -s $env:AWS_SECRET -b $env:BUILD_TYPE --force
                    '''
                }
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
