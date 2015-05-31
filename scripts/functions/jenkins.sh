# Copy files from /usr/share/jenkins/ref into /var/jenkins_home
# So the initial JENKINS-HOME is set with expected content.
# Don't override, as this is just a reference setup, and use from UI
# can then change this, upgrade plugins, etc.
function copy_reference_file() {
    f=${1%/}
    echo "$f"
    rel=${f:23}
    dir=$(dirname ${f})
    echo " $f -> $rel"
    if [[ ! -e $JENKINS_HOME/${rel} ]]
    then
	echo "copy $rel to JENKINS_HOME"
	mkdir -p $JENKINS_HOME/${dir:23}
	cp -r /usr/share/jenkins/ref/${rel} $JENKINS_HOME/${rel};
    fi;
}



function install_jenkins () {
    mkdir -p "$JENKINS_HOME"
    chown -R jenkins "$JENKINS_HOME"
    mkdir -p /etc/supervisor/conf.d
    cat > /etc/supervisor/conf.d/jenkins.conf <<EOF
[program:jenkins]
command=java $JAVA_OPTS -jar /usr/lib/jenkins/jenkins.war $JENKINS_OPTS "$@"
EOF

    export -f copy_reference_file
    find /usr/share/jenkins/ref/ -type f -exec bash -c 'copy_reference_file {}' \;
}
