pre_start_action() {
  install_supervisor
  install_postfix
  install_jenkins
}

post_start_action() {
    rm /first_run
}
