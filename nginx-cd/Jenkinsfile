pipeline {
    agent { label "chart-testing-agent" }
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    stages {
        stage("Setup") {
            steps {
                container("chart-testing") {
                    sh "helm repo add learnhelm ${env.GITHUB_PAGES_SITE_URL}"
                }
            }
        }
        stage("Deploy to Dev") {
            steps {
                container("chart-testing") {
                    dir("nginx-cd") {
                        sh "helm upgrade --install nginx-${env.BRANCH_NAME} learnhelm/nginx --values common-values.yaml --values dev/values.yaml -n dev --wait"
                    }
                }
            }
        }
        stage("Smoke Test") {
            steps {
                container("chart-testing") {
                    sh "helm test nginx-${env.BRANCH_NAME} -n dev"
                }
            }
        }
        stage("Deploy to QA") {
            when {
                expression {
                    return env.BRANCH_NAME == "master"
                }
            }
            steps {
                container("chart-testing") {
                    dir("nginx-cd") {
                        sh "helm upgrade --install nginx-${env.BRANCH_NAME} learnhelm/nginx --values common-values.yaml --values qa/values.yaml -n qa --wait"
                    }
                }
            }
        }
        stage("Wait for Input") {
            when {
                expression {
                    return env.BRANCH_NAME == "master"
                }
            }
            steps {
                container("chart-testing") {
                    input "Deploy to Prod?"
                }
            }
        }
        stage("Deploy to Prod") {
            when {
                expression {
                    return env.BRANCH_NAME == "master"
                }
            }
            steps {
                container("chart-testing") {
                    dir("nginx-cd") {
                        sh "helm upgrade --install nginx-${env.BRANCH_NAME} learnhelm/nginx --values common-values.yaml --values prod/values.yaml -n prod --wait"
                    }
                }
            }
        }
    }
}
