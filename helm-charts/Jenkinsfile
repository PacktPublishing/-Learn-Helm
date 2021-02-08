pipeline {
    agent { label "chart-testing-agent" }
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    stages {
        stage("Lint") {
            steps {
                container("chart-testing") {
                    sh "ct lint"
                }
            }
        }
        stage("Install & Test") {
            steps {
                container("chart-testing") {
                    sh "ct install --upgrade"
                }
            }
        }
        stage("Package Charts") {
            steps {
                script {
                    container("chart-testing") {
			sh "helm package --dependency-update helm-charts/charts/*"
                    }
                }
            }
        }
        stage("Push Charts to Chart Repo") {
            steps {
                script {
                    container("chart-testing") {
			// Handle master -> main branch renaming
			def baseBranch = "main"
			if (env.GITHUB_PAGES_BASE_BRANCH) {
			    baseBranch = env.GITHUB_PAGES_BASE_BRANCH
			}

                        // Clone GitHub Pages repository to a folder called "chart-repo"
                        sh "git clone ${env.GITHUB_PAGES_REPO_URL} chart-repo"

                        // Determine if these charts should be pushed to "stable" or "staging" based on the branch
                        def repoType
                        if (env.BRANCH_NAME == baseBranch) {
                            repoType = "stable"
                        } else {
                            repoType = "staging"
                        }

                        // Create the corresponding "stable" or "staging" folder if it does not exist
                        def files = sh(script: "ls chart-repo", returnStdout: true)
                        if (!files.contains(repoType)) {
                            sh "mkdir chart-repo/${repoType}"
                        }

                        // Move packaged charts to the corresponding "stable" or "staging" folder
                        sh "mv *.tgz chart-repo/${repoType}"

                        // Generate the updated index.yaml
                        sh "helm repo index chart-repo/${repoType}"

                        // Update git config details
                        sh "git config --global user.email 'chartrepo-robot@example.com'"
                        sh "git config --global user.name 'chartrepo-robot'"

                        dir("chart-repo") {
			    // Add and commit the changes
		 	    sh "git add --all"
			    sh "git commit -m 'pushing charts from branch ${env.BRANCH_NAME}'"
			    withCredentials([usernameColonPassword(credentialsId: 'github-auth', variable: 'USERPASS')]) {
			        script {

				    // Inject GitHub auth and push to the repo where charts are being served
				    def authRepo = env.GITHUB_PAGES_REPO_URL.replace("://", "://${USERPASS}@")
				    sh "git push ${authRepo} ${baseBranch}"
			        }
			    }
                        }
                    }
                }
            }
        }
    }
}
