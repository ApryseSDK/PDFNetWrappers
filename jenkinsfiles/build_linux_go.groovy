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

    stages {
        stage ('Build') {
            steps {
                s3ArtifactCopyInvoke(
                    "PDFNetC64_GCC48/" + getWrappersBranch(branch: env.BRANCH_NAME),
                    "PDFNetC64.tar.gz", params.INVOKER_BUILD_ID
                )

                sh '''
                    python3 PDFTronGo/build_go.py
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
