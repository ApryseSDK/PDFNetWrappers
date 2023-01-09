String cron_default = "0 0 * * *"

String cron_string = isBaseBranch(env.BRANCH_NAME) ? cron_default : ""

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

    triggers { cron(cron_string) }

    options {
        quietPeriod(60)
        disableConcurrentBuilds()
        timeout(time: 2, unit: 'HOURS')
    }

    environment {
        BUILD_TYPE   = "experimental"
    }

    stages {
        stage('Checkout') {
            steps {
                toolsCheckout()
            }
        }

        stage ('Build') {
            steps {
                sh '''
                    python3 build.py
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
                // withCredentials([usernamePassword(credentialsId: 's3_upload_nightly_creds', passwordVariable: 'AWS_SECRET', usernameVariable: 'AWS_ACCESS')]) {
                //     sh '''
                //         python ./script_tools/scripts/PDFTronUploaderGit.py build/PDFTronGo.tar.gz -ak ${AWS_ACCESS} -s ${AWS_SECRET} -b ${BUILD_TYPE} -ak ${AWS_ACCESS} -s ${AWS_SECRET} --force
                //     '''
                // }
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
